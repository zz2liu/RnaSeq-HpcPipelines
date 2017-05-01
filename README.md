# RnaSeq-HpcPipelines
RNA-Seq Pipelines live on Yale HPC clusters.
## Request an account on a yale HPC cluster, and get preprared
- Go to [yale center for research computing](http://research.computing.yale.edu/support/hpc/getting-started)
  - On the account request page, check farnam and ruddle (if you have data from YCGA).
  - You might want to excercise your unix command line while waiting for your account, and you can find two tutorials at the end of the [yale center for research computing](http://research.computing.yale.edu/support/hpc/getting-started).
- After you get your account, log into your account with ssh, example `ssh {your netid}@ruddle.hpc.yale.edu`
  - You can find more instructions for individual clusters [here](http://research.computing.yale.edu/support/hpc/clusters).
  - Note that all files saved on your scratch folder, which be deleted after 60 days, after an email notification from ITS.

## Prepare the unix terminal on client side (your laptop/desktop)
### for Windows users
- download and install [babun](http://babun.github.io/).  Run the install.bat file, it will take a while.
- run babun.bat and you are at the terminal!  You might pin it to the taskbar for convenience.
  - Babun Tip: mouse select to copy, mouse right click to paste
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

### Bulk download you sequence files (fastq.gz) from west campus (on ruddle)

- Follow the download link provided in their email, click the link to your project.
- In the address bar of your browser, copy the ending string after 'dirName=gpfs_illumina/' and you will get something like 
'sequencerS/.../Project_Ae44'
```
cd Downloads
projectDir=/sequencers/illumina/{paste here}
rsync -azvu {yourNetId}@ruddle.hpc.yale.edu:$projectDir
```
- Alternatively, if you do not have an account on ruddle
  - ask for an external link, copy the link address, then
  ```
  cd Downloads
  wget -e robots=off -r --accept *.fastq.gz {paste here}
  ```
### Basic QA with [fastqc](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
- run the run_fastqc.bat after downloaded and extracted. You might want to add a shortcut to your Desktop.
- You can find tutorial and examples on the [fastqc website](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/).

## Fastq to Gene Count pipelines on a HPC cluster
- log on to a cluster (ruddle or farnam). 
- locate your sequence files as described in the 'bulk download' section.
```
projectDir={paste your seqDir here)
mkdir rawData
ln -s $projectDir rawData
```
### Bowtie2 local single-end pipeline
- Example usage for batch mode (Project level)
```
#projectDir=~/rawData/Project_Aea44
cd scratch60
bowtie2localSeBatch hg38 $projectDir
```
- Arguments:
  * genome: one of {hg38, hg19, mm10, mm9}
  * projectDir: the Project folder with all you samples, each as folder with fastq.gz files.  Note that only R1 files are used for this single ended (Se) pipeline.
- Output:
  * create a new folder with the name {yourProject}.{genome} into your current folder.
  * write the count matrix of [gene x sample], RPKM matrix
  * write into each sample folder: BAM file, bigwig file, etc
  
### STAR + transcriptome pipeline
### Tophat2 + transcriptome pipeline

## Differential Gene Expression pipelines
### DESeq2 pipeline
- deseq2.vst
  - Usage example: `deseq2.vst < geneCount.csv > geneVst.csv`
### VoomLimma pipeline
### unix tips:
- essential command
  - ls, cd, mkdir, rmdir, cp, mv, ln, rm
  - cat, less, nano, echo
  - rsync, wget
- concepts and operators:
  - $, |, >, >> 
  
### Bulk download your sequence files (fastq) from Yale Stem Cell Center (on farnam)
- follow the download link provided in their email, click the link to your project.
- In the address bar of your browser, copy the ending string after 'dirName=' and you will get something like 
'/ysm-gpfs/.../Project_Ae4'
```
projectDir={paste here}
cd Downloads
rsync -azvu {yourNetId}@farnam.hpc.yale.edu:$projectDir .
```
- Alternatively, if you do not have a farnam account:
```
cd Downloads
wget -e robots=off -r --accept *.fastq http://futo.cs.yale.edu:16023/{paste here}
```

  
