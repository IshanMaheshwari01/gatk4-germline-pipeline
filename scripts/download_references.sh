#!/bin/bash
set -e

REF_DIR="$(cd "$(dirname "$0")/../test_data/references" && pwd)"
mkdir -p "$REF_DIR"
cd "$REF_DIR"

echo "=========================================="
echo "Downloading GATK Reference Data"
echo "Target: $REF_DIR"
echo "=========================================="

# 1. Download hg38 from UCSC and extract chr21
if [ ! -f "Homo_sapiens_assembly38.chr21.fa" ]; then
    echo "[1/6] Downloading hg38 reference genome..."
    wget -q --show-progress http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz
    echo "[2/6] Extracting chromosome 21..."
    gunzip -c hg38.fa.gz | awk '/^>chr21$/{p=1} /^>chr[0-9XYM]/{if($0!~/^>chr21$/){p=0}} p' > Homo_sapiens_assembly38.chr21.fa
    rm hg38.fa.gz
else
    echo "[1-2/6] Reference FASTA already exists, skipping..."
fi

# 2. Index reference
if [ ! -f "Homo_sapiens_assembly38.chr21.fa.fai" ]; then
    echo "[3/6] Indexing FASTA..."
    samtools faidx Homo_sapiens_assembly38.chr21.fa
else
    echo "[3/6] FASTA index already exists, skipping..."
fi

# 3. BWA index
if [ ! -f "Homo_sapiens_assembly38.chr21.fa.bwt" ]; then
    echo "[4/6] Creating BWA index (this takes ~2 minutes)..."
    bwa index Homo_sapiens_assembly38.chr21.fa
else
    echo "[4/6] BWA index already exists, skipping..."
fi

# 4. Sequence dictionary
if [ ! -f "Homo_sapiens_assembly38.chr21.dict" ]; then
    echo "[5/6] Creating sequence dictionary..."
    docker run --rm -v "$REF_DIR:/data" -u $(id -u):$(id -g) broadinstitute/gatk:4.5.0.0 \
        gatk CreateSequenceDictionary -R /data/Homo_sapiens_assembly38.chr21.fa -O /data/Homo_sapiens_assembly38.chr21.dict
else
    echo "[5/6] Sequence dictionary already exists, skipping..."
fi

# 5. Known sites for BQSR (from DDBJ mirror)
if [ ! -f "Mills_and_1000G_gold_standard.indels.hg38.chr21.vcf.gz" ]; then
    echo "[6/6] Downloading Mills & 1000G indels..."
    wget -q --show-progress https://ddbj.nig.ac.jp/public/public-human-genomes/GRCh38/fasta/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
    mv Mills_and_1000G_gold_standard.indels.hg38.vcf.gz Mills_and_1000G_gold_standard.indels.hg38.chr21.vcf.gz
    wget -q --show-progress https://ddbj.nig.ac.jp/public/public-human-genomes/GRCh38/fasta/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi
    mv Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi Mills_and_1000G_gold_standard.indels.hg38.chr21.vcf.gz.tbi
else
    echo "[6/6] Known sites already exist, skipping..."
fi

echo ""
echo "=========================================="
echo "Download Complete!"
echo "=========================================="
ls -lh "$REF_DIR"
