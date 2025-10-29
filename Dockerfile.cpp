FROM ubuntu:22.04

# install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    wget \
    git \
		zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# copy project files
COPY CMakeLists.txt main.cc configure.sh build.sh model.bin input.bin ./

# note: you'll need to provide onnxruntime library
# see step 3 below for obtaining it
COPY onnxruntime ./onnxruntime

# make scripts executable
RUN chmod +x configure.sh build.sh

# build the project
RUN ./configure.sh && ./build.sh

# run the executable
CMD ["./build/problem"]
