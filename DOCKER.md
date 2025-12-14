# Docker Setup for TripoSR

This guide explains how to build and run TripoSR using Docker.

## Prerequisites

- Docker (version 20.10 or higher)
- Docker Compose (version 1.29 or higher)
- NVIDIA Docker runtime (for GPU acceleration)
  - Install from: https://github.com/NVIDIA/nvidia-docker

### Verify NVIDIA Docker Runtime

```bash
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

## Quick Start

### Using Docker Compose (Recommended)

1. Build and start the Gradio web interface:
```bash
docker-compose up --build
```

2. Open your browser and navigate to:
```
http://localhost:7860
```

3. To stop the container:
```bash
docker-compose down
```

### Using Docker CLI

#### Build the Image

```bash
docker build -t triposr:latest .
```

#### Run the Gradio App

```bash
docker run --gpus all -p 7860:7860 -v $(pwd)/output:/app/output triposr:latest
```

Then open http://localhost:7860 in your browser.

#### Run Inference on Command Line

```bash
docker run --gpus all -v $(pwd)/output:/app/output triposr:latest \
  python run.py examples/chair.png --output-dir /app/output
```

## Advanced Usage

### CPU-Only Mode

If you don't have a GPU, you can run in CPU mode (much slower):

```bash
docker run -p 7860:7860 -v $(pwd)/output:/app/output triposr:latest
```

### Custom Input Images

Mount your local images directory:

```bash
docker run --gpus all \
  -v $(pwd)/my-images:/app/my-images \
  -v $(pwd)/output:/app/output \
  triposr:latest \
  python run.py /app/my-images/myimage.png --output-dir /app/output
```

### Bake Texture Output

To generate textured models instead of vertex colors:

```bash
docker run --gpus all -v $(pwd)/output:/app/output triposr:latest \
  python run.py examples/chair.png --output-dir /app/output \
  --bake-texture --texture-resolution 2048
```

### Batch Processing

Process multiple images:

```bash
docker run --gpus all -v $(pwd)/output:/app/output triposr:latest \
  python run.py examples/chair.png examples/horse.png examples/teapot.png \
  --output-dir /app/output
```

### Interactive Shell

To access the container shell for debugging:

```bash
docker run --gpus all -it -v $(pwd)/output:/app/output \
  triposr:latest /bin/bash
```

## Configuration Options

### Environment Variables

You can pass environment variables to customize behavior:

```bash
docker run --gpus all \
  -e CUDA_VISIBLE_DEVICES=0 \
  -p 7860:7860 \
  triposr:latest
```

### Memory Requirements

The default configuration requires about 6GB of VRAM. If you have limited VRAM, you can reduce the chunk size:

```bash
docker run --gpus all -v $(pwd)/output:/app/output triposr:latest \
  python run.py examples/chair.png --chunk-size 4096 --output-dir /app/output
```

### Docker Compose Customization

Edit `docker-compose.yml` to customize:
- Port mappings
- Volume mounts
- GPU allocation
- Environment variables

## Troubleshooting

### GPU Not Detected

If you get CUDA errors:
1. Verify NVIDIA drivers are installed: `nvidia-smi`
2. Verify Docker can access GPU: `docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi`
3. Ensure NVIDIA Container Toolkit is installed

### Out of Memory

Reduce the chunk size or marching cubes resolution:
```bash
docker run --gpus all -v $(pwd)/output:/app/output triposr:latest \
  python run.py examples/chair.png \
  --chunk-size 4096 \
  --mc-resolution 128 \
  --output-dir /app/output
```

### Gradio Connection Issues

If you can't access the Gradio interface:
- Check if the port is already in use
- Try mapping to a different port: `-p 8080:7860`
- Ensure firewall allows the connection

### Build Failures

If the build fails:
1. Ensure you have enough disk space
2. Try building with no cache: `docker build --no-cache -t triposr:latest .`
3. Check your internet connection for downloading dependencies

## Model Download

The first time you run the container, it will download the pretrained model from Hugging Face (approximately 1.5GB). This may take several minutes depending on your internet connection.

## Performance Notes

- GPU mode: ~0.5 seconds per image on NVIDIA A100
- CPU mode: Significantly slower, may take minutes per image
- Memory usage: ~6GB VRAM with default settings
- First run includes model download time

## Cleaning Up

Remove containers and images:
```bash
# Stop and remove containers
docker-compose down

# Remove the image
docker rmi triposr:latest

# Clean up Docker system
docker system prune -a
```
