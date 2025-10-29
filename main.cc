#include <fstream>
#include <onnxruntime_cxx_api.h>
#include <iostream>

char *read_file(const char *filename) {
  std::ifstream file(filename, std::ios::binary | std::ios::ate);

  size_t size = file.tellg();
  char *buffer = new char[size + 1];

  file.seekg(0);
  file.read(buffer, size);

  return buffer;
}

int main() {
  auto env = Ort::Env{ORT_LOGGING_LEVEL_ERROR, "Default"};

  Ort::SessionOptions so;
  so.SetGraphOptimizationLevel(GraphOptimizationLevel::ORT_DISABLE_ALL);
  so.SetExecutionMode(ORT_SEQUENTIAL);
  so.SetInterOpNumThreads(1);
  so.SetIntraOpNumThreads(1);

  auto session =
      std::make_unique<Ort::Session>(Ort::Session(env, "model.bin", so));

  const float *input = reinterpret_cast<float *>(read_file("input.bin"));
  std::vector<float> input_vector(input, input + 5760);

  auto memory_info =
      Ort::MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault);
  std::vector<int64_t> shape = {4, 40, 36};


  std::vector<Ort::Value> input_tensors;
  input_tensors.push_back((Ort::Value::CreateTensor<float>(
      memory_info, input_vector.data(), input_vector.size(), shape.data(),
      shape.size())));

  using AllocatedStringPtr = std::unique_ptr<char, Ort::detail::AllocatedFree>;
  std::vector<const char *> input_names;
  std::vector<AllocatedStringPtr> inputNodeNameAllocatedStrings;
  std::vector<const char *> output_names;
  std::vector<AllocatedStringPtr> outputNodeNameAllocatedStrings;
  Ort::AllocatorWithDefaultOptions allocator;

  size_t numInputNodes = session->GetInputCount();
  for (int i = 0; i < numInputNodes; i++) {
    auto input_name = session->GetInputNameAllocated(i, allocator);
    inputNodeNameAllocatedStrings.push_back(std::move(input_name));
    input_names.emplace_back(inputNodeNameAllocatedStrings.back().get());
  }

  size_t numOutputNodes = session->GetOutputCount();
  for (int i = 0; i < numOutputNodes; i++) {
    auto output_name = session->GetOutputNameAllocated(i, allocator);
    outputNodeNameAllocatedStrings.push_back(std::move(output_name));
    output_names.emplace_back(outputNodeNameAllocatedStrings.back().get());
  }

  std::vector<Ort::Value> output_tensors = session->Run(
      Ort::RunOptions{nullptr}, input_names.data(), input_tensors.data(),
      input_tensors.size(), output_names.data(), output_names.size());
  auto *output = output_tensors[0].GetTensorMutableData<float>();

  std::ofstream("outputs/cc_output.bin", std::ios::binary).write(reinterpret_cast<const char*>(output), 160 * 4);
}
