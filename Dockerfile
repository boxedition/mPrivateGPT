# Nvidia Cuda Image
FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

# Add CUDA to PATH and LD_LIBRARY_PATH
ENV PATH="/usr/local/cuda-12.4/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda-12.4/lib64:${LD_LIBRARY_PATH}"

# Define arguments
ARG HUGGING_FACE_TOKEN
ARG PY_VERSION

# Update and install dependencies
RUN apt update && apt install -y \
        git \
        make \
        curl \
        build-essential \
        zlib1g-dev \
        libssl-dev \
        libsqlite3-dev \
        libbz2-dev \
        libreadline-dev \
        libffi-dev \
        liblzma-dev

# Install pyenv
RUN git clone https://github.com/pyenv/pyenv.git .pyenv
ENV PYENV_ROOT="${HOME}/.pyenv"
# Add PyEnv to PATH
ENV PATH="$PYENV_ROOT/bin:$PATH"

# Install Python based of PY_VERSION
RUN pyenv install ${PY_VERSION}
RUN pyenv global ${PY_VERSION}
ENV PATH="$PYENV_ROOT/versions/${PY_VERSION}/bin:$PATH"

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:$PATH"


# Clone Private GPT
RUN git clone https://github.com/zylon-ai/private-gpt /app
WORKDIR /app

# HuggingFace Login (required to download Mistral)
RUN pip install --upgrade huggingface_hub && huggingface-cli login --token ${HUGGING_FACE_TOKEN}

# Install dependencies
RUN poetry install --extras "ui vector-stores-qdrant llms-ollama embeddings-huggingface llms-llama-cpp"
RUN poetry run python scripts/setup

# Activate GPU
# RUN CUDACXX='/usr/local/cuda-12/bin/nvcc' CMAKE_ARGS='-DLLAMA_CUBLAS=on' poetry run pip install --force-reinstall --no-cache-dir llama-cpp-python

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 8001
