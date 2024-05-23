# Nvidia Cuda Image
FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

# Define arguments
ARG HUGGING_FACE_TOKEN
ARG PY_VERSION=3.11.6

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
RUN  pip install --upgrade huggingface_hub
RUN huggingface-cli login --token ${HUGGING_FACE_TOKEN}

RUN poetry install --extras "ui vector-stores-qdrant llms-ollama embeddings-huggingface llms-llama-cpp"

RUN poetry run python scripts/setup

# Make run
ENTRYPOINT make run
EXPOSE 8001