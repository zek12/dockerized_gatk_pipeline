#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "GATK_joint_genotyping"

label: "Perform joint-genotyping of all samples per chromosome using GATK GenotypeGVCFs"

cwlVersion: v1.0

doc: |
    ![build_status](https://quay.io/repository/zek12/dockerized_gatk_pipeline/status)
    See the [dockerized_gatk_pipeline](https://github.com/zek12/dockerized_gatk_pipeline) website for more information.

$schemas:
- http://schema.org/docs/schema_org_rdfa.html
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf


dct:creator:
  "@id": "Ezequiel.Anokian@icr.ac.uk"
  foaf:name: Ezequiel Anokian
  foaf:mbox: "mailto:Ezequiel.Anokian@icr.ac.uk"



requirements:
  - class: DockerRequirement
    dockerPull: "quay.io/zek12/dockerized_gatk_pipeline:0.2.0"

hints:
  - class: ResourceRequirement
    coresMin: 1 # all processes are single threaded
    ramMin: 8000

inputs:

  path_to_gvcfs:
    type: Directory
    doc: "path where the gvcfs are located. All indexes must be located here!!!"
    inputBinding:
      position: 1
      shellQuote: true

  chr:
    type: string
    doc: "chromosome for which to perform the joint-genotyping"
    inputBinding:
      position: 2
      shellQuote: true



  mem:
    type: int
    doc: "number of GBs for max memory of Java processes to use. Default: 32"
    default: 32
    inputBinding:
      position: 3

  ref_genome:
    type: File
    doc: "reference genome files (.fa and .dict) in tar. Default: http://ftp.sanger.ac.uk/pub/cancer/dockstore/human/core_ref_GRCh37d5.tar.gz"
    default: "http://ftp.sanger.ac.uk/pub/cancer/dockstore/human/core_ref_GRCh37d5.tar.gz"
    inputBinding:
      position: 4
      shellQuote: true

  exclude:
    type: File
    doc: "A txt file with the gvcfs to exclude (bad samples) from the joint genotyping. Samples have to be one per line and ending with .g.vcf.gz"
    inputBinding:
      position: 5
      shellQuote: true


outputs:

  vcf:
    type: File
    format: "http://edamontology.org/format_3016"
    outputBinding:
      glob: joint_chr$(inputs.chr).vcf




baseCommand: ["/opt/part3_joint_genotyping.sh"]


$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  s: http://schema.org/

s:codeRepository: https://github.com/zek12/dockerized_gatk_pipeline
s:author:
  - class: s:Person
    s:email: mailto:Ezequiel.Anokian@icr.ac.uk
    s:name: Ezequiel Anokian

