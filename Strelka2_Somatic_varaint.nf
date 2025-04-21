nextflow.enable.dsl = 2

params {
    read_dir = "Patients"
    reference = "ref/hg38.fa"
    adapters = "Adapt/adapters.fa"
}

workflow {
    get_samples(params.read_dir) | trim_reads | fastqc | align_and_call
}

process get_samples {
    input:
    val folder_path from Channel.fromPath("${params.read_dir}/*").filter { it.isDirectory()}
}

    output:
    tuple val(folder_path.getName()),
    path("${folder_path}/*_tumor_R1.fastq.gz"),
    path("${folder_path}/*_tumor_R2.fastq.gz"),
    path("${folder_path}/*_normal_R1.fastq.gz"),
    path("${folder_path}/*_normal_R2.fastq.gz")

    script:
    """
    echo "Collecting sample: ${folder_path.getName()}"
    """
}

process trim_reads {
    tag "$sample_id"

    input:
    tuple val(sample_id),path(tumor_r1),path(tumor_r2),path(normal_r1), path(normal_r2)

    output:
    tuple val(sample_id),
          path("trimmed_tumor_R1.fq.gz"),
          path("trimmed_tumor_R2.fq.gz"),
          path("trimmed_normal_R1.fq.gz"),
          path("trimmed_normal_R2.fq.gz")
    
    script:
    """
    trim_galore --paired $tumor_r1 $tumor_r2 -o . --basename trimmed_tumor
    trim_galore --paired $normal_r1 $normal_r2 -o . --basename trimmed_normal
    """
}

process fastqc {
    tag "$sample_id"

    input:
    tuple val(sample_id),
          path(tumor_r1), path(tumor_r2),
          path(normal_r1), path(normal_r2)

    output:
    tuple val(sample_id),path(tumor_r1), path(tumor_r2), path(normal_r1), path(normal_r2)

    script:
    """
    fastqc $tumor_r1 $tumor_r2 $normal_r1 $normal_r2
    """
}

process align_and_call {
    tag "$sample_id"

    input:
    tuple val(sample_id), path(tumor_r1), path(tumor_r2), path(normal_r1), path(normal_r2)

    output:
    path("${sample_id}_strelka_results")

    script:
    """
    mkdir -p ${sample_id}_work

    #BWA alignment
    bwa mem -R "@RG\\tID:${sample_id}_tumor\\tSM:${sample_id}_tumor\\tPL:ILLUMINA" ${params.reference} $tumor_r1 $tumor_r2 | samtools sore -o ${sample_id}_work/tumor.bam"
    bwa mem -R "@RG\\tID:${sample_id}_normal\\tSM:${sample_id}_normal\\tPL:ILLUMINA" ${params.reference} $normal_r1 $normal_r2 | samtools sort -o ${sample_id}_work/normal.bam
    samtools index ${sample_id}_work/tumor.bam
    samtools index ${sample_id}_work/normal.bam

    #Configure Strelka2
    configureStrelkaSomaticWorkflow.py \
        --normalBam ${sample_id}_work/normal.bam \
        --tumorBam ${sample_id}_work/tumor.bam \
        --referenceFasta ${params.reference} \
        --runDir ${sample_id}_work/strelka

    #Run Strelka2
    ${sample_id}_work/strelka/runWorkflow.py -m local -j 8

    mv ${sample_id}_work/strelka/results ${sample_id}_strelka_results
    “”“
}




