# Сборка ClickHouse с PDX-индексом + стенд для экспериментов.
# docker build -t pdx-ch .
# docker run --rm -it pdx-ch clickhouse local -q "select version()"

FROM ubuntu:24.04 AS build

ARG BRANCH=pdx-s3

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    build-essential git cmake ninja-build ccache python3 nasm yasm gawk \
    wget lsb-release software-properties-common gnupg \
    && wget -qO- https://apt.llvm.org/llvm.sh | bash -s -- 21 \
    && rm -rf /var/lib/apt/lists/*

# как в docs: shallow clone + сабмодули через скрипт из репы
RUN git clone --depth 1 --branch $BRANCH https://github.com/arnmacing/ClickHouse.git /ClickHouse \
    && cd /ClickHouse && ./contrib/update-submodules.sh

WORKDIR /ClickHouse
ENV CC=clang-21 CXX=clang++-21 CCACHE_DIR=/ccache
RUN --mount=type=cache,target=/ccache \
    cmake -S . -B build -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_PDX=ON -DENABLE_RUST=OFF -DENABLE_TESTS=OFF \
        -DCOMPILER_CACHE=ccache \
    && ninja -C build clickhouse


FROM ubuntu:24.04

RUN apt-get update && apt-get install -y python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /ClickHouse/build/programs/clickhouse /usr/bin/clickhouse

COPY bench /bench
RUN pip3 install --break-system-packages -r /bench/requirements.txt

WORKDIR /bench
