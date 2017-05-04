# RnaSeq-HpcPipelines
RNA-Seq Pipelines live on Yale HPC **clusters**.
## 1. Request an account on a yale HPC cluster, and get preprared
- Go to [yale center for research computing](http://research.computing.yale.edu/support/hpc/getting-started)
  - On the account request page, check farnam and ruddle (if you have data from YCGA).
  - While waiting for your accounts, familiarize yourself with basic linux concepts and commands. 
    - [Command-line Bootcamp](http://rik.smith-unna.com/command_line_bootcamp) might be a good start.
    - [See another tutorial here](http://www.ee.surrey.ac.uk/Teaching/Unix/index.html).
- After you get your account, log into your account with ssh, example `ssh __netid__@ruddle.hpc.yale.edu`
  - You can find more instructions for individual clusters [here](http://research.computing.yale.edu/support/hpc/clusters).

## 2. Prepare the unix terminal on client side (your laptop/desktop)
### for Windows users
- download and install [babun](http://babun.github.io/).  Run the install.bat file, it will take a while.
- run babun.bat and you are at the terminal!  You might pin it to the taskbar for convenience.
    ```sh
    babun update
    babun shell /bin/bash
    ln -s $HOMEPATH/Downloads .
    ```
  - Babun Tip: mouse select to copy, mouse right click to paste

- windows 10 users have another option to use 'subsystem for linux', [see here](https://www.howtogeek.com/249966/how-to-install-and-use-the-linux-bash-shell-on-windows-10/).

### for Mac OS X users
- run terminal
    ```sh
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install wget
    ```

## 3. Fastq to Gene Count pipelines on a HPC cluster
- One time setup after log on to your cluster account.
    ```sh
    echo 'export PATH=$HOME/../zl99/code/ngs/pipelines:$PATH' >> ~/.bashrc
    echo 'alias tmux="tmux detach -a; tmux a || tmux new -s S0" >> ~/.bashrc
    . bashrc
    echo 'set -g mouse on' >>~/.tmux.conf'
    ```
- Then every time after log on, use tmux for later access to your working process. See my brief introduction to tmux in FAQs section, and you can [learn more about tmux here](https://gist.github.com/MohamedAlaa/2961058).
```
tmux
```
- locate your sequence project folder as described in the 'FAQs:bulk download' section.
<pre>
projectDir=<ins>__paste here__</ins>
mkdir rawData
ln -s $projectDir rawData
</pre>
- In the following examples, all the results are stored under your scratch60 folder, which be automatically deleted after 60 days, following an email notification from ITS.

### 3.1 Bowtie2 local single-end pipeline
- get into a computing node with 8 CPUs and 32Gb Memory:
`qsub -I -q interactive -lnodes=1:ppn=8 -lmem=32g`
- Example usage for batch mode (Project level) on ruddle
```sh
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
  
### 3.2 STAR + transcriptome pipeline
TBD.

### 3.3 Tophat2 + transcriptome pipeline
TBD.

## 4. Differential Gene Expression pipelines
### 4.1 DESeq2 pipeline
- deseq2.vst
  - Usage example: `deseq2.vst < geneCount.csv > geneVst.csv`
### 4.2 VoomLimma pipeline
TBD.


## FAQs
### How to download from/upload to the cluster?
Use rsync.

### How to bulk download you sequence files (fastq.gz) from west campus (on ruddle)
- Follow the download link provided in their email, click the link to your project.
- In the address bar of your browser, copy the ending string after 'dirName=gpfs_illumina/' and you will get something like 
'sequencerS/.../Project_Ae44'
```sh
cd Downloads
netId=__type here__
projectDir=/sequencers/illumina/__paste here__
rsync -azvu $netId@ruddle.hpc.yale.edu:$projectDir
```
- Alternatively, if you do not have an account on ruddle. Email to ask for an external link, copy the link address, then
```sh
cd Downloads
wget -e robots=off -r --accept *.fastq.gz __paste here__
```

### How to bulk download sequence files (fastq) from Yale Stem Cell Center (on farnam)
- follow the download link provided in their email, click the link to your project.
- In the address bar of your browser, copy the ending string after 'dirName=' and you will get something like 
'/ysm-gpfs/.../Project_Ae4'
```sh
netId=__type here__
projectDir=__paste here__
cd Downloads
rsync -azvu $netId@farnam.hpc.yale.edu:$projectDir .
```
- Alternatively, if you do not have a farnam account:
```sh
cd Downloads
wget -e robots=off -r --accept *.fastq http://futo.cs.yale.edu:16023/__paste here__
```
### How to perform basic Quality analyses to the raw data?
Use [fastqc](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
- run the run_fastqc.bat after downloaded and extracted. You might want to add a shortcut to your Desktop.
  - Menu : file to open one of a fasta.gz file.
  - Menu : file to save report.
- You can find tutorial and examples on the [fastqc website](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/).
- Mac tip: you might want to allow the software by [System preferences - security - open anyway].

### What are the first linux commands should I learn?
- essential commands
  - ls, cd, mkdir, rmdir, cp, mv, ln, rm
  - cat, less, echo
  - rsync, wget
- concepts and operators:
  - ${}, |, >, >>, \*, ?

### What are the first tmux commands should I learn?
- Why whould i use tmux?
[See an appetite here](https://www.ocf.berkeley.edu/~ckuehl/tmux/).
- one time set up to start tmux, then run `tmux` to start it.
```sh
echo 'alias tmux="tmux detach -a; tmux a || tmux new -s S0"' >> ~/.bashrc
. .bashrc
echo 'set -g mouse on' >>~/.tmux.conf #works for tmux 2
```
- once in tmux, type ctrl-b then

|key  |to do|
|----:|-----|
|?              |to see a shortcut list|
|d/D            |to detach and leave everything running in the background|
|c              |to create a new window|
|n/l/number     |to select next/last/specific window; __mouse can be used__.|
|"/%            |to create a new pane horizontally/vertically.|
|o/;/q+number   |to select next/last/specific pane; __mouse can be used__.|
|z/ctrl+arrows  |to maximize/resize a pane; __mouse can be used__.|
|x              |to kill a pane; exit linux command is preferred if possible.|
|,              |to rename a window|

