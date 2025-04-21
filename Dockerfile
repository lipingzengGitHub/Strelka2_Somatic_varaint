# Use an official Ubuntu image as a base
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update and install dependencies
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y \
    bwa \
    samtools \
    fastqc \
    python3 \
    python3-pip \
    git \
    curl \
    zlib1g-dev \
    gcc \
    g++ \
    make \
    && apt-get clean

# Install Trim Galore! (via conda)
RUN curl -sSL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p /opt/conda \
    && rm /tmp/miniconda.sh \
    && /opt/conda/bin/conda install -y -c bioconda trim-galore

# Install Strelka2 (via GitHub release)
RUN git clone https://github.com/Illumina/strelka.git /opt/strelka \
    && cd /opt/strelka \
    && python3 setup.py install

# Add the conda binary folder to PATH
ENV PATH /opt/conda/bin:$PATH
ENV PATH /opt/strelka/bin:$PATH

# Set work directory
WORKDIR /data

# Set the entry point for the container (can be modified as needed)
ENTRYPOINT ["bash"]


