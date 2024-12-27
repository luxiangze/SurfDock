FROM ubuntu:22.04

# Set environment variables
ENV LC_ALL=C \
    PATH=/opt/conda/bin:$PATH \
    PYTHONPATH=/opt/conda/lib/python3.10/site-packages:$PYTHONPATH

# Install system dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    wget \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh

# Set up conda environment
SHELL ["/bin/bash", "-c"]
RUN source /opt/conda/etc/profile.d/conda.sh && \
    conda create -y -n SurfDock python=3.10 && \
    conda activate SurfDock && \
    # Install PyTorch with CUDA support
    conda install -y pytorch==2.2.2 pytorch-cuda=12.1 -c pytorch -c nvidia && \
    # Install basic scientific packages
    conda install -y --channel=conda-forge --channel=pytorch --channel=pyg \
        numpy==1.24.4 \
        scipy==1.8.1 \
        pandas==2.1.2 \
        && conda clean -ya && \
    # Install molecular modeling packages
    conda install -y --channel=conda-forge --channel=pytorch --channel=pyg \
        openff-toolkit==0.15.2 \
        openmm==8.1.1 \
        openmmforcefields==0.12.0 \
        pdbfixer==1.9 \
        && conda clean -ya && \
    # Install additional dependencies
    conda install -y --channel=conda-forge --channel=pytorch --channel=pyg \
        babel==2.13.1 \
        biopandas==0.4.1 \
        openbabel==3.1.1 \
        plyfile==1.0.1 \
        prody==2.4.0 \
        torch-ema==0.3 \
        torchmetrics==1.2.1 \
        && conda clean -ya && \
    # Install PyG
    conda install -y pyg -c pyg && \
    pip install pyg_lib torch_scatter torch_sparse torch_cluster torch_spline_conv -f https://data.pyg.org/whl/torch-2.2.0+cu121.html && \
    # Install Python packages
    pip install -U --no-cache-dir \
        spyrmsd \
        scikit-learn==1.3.2 \
        accelerate==0.15.0 \
        biopython==1.79 \
        e3nn==0.5.1 \
        huggingface-hub==0.17.3 \
        mdanalysis==2.4.0 \
        posebusters==0.2.7 \
        rdkit==2023.3.1 \
        tokenizers==0.13.3 \
        transformers==4.29.2 \
        wandb==0.16.1 \
        pymesh \
        loguru \
        dimorphite_dl \
        prefetch_generator && \
    # Install PyMesh wheel
    pip install https://github.boki.moe/https://github.com/nuvolos-cloud/PyMesh/releases/download/v0.3.1/pymesh2-0.3.1-cp310-cp310-linux_x86_64.whl

# Install ESM
WORKDIR /opt
RUN git clone https://github.com/facebookresearch/esm && \
    cd esm && \
    pip install -e .

# Install additional dependencies for Masif & Data processing
RUN source /opt/conda/etc/profile.d/conda.sh && \
    conda activate SurfDock && \
    conda install -y mx::reduce conda-forge::openbabel

# Set working directory
WORKDIR /workspace

# Activate conda environment by default
RUN echo "source /opt/conda/etc/profile.d/conda.sh && conda activate SurfDock" >> ~/.bashrc

# Set default command
CMD ["/bin/bash"]

# Add labels
LABEL author="Duanhua Cao & Mingan Chen" \
      version="v1.0" \
      description="SurfDock container for protein-ligand complex prediction"
