# RnaSeq-HpcPipelines
RNA-Seq Pipelines live on Yale HPC clusters.
## 1. Request an account on a yale HPC cluster, and get preprared
- Go to [yale center for research computing](http://research.computing.yale.edu/support/hpc/getting-started)
  - On the account request page, check farnam and ruddle (if you have data from YCGA).
  - You might want to excercise your unix command line while waiting for your account, and you can find two tutorials at the end of the [yale center for research computing](http://research.computing.yale.edu/support/hpc/getting-started).
- After you get your account, log into your account with ssh, example `ssh {your netid}@ruddle.hpc.yale.edu`
  - You can find more instructions for individual clusters [here](http://research.computing.yale.edu/support/hpc/clusters).
  - Note that all files saved on your scratch folder, which be deleted after 60 days, after an email notification from ITS.

## 2. Prepare the unix terminal on client side (your laptop/desktop)
### for Windows users
- download and install [babun](http://babun.github.io/).  Run the install.bat file, it will take a while.
- run babun.bat and you are at the terminal!  You might pin it to the taskbar for convenience.
  - Babun Tip: mouse select to copy, mouse right click to paste
```
babun update
babun shell /bin/bash
ln -s $HOMEPATH/Downloads .
```
- windows 10 users have another option to use 'subsystem for linux', [see here](https://www.howtogeek.com/249966/how-to-install-and-use-the-linux-bash-shell-on-windows-10/).
### for Mac OS X users
- run terminal
```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install wget
```

## 3. Use the unix terminal on client side
### Bulk download you sequence files (fastq.gz) from west campus (on ruddle)

- Follow the download link provided in their email, click the link to your project.
- In the address bar of your browser, copy the ending string after 'dirName=gpfs_illumina/' and you will get something like 
'sequencerS/.../Project_Ae44'
```
cd Downloads
projectDir=/sequencers/illumina/{paste here}
rsync -azvu {yourNetId}@ruddle.hpc.yale.edu:$projectDir
```
- Alternatively, if you do not have an account on ruddle. Email to ask for an external link, copy the link address, then
```
cd Downloads
wget -e robots=off -r --accept *.fastq.gz {paste here}
```

### Basic QA with [fastqc](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
- run the run_fastqc.bat after downloaded and extracted. You might want to add a shortcut to your Desktop.
  - Menu - file to open one of a ...R1_???.fasta.gz file.
  - Menu - file to save report.
- You can find tutorial and examples on the [fastqc website](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/).
- *Mac: you might want to allow the software by [System preferences - security - open anyway].

## 4. Fastq to Gene Count pipelines on a HPC cluster
- log on to a cluster (ruddle or farnam), example `ssh zl99@ruddle.hpc.yale.edu`
- then use tmux for later access, [read here for more about tmux](https://gist.github.com/MohamedAlaa/2961058).
```
tmux a || tmux
```
- locate your sequence files as described in the 'bulk download' section.
```
projectDir={paste your seqDir here}
mkdir rawData
ln -s $projectDir rawData
```
### 4.1 Bowtie2 local single-end pipeline
- get into a computing node with 8 CPUs and 32Gb Memory:
`qsub -I -q interactive -lnodes=1:ppn=8 -lmem=32g`
- Example usage for batch mode (Project level) on ruddle
```
export PATH=/ycga-ba/home/zl99/code/ngs/pipelines:$PATH

#make a new work space/directory
cd scratch60
mkdir bowtie2.hg38
cd bowtie2.hg38

projectDir=~/rawData/Project_Aea44 #point to your project folder
bowtie2localSeBatch.sh hg38 $projectDir
```
- Arguments:
  * genome: one of {hg38, hg19, mm10, mm9}
  * projectDir: the Project folder with all you samples, each as folder with fastq.gz files.  Note that only R1 files are used for this single ended (Se) pipeline.
- Output:
  * write the count matrix of [gene x sample], RPKM matrix
  * create sample folders, each with: BAM file, bigwig file, etc
  
### STAR + transcriptome pipeline
TBD.
### Tophat2 + transcriptome pipeline
TBD.
## Differential Gene Expression pipelines
### DESeq2 pipeline
- deseq2.vst
  - Usage example: `deseq2.vst < geneCount.csv > geneVst.csv`
### VoomLimma pipeline
TBD.

### unix tips:
- essential command
  - ls, cd, mkdir, rmdir, cp, mv, ln, rm
  - cat, less, nano, echo
  - rsync, wget
- concepts and operators:
  - ${}, |, >, >>, *, ?
  
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

  
