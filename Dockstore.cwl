#!/usr/bin/env cwl-runner

class: CommandLineTool
id: "GATK_joint_genotyping"
label: "Perform joint-genotyping of all samples per chromosome using GATK GenotypeGVCFs"
cwlVersion: v1.0
doc: |
    ![build_status](https://quay.io/repository/zek12/dockerized_gatk_pipeline/status)
    See the [dockerized_gatk_pipeline](https://github.com/zek12/dockerized_gatk_pipeline) website for more information.

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  s: http://schema.org/

$schemas:
- http://schema.org/docs/schema_org_rdfa.html
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf



dct:creator:
  "@id": "Ezequiel.Anokian@icr.ac.uk"
  foaf:name: Ezequiel Anokian
  foaf:mbox: "Ezequiel.Anokian@icr.ac.uk"

requirements:
  - class: DockerRequirement
    dockerPull: "quay.io/zek12/dockerized_gatk_pipeline:0.1.0"

hints:
  - class: ResourceRequirement
    coresMin: 1 # all processes are single threaded
    ramMin: 8000

inputs:

  path_to_gvcfs:
    type: Directory
    doc: "path where the gvcfs are located"
    inputBinding:
      position: 1
      shellQuote: true

  chr:
    type: string
    doc: "chromosome for which to perform the joint-genotyping"
    inputBinding:
      position: 2
      shellQuote: true

  path_logs:
    type: Directory
    doc: "path where to save the log files"
    inputBinding:
      position: 3
      shellQuote: true

  path_output:
    type: Directory
    doc: "path where to save the output VCF"
    inputBinding:
      position: 4
      shellQuote: true

  mem:
    type: int
    doc: "number of GBs for max memory of Java processes to use. Default: 32GB."
    default: 32
    inputBinding:
      position: 5

  gatk_ref_bundle_gzipped_dbsnp:
    type: File
    doc: "gzipped Mills and 1000G golden standard indels vcf file from GATK reference bundle. Use Mills_and_1000G_gold_standard.indels.b37.vcf.gz. It can be downloaded from ftp://ftp.broadinstitute.org/bundle/, username: gsapubftp-anonymous, no password"
    inputBinding:
      position: 6
      shellQuote: true



outputs:

  vcf:
    type: File
    format: "http://edamontology.org/format_3016"
    outputBinding:
      glob: $(inputs.path_output)/joint_chr$(inputs.chr).vcf

  log:
    type: File
    outputBinding:
      glob: $(inputs.path_logs)/log.log

  finished1:
    type: File
    outputBinding:
      glob: $(inputs.path_logs)/part_3_GenotypeGVCFs_finished_chr$(inputs.chr).txt

  finished2:
    type: File
    outputBinding:
      glob: $(inputs.path_logs)/part_3_joint_validation_finished_chr$(inputs.chr).txt


baseCommand: ["part3_joint_genotyping.sh"]

s:codeRepository: https://github.com/zek12/dockerized_gatk_pipeline
s:author:
  - class: s:Person
    s:email: mailto:Ezequiel.Anokian@icr.ac.uk
    s:name: Ezequiel Anokian