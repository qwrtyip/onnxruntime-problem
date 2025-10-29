import * as ort from "npm:onnxruntime-node@1.22.0";

const session = await ort.InferenceSession.create(
  Deno.readFileSync("model.bin"),
  {
    executionMode: "sequential",
    interOpNumThreads: 1,
    intraOpNumThreads: 1,
    executionProviders: ["cpu"],
  },
);

const tensor = new ort.Tensor(
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
  "outputs/js-node_output.bin",
  new Uint8Array(
    (output[session.outputNames[0]].data as Float32Array<ArrayBuffer>).buffer,
  ),
);