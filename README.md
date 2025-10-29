# The Problem

`js_output.bin != cc_output.bin` where the expected output is `js_output.bin`.

## How to Run

1. Clone repo
2. Get runtime inside cloned dir
```
# macos arm64
wget https://github.com/microsoft/onnxruntime/releases/download/v1.20.1/onnxruntime-osx-arm64-1.20.1.tgz
tar -xzf onnxruntime-osx-arm64-1.20.1.tgz
mv onnxruntime-osx-arm64-1.20.1 onnxruntime

# linux x64
wget https://github.com/microsoft/onnxruntime/releases/download/v1.20.1/onnxruntime-linux-x64-1.20.1.tgz
tar -xzf onnxruntime-linux-x64-1.20.1.tgz
mv onnxruntime-linux-x64-1.20.1 onnxruntime
```
3. Have podman or docker setup
4. Run run-test-docker.sh or run-test-podman.sh