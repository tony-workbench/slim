FROM python:3.10-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc g++ git curl \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir --upgrade pip setuptools wheel

COPY requirements.txt .

# Install torch first so flash-attn's build can import it
RUN pip install --no-cache-dir torch==2.7.1

# Install the other requirements; flash-attn is left out here and tried below
RUN grep -v "^flash-attn" requirements.txt > /tmp/req.txt && \
    pip install --no-cache-dir -r /tmp/req.txt

# Try flash-attn last (often fails on CPU-only)
RUN pip install --no-cache-dir flash-attn || true

COPY . .

ENV PORT=8080
EXPOSE 8080
CMD ["sh", "-c", "uvicorn app:app --host 0.0.0.0 --port ${PORT:-8080}"]
