# The Problem

`js_output.bin != cc_output.bin` where the expected output is `js_output.bin`.

## How to Run

## JavaScript

```ts
deno -A main.ts # Creates js_output.bin
```

## C++

1. Build ONNX Runtime following the instructions at https://github.com/olilarkin/ort-builder.
2. Copy its build output to the root directory of this project under a new directory called `onnxruntime`.
3. Run this:

```shell
./configure.sh
./build.sh
./build/problem # Creates cc_output.bin
```
