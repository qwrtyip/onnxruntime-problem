import { env, InferenceSession, Tensor } from "npm:onnxruntime-web@1.22.0/wasm";

// disable blob URLs, use file system
env.wasm.numThreads = 1;
env.wasm.simd = false;

const session = await InferenceSession.create(
  Deno.readFileSync("model.bin"),
  {
    executionMode: "sequential",
    interOpNumThreads: 1,
    intraOpNumThreads: 1,
    executionProviders: ["cpu"],
    graphOptimizationLevel: "disabled",
  },
);

const tensor = new Tensor(
  "float32",
  new Float32Array(Deno.readFileSync("input.bin").buffer),
  [4, 40, 36],
);
const output = await session.run(
  Object.fromEntries(
    session.inputNames.map((v): [string, Tensor] => [v, tensor]),
  ),
);

Deno.writeFileSync(
  "outputs/js_output.bin",
  new Uint8Array(
    (output[session.outputNames[0]].data as Float32Array<ArrayBuffer>).buffer,
  ),
);