# ==============================================================================
# Vertex AI GNN Custom Container Serving Dockerfile
# ==============================================================================

# Use a lightweight official Python slim image as our foundation
FROM python:3.11-slim

# Prevent Python from writing .pyc files and enable unbuffered output logging
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8080

WORKDIR /app

# Install system dependencies needed for compiling light python modules
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install CPU-optimized PyTorch directly to reduce image size (bypasses heavy CUDA runtimes)
RUN pip3 install --no-cache-dir torch torchvision --index-url https://download.pytorch.org/whl/cpu

# Install Pure-Python PyTorch Geometric and FastAPI Serving packages
# NOTE: Modern torch-geometric package operates 100% out-of-the-box on pure python.
# We do NOT require native C++ compilers like torch-scatter or torch-sparse for standard GCN convolved layers.
RUN pip3 install --no-cache-dir \
    torch-geometric \
    fastapi \
    uvicorn \
    pydantic

# Copy GNN model structure and training scripts
COPY model.py /app/model.py
COPY train.py /app/train.py

# Execute GNN convolved training inside the container during image build
# This generates model.pt and metadata.json directly inside the target artifacts directory in the cloud build context,
# meaning the host local machine requires zero local Docker, PyTorch, or PyG dependencies!
RUN python3 /app/train.py

# Copy custom prediction server script
COPY serve.py /app/serve.py

# Expose standard container port 8080 (Vertex AI default serving gateway)
EXPOSE 8080

# Launch Uvicorn server binding to Port 8080
CMD ["uvicorn", "serve:app", "--host", "0.0.0.0", "--port", "8080"]
