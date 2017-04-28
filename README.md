# RnaSeq-HpcPipelines
RNA-Seq Pipelines live on Yale HPC clusters.
##prepare the unix terminal on client side (your laptop/desktop)
### for windows 7 users
- download and install babun
- run babun and you are at the terminal
```
babun update
babun shell /bin/bash
ln -s $HOMEPATH/Downloads .
cd Downloads
ls #to list your folders and files
```
### for Mac OS X users
- run terminal
```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install wget
cd Downloads
ls #to list your folders and files
```
## Fastq to Gene Count pipelines
### Bowtie2 local single-end pipeline
### STAR pipeline
### Tophat pipeline
## Differential Gene Expression pipelines
### DESeq2 pipeline
### VoomLimma pipeline
