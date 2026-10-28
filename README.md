# SLiM

SLiM compresses large language models in one shot by combining pruning, quantization and a low-rank correction, with no retraining.
SLiM is by Mohammad Mozaffari, Amir Yazdanbakhsh and Maryam Mehri Dehnavi. This repository is based on the [original SLiM repository](https://github.com/Paramathic/slim) and adds a `Dockerfile` and a small FastAPI health endpoint (`app.py`) so the project can be built and checked as a container.

## What you need

- Python 3.10
- Linux with an NVIDIA GPU and CUDA, to compress models
- Docker, to build and run the container

## Steps

1. Clone the repository and install the dependencies.

   ```bash
   git clone https://github.com/tony-workbench/slim.git
   cd slim
   python3.10 -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

2. Compress a model. This prunes OPT-125M to 2:4 sparsity, quantizes the weights to 4 bits, adds a low-rank correction, prints the WikiText2 perplexity and saves the result in `checkpoints/opt-125m-slim`. The model and datasets download from Hugging Face on the first run.

   ```bash
   export HF_DATASETS_TRUST_REMOTE_CODE=1
   python main.py \
       --model facebook/opt-125m \
       --prune_method wanda \
       --sparsity_ratio 0.5 \
       --sparsity_type 2:4 \
       --quantize_weight \
       --slim_quant \
       --bitwidth 4 \
       --lora_rank 0.1 \
       --slim_lora \
       --evaluate_perplexity \
       --save_checkpoint_path checkpoints/opt-125m-slim
   ```

   For every option, see `scripts/run.sh` and the original README.

## Health check

1. Build the image. It is large because it includes PyTorch and vLLM. On an Apple Silicon Mac, add `--platform linux/amd64`.

   ```bash
   docker build -t slim .
   ```

2. Start the container.

   ```bash
   docker run -d --name slim -p 8080:8080 slim
   ```

3. Check the endpoint. It returns `{"status":"ok"}`.

   ```bash
   curl http://localhost:8080/
   ```

4. Stop and remove the container.

   ```bash
   docker rm -f slim
   ```

Without Docker, run `pip install fastapi "uvicorn[standard]"`, then `uvicorn app:app --port 8080`, and use the same `curl` command.

## Links

- [Original SLiM repository](https://github.com/Paramathic/slim) and its [README](https://github.com/Paramathic/slim#readme): full options, results, method details and the BibTeX citation
- Paper: [SLiM: One-shot Quantized Sparse Plus Low-rank Approximation of LLMs](https://arxiv.org/abs/2410.09615) (ICML 2025)
- The code builds on [SparseGPT](https://github.com/IST-DASLab/sparsegpt) and [Wanda](https://github.com/locuslab/wanda)
- License: [MIT](LICENSE)
