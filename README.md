# Dockerised GATK pipeline

Dockerised version of Ezequiel Anokian's GATK pipeline for germline variants analysis. For pipeline's details please contact: Ezequiel.Anokian@icr.ac.uk

## Packaged tool versions

* **Java:** `1.8.0_212`
* **GATK:** `v3.7-0-gcfedb67`
* **Picardtools:** `2.0.1` (built with `htsjdk-2.0.1`)
* **VerifyBamID:** `1.1.2`
* **samtools:** `1.7.1`
* **R:** `3.6.0 (2019-04-26)` with packages below:
  * ggplot2: `3.1.1`
  * gplots: `3.0.1`
  * gsalib: `2.1`
  * reshape `0.8.8`
  And their dependencies.


## Packaged CWL tool

### Parts 1 & 2: bam_to_vcf

It produces various quality metrics from the input BAM, clean the BAM file and fix mate info of it, then recalibrates the BAM and generates a gzip GVCF file from it.

Details of inputs and outputs are in `cwl/bam_to_gvcf.json`.

***Note:*** Only BAM recalibration and HaplotypCaller support multiple threading, 8 cores should be enough for most of cases. Set a sensible amount of RAM accordingly.

### Part 3: joint-genotyping

Performs joint-genotyping of all samples per chromosome using `GATK GenotypeGVCFs`. Excludes samples in the `exclude` file, which must be filled in according to the following failing BAM QC metrics:
* Insert size metrics: insert size has to be >= 250 bp.
  * Check in file **sample.multiple_metrics.insert_size_metrics**, column MEAN_INSERT_SIZE, where READ_GROUP = "".
* GC bias: AT_DROPOUT and GC_DROPOUT must be <= 5%.
  * Check in file **sample.multiple_metrics.gc_bias.summary_metrics**, columns AT_DROPOUT and GC_DROPOUT, where ACCUMULATION_LEVEL = "Sample".
* Alignment metrics: PCT_PF_READS_ALIGNED has to be >= 95%, and PF_MISMATCH_RATE must be <= 5%.
  * Check in file **sample.multiple_metrics.alignment_summary_metrics**, columns PCT_PF_READS_ALIGNED and PF_MISMATCH_RATE, where CATEGORY != "UNPAIRED".
* Coverage: percentage of genome with at least 20X coverage must be >= 80%.
  * Check in file **sample.wgs_metrics.txt**, column PCT_20X.
* Contamination: sample contamination has to be <= 3%.
  * Check in file **sample.VerifyBamID.selfSM**, column FREEMIX.


Details of inputs and outputs are in `Dockstore.json`.

