# RnaSeq-HpcPipelines
RNA-Seq Pipelines live on Yale HPC clusters.
## Request an account on a yale HPC cluster, and get preprared
- Go to [yale center for research computing](http://research.computing.yale.edu/support/hpc/getting-started)
- On the account request page, check farnam and ruddle (if you have data from YCGA).
- log into your account with ssh, example `ssh {your netid}@farnam.hpc.yale.edu`
  - Note that all files saved on your scratch folder, which be deleted after 60 days, after an email notification from ITS.
- get prepared for pipelines on farnam.  
```
ln -s /ysm-gpfs/scratch60/$USER scratch
ls -l
```
- get prepared for pipelines on ruddle.
```
```

## Prepare the unix terminal on client side (your laptop/desktop)
### for windows 7 users
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
### Bulk download your sequence files (fastq) from Yale Stem Cell Center (on farnam)
- follow the download link provided in their email, click the link to your project
- In the address bar of your browser, copy the ending string after 'dirName=' and you will get something like 
'/ysm-gpfs/.../Project_Ae4'
```
cd Downloads
wget -e robots=off -r --accept *.fastq http://futo.cs.yale.edu:16023/{paste here}
```
- You can then find your data in a new 'futo.cs.yale.edu:16023' folder under your Download folder.
- Alternatively, if you have an account on farnam
  - follow the link to your project
  - In the address bar, copy the ending string after 'dirName=' and you will get something like 
'/ysm-gpfs/.../Project_Ae4'
```
cd Downloads
rsync -azvu {yourNetId}@farnam.hpc.yale.edu:/{paste here} .
```

### Bulk download you sequence files (fastq.gz) from west campus (on ruddle)
- ask for an external link, and copy the link address
```
cd Downloads
wget -e robots=off -r --accept *.fastq.gz {paste here}
```
- You can then find your data in a new 'sysg1.cs.yale.edu:3010' folder under your Download folder.
- Alternatively, if you have an account on ruddle
  - follow the link to your project
  - In the address bar, copy the ending string after 'gpfs_illumina' and you will get something like 
'/sequencerS/runs/.../Unaligned/Project_Aea44'
```
cd Downloads
rsync -azvu {yourNetId}@ruddle.hpc.yale.edu:/sequencers/illumina/{paste here}
```
### Basic QA with [fastqc](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
- run the run_fastqc.bat after downloaded and extracted. You might want to add a shortcut to your Desktop.
- You can find tutorial and examples on the [fastqc website](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/).

## Fastq to Gene Count pipelines on a HPC cluster
- log on to a cluster (ruddle or farnam). 
- locate your sequence files as described in the 'bulk download' section. See also [descriptions on individual clusters](http://research.computing.yale.edu/support/hpc/clusters). Examples on ruddle,
```
ls -s 
```
### Bowtie2 local single-end pipeline
### STAR + transcriptome pipeline
### Tophat2 + transcriptome pipeline

## Differential Gene Expression pipelines
### DESeq2 pipeline
### VoomLimma pipeline
