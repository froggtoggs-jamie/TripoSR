# Use official PyTorch image with CUDA support (devel for build tools)
FROM pytorch/pytorch:2.1.0-cuda11.8-cudnn8-devel

# Set working directory
WORKDIR /app

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install system dependencies and build tools
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Upgrade setuptools as required by the project
RUN pip install --no-cache-dir --upgrade setuptools

# Install onnxruntime first (required by rembg)
RUN pip install --no-cache-dir onnxruntime

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
# Note: torchmcubes requires git and will be built with CUDA support if available
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire project
COPY . .

# Create output directory
RUN mkdir -p /app/output

# Expose port for Gradio app
EXPOSE 7860

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Default command runs the Gradio app
# Can be overridden to run inference with: docker run ... python run.py examples/chair.png
CMD ["python", "gradio_app.py", "--listen", "--port", "7860"]
