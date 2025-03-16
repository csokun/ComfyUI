FROM nvidia/cuda:12.6.3-base-ubuntu22.04
ENV DEBIAN_FRONTEND noninteractive
ENV CMDARGS --listen

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y curl wget libgl1 libglib2.0-0 python3-pip python-is-python3 git \
    ffmpeg libx264-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# perftools
RUN apt-get update && apt-get install --no-install-recommends -y google-perftools

RUN apt-get install -y libcudnn8

RUN apt-get install libgl1-mesa-glx -y

# Install under /root/.local
ENV PIP_USER="true"
ENV PIP_NO_WARN_SCRIPT_LOCATION=0
ENV PIP_ROOT_USER_ACTION="ignore"

RUN --mount=type=cache,target=/root/.cache \
    pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu126

WORKDIR /app

COPY requirements.txt requirements_docker.txt ./
RUN --mount=type=cache,target=/root/.cache \
    pip install -r requirements_docker.txt -r requirements.txt

# ref. https://github.com/microsoft/onnxruntime/issues/21684
# Failed to load library libonnxruntime_providers_cuda.so with error: libcudnn_adv.so.9: cannot open shared object file: No such file or directory
RUN --mount=type=cache,target=/root/.cache \
    pip uninstall -y onnxruntime onnxruntime-gpu && \
    pip install onnxruntime-gpu==1.18.1 --extra-index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/onnxruntime-cuda-12/pypi/simple/

# Janus-pro
RUN python3 -m pip install --upgrade pip
RUN --mount=type=cache,target=/root/.cache \
    pip install git+https://github.com/deepseek-ai/Janus.git

COPY . .

CMD ["python", "main.py", "--listen", "--lowvram"]
