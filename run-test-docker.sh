#!/bin/bash
set -e
echo "======================================"
echo "ONNX Runtime Problem - Test"
echo "======================================"
echo

# colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # no color

# check if we're in the right directory
if [ ! -f "main.ts" ] || [ ! -f "main.cc" ]; then
    echo -e "${RED}error: cannot find main.ts or main.cc${NC}"
    echo "please run this script from the repository root"
    exit 1
fi
echo -e "${GREEN}✓ repository files found${NC}"
echo
# check if onnxruntime directory exists
if [ ! -d "onnxruntime" ]; then
    echo -e "${YELLOW}warning: onnxruntime directory not found${NC}"
    echo "you need to provide the onnxruntime library"
    echo
    read -p "do you want to continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# clean up old outputs
echo "cleaning up old output files..."
rm -rf outputs
mkdir -p outputs
echo

# build images
echo "building docker images..."
echo "(this may take a few minutes the first time)"
echo
docker-compose build
echo
echo -e "${GREEN}✓ docker images built successfully${NC}"
echo

# run deno wasm version
echo "======================================"
echo "running deno wasm (javascript) version..."
echo "======================================"
docker-compose run --rm deno-test
echo
echo -e "${GREEN}✓ deno wasm version completed${NC}"
echo

# run deno node version
echo "======================================"
echo "running deno node (javascript) version..."
echo "======================================"
docker-compose run --rm deno-node-test
echo
echo -e "${GREEN}✓ deno node version completed${NC}"
echo

# run c++ version
echo "======================================"
echo "running c++ version..."
echo "======================================"
docker-compose run --rm cpp-test
echo
echo -e "${GREEN}✓ c++ version completed${NC}"
echo

# check if outputs exist
if [ ! -f "outputs/js_output.bin" ]; then
    echo -e "${RED}error: js_output.bin not created${NC}"
    exit 1
fi
if [ ! -f "outputs/js-node_output.bin" ]; then
    echo -e "${RED}error: js-node_output.bin not created${NC}"
    exit 1
fi
if [ ! -f "outputs/cc_output.bin" ]; then
    echo -e "${RED}error: cc_output.bin not created${NC}"
    exit 1
fi

# compare outputs
echo "======================================"
echo "comparing outputs..."
echo "======================================"
echo

WASM_NODE_MATCH=false
WASM_CPP_MATCH=false
NODE_CPP_MATCH=false

# compare wasm vs node
if diff -q outputs/js_output.bin outputs/js-node_output.bin > /dev/null; then
    echo -e "${GREEN}✓ wasm vs node: identical${NC}"
    WASM_NODE_MATCH=true
else
    echo -e "${YELLOW}⚠ wasm vs node: differ${NC}"
fi
# compare wasm vs c++
if diff -q outputs/js_output.bin outputs/cc_output.bin > /dev/null; then
    echo -e "${GREEN}✓ wasm vs c++: identical${NC}"
    WASM_CPP_MATCH=true
else
    echo -e "${YELLOW}⚠ wasm vs c++: differ${NC}"
fi
# compare node vs c++
if diff -q outputs/js-node_output.bin outputs/cc_output.bin > /dev/null; then
    echo -e "${GREEN}✓ node vs c++: identical${NC}"
    NODE_CPP_MATCH=true
else
    echo -e "${YELLOW}⚠ node vs c++: differ${NC}"
fi
echo

# summary
if [ "$WASM_NODE_MATCH" = true ] && [ "$WASM_CPP_MATCH" = true ] && [ "$NODE_CPP_MATCH" = true ]; then
    echo -e "${GREEN}✓✓✓ success! all outputs are identical ✓✓✓${NC}"
    echo "the graph optimization fix resolved the discrepancy"
else
    echo -e "${YELLOW}⚠ some outputs differ${NC}"
fi
echo
echo "file sizes:"
ls -lh outputs/*.bin | awk '{print $5, $9}'
echo
echo "first 64 bytes of each file:"
echo -e "${BLUE}--- js_output.bin (wasm) ---${NC}"
hexdump -C outputs/js_output.bin | head -n 4
echo -e "${BLUE}--- js-node_output.bin (node) ---${NC}"
hexdump -C outputs/js-node_output.bin | head -n 4
echo -e "${BLUE}--- cc_output.bin (c++) ---${NC}"
hexdump -C outputs/cc_output.bin | head -n 4
echo
if [ "$WASM_NODE_MATCH" = false ] || [ "$WASM_CPP_MATCH" = false ] || [ "$NODE_CPP_MATCH" = false ]; then
    echo -e "${YELLOW}possible issues:${NC}"
    echo "1. graph optimization fix not applied to main.cc"
    echo "2. different onnxruntime versions"
    echo "3. binary data corruption during copy"
fi
echo
echo "======================================"
echo "test complete"
echo "======================================"
echo
echo "to clean up:"
echo "  docker-compose down"
echo "  docker system prune -a"
echo