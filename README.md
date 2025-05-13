### Strelka2 Somatic Variant Calling Pipeline
This pipeline performs somatic variant calling using Strelka2 from tumor-normal paired whole genome sequencing (WGS) data, using Nextflow and Docker for reproducibility and scalability.

###Directory Structure
project/
├── Dockerfile
├── README.md
├── Strelka2_Somatic_variant.nf
├── nextflow.config
└── data/
    ├── patient1/
    │   ├── tumor_R1.fastq.gz
    │   ├── tumor_R2.fastq.gz
    │   ├── normal_R1.fastq.gz
    │   └── normal_R2.fastq.gz
    └── ...

### How to Run
1. Install Nextflow:
curl -s https://get.nextflow.io | bash

2. Clone the repository and change into the directory:
git clone https://github.com/lipingzengGitHub/Strelka2_Somatic_varaint.git
cd Strelka2_Somatic_varaint

3. Run the pipeline:
nextflow run Strelka2_Somatic_variant.nf -profile docker

### Input Requirements:
Each patient’s data must be in a separate folder under data/

Each folder must contain these 4 files:
tumor_R1.fastq.gz
tumor_R2.fastq.gz
normal_R1.fastq.gz
normal_R2.fastq.gz

### Output
Results will be saved under results/ folder per sample

Strelka2 output includes:

somatic.indels.vcf.gz

somatic.snvs.vcf.gz



