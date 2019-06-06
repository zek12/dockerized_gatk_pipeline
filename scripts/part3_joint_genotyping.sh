#!/bin/bash

set -xueo pipefail

###########################################################################################################################################################
# PART 3: Joint-genotyping
###########################################################################################################################################################
# - Joint-genotyping of all samples per chromosome (joint_chr1.vcf, joint_chr2.vcf, ..., joint_chr22.vcf, joint_chrX.vcf, joint_chrY.vcf, joint_chrMT.vcf)
# - validate variants
###########################################################################################################################################################

path_to_gvcfs=$1
chr=$2 # 1, 2, ..., 22, X, Y, MT
path_logs=$3
path_output=$4
mem=$5 # = 32
gatk_ref_bundle_gzipped_dbsnp=$6 # $bundle2_8/b37/dbsnp_138.b37.vcf

path_ref=ref/genome.fa
this_gatk="java -Xmx${mem}g -Djava.io.tmpdir=/tmp -Djava.library.path=/tmp -jar /opt/GenomeAnalysisTK.jar -R $path_ref"
logfile=${path_logs}/log.log

mkdir -p $path_logs
mkdir -p $path_output

gatk_ref_bundle_dbsnp="gatk_bundle/gatk_ref_bundle_dbsnp.vcf"
gunzip -c $gatk_ref_bundle_gzipped_dbsnp > $gatk_ref_bundle_dbsnp





####################################################
# Joint Genotyping - GenotypeGVCFs
####################################################

if [ ! -f $path_logs/part_3_GenotypeGVCFs_finished_chr$chr.txt ]; then

	echo "$(date '+%d/%m/%y_%H:%M:%S'),---Starting GenotypeGVCFs: joint genotyping of chromosome $chr---" >> "$logfile"

	gvcf_paths=$(ls $path_to_gvcfs/*.g.vcf.gz)
	gvcf_array=$(for i in $gvcf_paths; do echo "--variant $i"; done)

	time ($this_gatk \
	-T GenotypeGVCFs \
	--dbsnp $gatk_ref_bundle_dbsnp \
	${gvcf_array[@]} \
	-L $chr \
	-newQual \
	--disable_auto_index_creation_and_locking_when_reading_rods \
	-o $path_output/joint_chr$chr.vcf )

	# added -newQual
	# if the previous command gives an error, try:
	# - removing -nt 16 \ Da error MESSAGE: Code exception (see stack trace for error itself)
	# - extracting .g.vcf.gz to .g.vcf

	echo "$(date '+%d/%m/%y_%H:%M:%S'),Finished GenotypeGVCFs of chromosome $chr" >> "$logfile" \
	&& touch $path_logs/part_3_GenotypeGVCFs_finished_chr$chr.txt
	
else
	echo "$(date '+%d/%m/%y_%H:%M:%S'),***Skipping GenotypeGVCFs of chromosome $chr since it was previously computed***" >> "$logfile"
fi




####################################################
# Check the validity of the vcf file
####################################################


if [ ! -f $path_logs/part_3_joint_validation_finished_chr$chr.txt ]; then

	echo "$(date '+%d/%m/%y_%H:%M:%S'),---Validating joint VCF on chromosome $chr---" >> "$logfile"

	time ($this_gatk \
	-T ValidateVariants \
	-V $path_output/joint_chr$chr.vcf \
	--validationTypeToExclude ALL \
	) >> "$logfile"

	echo "$(date '+%d/%m/%y_%H:%M:%S'), Validation of VCF chromosome $chr completed">> "$logfile" \
	&& touch $path_logs/part_3_joint_validation_finished_chr$chr.txt

else
	echo "$(date '+%d/%m/%y_%H:%M:%S'),***Skipping VCF validation on chromosome $chr since it was previously computed***" >> "$logfile"
fi

