#!/bin/bash

# we are in /opt
set -uxe

# Basic preparation for apt package installation
apt-get -yq update
apt-get -yq install --no-install-recommends wget curl software-properties-common apt-transport-https ca-certificates


## install JAVA
# add-apt-repository -y ppa:webupd8team/java
# bash -c '/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections'
# bash -c '/bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections'
# apt-get -yq update
# apt-get -yq install --no-install-recommends oracle-java8-installer oracle-java8-unlimited-jce-policy

# apt-get -yq install default-jdk
# apt-get -yq upgrade
# apt-get -yq update
# apt -yq autoremove
# apt-get -yq install default-jre
apt -yq install openjdk-8-jdk
# update-alternatives --config java

java -version

# Install tabix
apt-get -yq install tabix 

# Install GATK 3.7
curl -sSL 'https://software.broadinstitute.org/gatk/download/auth?package=GATK-archive&version=3.7-0-gcfedb67' > GenomeAnalysisTK.tar.bz2
tar xjf GenomeAnalysisTK.tar.bz2
rm GenomeAnalysisTK.tar.bz2 && rm -r resources

# Download GATK bundle
wget ftp://ftp.broadinstitute.org/bundle/b37/dbsnp_138.b37.vcf.gz --user=gsapubftp-anonymous
gunzip dbsnp_138.b37.vcf.gz
bgzip dbsnp_138.b37.vcf
tabix -p vcf dbsnp_138.b37.vcf.gz

# Install R and R packages needed by GATK
# apt-get -yq install dirmngr --install-recommends
# apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
# add-apt-repository -y 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
# apt -yq update
# apt -yq install r-base
# R --version

# Rscript -e 'install.packages(c("ggplot2", "gplots", "reshape", "gsalib"))'



# Install Samtools 1.7
# apt-get -yq install --no-install-recommends samtools=1.7-1

# Install Picard 2.0.1
# DEBIAN_FRONTEND=noninteractive apt-get -yq install --no-install-recommends ant git r-base r-base-dev
# curl -sSL https://github.com/broadinstitute/picard/archive/2.0.1.tar.gz > picard.tar.gz
# tar xzf picard.tar.gz
# rm picard.tar.gz
# cd picard-2.0.1
# curl -sSL https://github.com/samtools/htsjdk/archive/2.0.1.tar.gz > htsjdk.tar.gz
# tar xzf htsjdk.tar.gz
# rm htsjdk.tar.gz
# mv htsjdk-2.0.1 htsjdk
# ant clean all
# mv dist/picard.jar ../
# ant clean
# cd ..
# rm -r picard-2.0.1

# Install VerifyBamID v1.1.2
# curl -sSL https://github.com/statgen/verifyBamID/releases/download/v1.1.2/verifyBamID.1.1.2 > verifyBamID
# chmod +x verifyBamID
# # download ref vcf
# curl -sSL http://csg.sph.umich.edu/kang/verifyBamID/download/Omni25_genotypes_1525_samples_v2.b37.PASS.ALL.sites.vcf.gz | gunzip -c > Omni25_genotypes_1525_samples_v2.b37.PASS.ALL.sites.vcf

apt-get clean autoclean
apt-get autoremove -y

