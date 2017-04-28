# RnaSeq-HpcPipelines
RNA-Seq Pipelines live on Yale HPC clusters.
## Prepare the unix terminal on client side (your laptop/desktop)
### for windows 7 users
- download and install [babun](http://babun.github.io/).  Run the install.bat file, it will take a while.
- run babun and you are at the terminal, you can pin it to the taskbar for convenience.

-- Tip: mouse select to copy, mouse right click to paste

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
- In the address bar of your browser, delete the string between the first slash and 'dirName=', then copy the resulting URL. You will get something like 'http://futo.cs.yale.edu:16023//ysm-gpfs/.../Project_Gale_ChMo_D_pool1'
```
cd Downloads
wget -e robots=off -r --accept *.fastq {paste here}
```
### Bulk download you sequence files (fastq.gz) from west campus (on ruddle)
- ask for an external link, and copy the link address
```
cd Downloads
wget -e robots=off -r --accept *.fastq.gz {paste here}
```
- Alternatively, if you have an account on ruddle
-- follow the link to your project
-- In the address bar, copy the ending string after 'gpfs_illumina' and you will get something like 
'/sequencerS/runs/.../Unaligned/Project_Aea44'

```
rsync -azvu {yourNetId}@ruddle.hpc.yale.edu:/sequencers/illumina/{paste here}
```
### basic QA with [fastqc](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
- run the run_fastqc.bat after downloaded and extracted. You might want to add a shortcut to your Desktop.
- You can find tutorial and examples on the website.

### Request a new account on HPC clusters
- Go to yale center for research computing
- on the form check ruddle and farnam

## Fastq to Gene Count pipelines
### Bowtie2 local single-end pipeline
### STAR pipeline
### Tophat pipeline
## Differential Gene Expression pipelines
### DESeq2 pipeline
### VoomLimma pipeline
