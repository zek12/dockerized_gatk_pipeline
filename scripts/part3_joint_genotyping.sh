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
path_logs="."
path_output_vcf="."
mem=$3 # = 32
ref_genome=$4
exclude=$5

# remove last slash in input dirs if they end with slash
path_to_gvcfs=${path_to_gvcfs%/}


gatk_ref_bundle_dbsnp="/opt/dbsnp_138.b37.vcf.gz"
logfile=${path_logs}/log.log


# exclude bad samples
# ls -1a $path_to_gvcfs/*.g.vcf.gz | sed -e 's/.*\///g' | sed -e 's/\..*//g' > all_samples.txt
ls -1a $path_to_gvcfs/*.g.vcf.gz | sed -e 's/.*\///g' > all_samples.txt
grep -F -x -v -f $exclude all_samples.txt > passed.txt


# prepare ref genome
mkdir -p ref
tar xzf $ref_genome -C ref --strip-components 1
# path_ref=ref/genome.fa
path_ref=$(find ref -name *.fa) # ref/genome.fa
path_dict=$(find ref -name *.dict) # ref/genome.fa.dict
new_name=$(echo "${path_ref/\.fa/\.dict}")
cp $path_dict $new_name




this_gatk="java -Xmx${mem}g -Djava.io.tmpdir=/tmp -Djava.library.path=/tmp -jar /opt/GenomeAnalysisTK.jar -R $path_ref"




####################################################
# Joint Genotyping - GenotypeGVCFs
####################################################

if [ ! -f $path_logs/part_3_GenotypeGVCFs_finished_chr$chr.txt ]; then

	echo "$(date '+%d/%m/%y_%H:%M:%S'),---Starting GenotypeGVCFs: joint genotyping of chromosome $chr---" >> "$logfile"

	# gvcf_paths=$(ls $path_to_gvcfs/*.g.vcf.gz)
	# gvcf_array=$(for i in $gvcf_paths; do echo "--variant $i"; done)
	gvcf_paths=$(cat passed.txt)
	gvcf_array=$(for i in $gvcf_paths; do echo "--variant $path_to_gvcfs/$i"; done)

	time ($this_gatk \
	-T GenotypeGVCFs \
	--dbsnp $gatk_ref_bundle_dbsnp \
	${gvcf_array[@]} \
	-L $chr \
	-newQual \
	--disable_auto_index_creation_and_locking_when_reading_rods \
	-o $path_output_vcf/joint_chr$chr.vcf )

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
	-V $path_output_vcf/joint_chr$chr.vcf \
	--validationTypeToExclude ALL \
	) >> "$logfile"

	echo "$(date '+%d/%m/%y_%H:%M:%S'), Validation of VCF chromosome $chr completed">> "$logfile" \
	&& touch $path_logs/part_3_joint_validation_finished_chr$chr.txt

else
	echo "$(date '+%d/%m/%y_%H:%M:%S'),***Skipping VCF validation on chromosome $chr since it was previously computed***" >> "$logfile"
fi

