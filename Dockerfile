FROM nvidia/cuda:12.4.1-base-ubuntu22.04
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

RUN --mount=type=cache,target=/root/.cache \
	pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu126

WORKDIR /app

COPY requirements.txt requirements_docker.txt ./
RUN --mount=type=cache,target=/root/.cache \
	pip install -r requirements_docker.txt -r requirements.txt

RUN --mount=type=cache,target=/root/.cache \
	pip uninstall -y onnxruntime onnxruntime-gpu && \
	pip install onnxruntime-gpu --extra-index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/onnxruntime-cuda-12/pypi/simple/

COPY . .

CMD ["python", "main.py", "--listen", "--lowvram"]
