# RnaSeq-HpcPipelines
RNA-Seq Pipelines live on Yale HPC **clusters**.
## 1. Request an account on a yale HPC cluster, and get preprared
- Go to [yale center for research computing](http://research.computing.yale.edu/support/hpc/getting-started)
  - On the account request page, check farnam and ruddle (if you have data from YCGA).
  - While waiting for your accounts, familiarize yourself with basic linux concepts and commands. 
    - [Command-line Bootcamp](http://rik.smith-unna.com/command_line_bootcamp) might be a good start.
    - [See another tutorial here](http://www.ee.surrey.ac.uk/Teaching/Unix/index.html).
- After you get your account, log into your account with ssh, example `ssh mynetid@ruddle.hpc.yale.edu`
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
    zl99=$(realpath ~/../zl99)
    echo "export PATH=$zl99/code/ngs/pipelines:\$PATH" >> ~/.bashrc
    echo "alias tmux='tmux detach -a; tmux a || tmux new -s S0'" >> ~/.bashrc
    echo ".libPaths(c('$zl99/R/x86_64-pc-linux-gnu-library/3.2', .libPaths()))" >> ~/.Rprofile
    echo "bind m set -g mouse" >> ~/.tmux.conf
    . ~/.bashrc
    ```
    - Then every time after log on, run `tmux` for later access to your working process. See my brief introduction to tmux in [FAQs](#faqs).

- locate your sequence project folder as described in the [FAQs](#faqs).
    ```sh
    projectDir=______
    mkdir rawData
    ln -s $projectDir rawData
    ```
- In the following examples, all the results are stored under your scratch60 folder, which be automatically deleted after 60 days, following an email notification from ITS. see [FAQs](#faqs) to find how to backup/synchronize to your computer.

### 3.1 Bowtie2 local single-end pipeline
- get into a computing node with 8 CPUs and 32Gb Memory:
`qsub -I -q interactive -lnodes=1:ppn=8 -lmem=32g`
- make a new folder for output, for example
    ```sh
    cd scratch60
    mkdir bowtie2.hg38
    cd bowtie2.hg38
    ```

- Example usage for mapping and counting in batch mode (Project level) on ruddle
    ```sh
    projectDir=~/rawData/Project_Aea44 #point to your project folder
    bowtie2localSeBatch.sh hg38 $projectDir
    ```
  - Arguments:
    * genome: one of {hg38, hg19, mm10, mm9}
    * projectDir: the Project folder with all you samples, each as folder with fastq.gz files.  Note that only R1 files are used for this single ended (Se) pipeline.
  - Output:
    * a summary report of the mapping pipeline: summary.report.csv, summary.report.pdf
    * write the count matrix of [gene x sample]: geneCount.csv, geneInfo.csv
    * normalization of the gene count matrix: geneRpkm.csv, geneExpr.vst.csv
    * create sample output folders, each with: 
      - BAM file: the alignments.
      - bigwig file: the coverage at each base normalized to Counts Per Million Reads mapped (CPM).
  
### 3.2 STAR + transcriptome pipeline
TBD.

### 3.3 Tophat2 + transcriptome pipeline
TBD.

## 4. Differential Gene Expression pipelines
### 4.1 DESeq2 pipeline
TBD.

### 4.2 VoomLimma pipeline
TBD.

## FAQs
### How to download from/upload to the cluster?
- You can use rsync, [see a tutorial](https://www.tecmint.com/rsync-local-remote-file-synchronization-commands/). For example:
```
netid=______
newFolder=______
#backup/synchronize from you cluster scratch60 folder
rsync -azvuP $netid@ruddle.hpc.yale.edu:scratch60 ~
#upload a newFolder to your cluster scratch60
rsync -azvuP ~/scratch60/$newFolder $netid@ruddle.hpc.yale.edu:scratch60
```

### How to bulk download you sequence files (fastq.gz) from west campus (on ruddle)
- Follow the download link provided in their email, click the link to your project.
- In the address bar of your browser, copy the ending string after 'dirName=gpfs_illumina/' and you will get something like 'sequencerS/.../Project_Ae44' 
    ```sh
    cd Downloads
    netId=______
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
    netId=______
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

### How to visualize the bigwig (.bw) files for each sample?
- You can use IGV, [see here](http://software.broadinstitute.org/software/igv/)

### What are the first tmux commands should I learn?
- Why whould i use tmux?
[See an appetite here](https://www.ocf.berkeley.edu/~ckuehl/tmux/).
- once in tmux, type ctrl-b then

    |type a key  |to |
    |----:|-----|
    |?              |see a shortcut list |
    |d/D            |detach and leave everything running in the background |
    |c              |create a new window |
    |n/l     |select next/last window |
    |number/__mouse__ |select a specific window<br> |
    |"/%            |create a new pane horizontally/vertically |
    |o/;   |select next/last pane |
    |q+number/arrow/__mouse__   |select a specific pane <br> |
    |z  | toggle maximize/unmaximize a pane |
    |ctrl+arrow/__mouse__  |resize a pane |
    |x              |kill a pane; `exit` linux command is preferred if possible.|
    |m              |__toggle mouse on/off__. Require: `bind m set -g mouse` in your ~/.tmux.conf|

### What are the first linux commands should I learn?
- essential commands
  - navigation: ls, cd, mkdir, rmdir, cp, mv, ln, rm
  - view/edit: cat, less, echo, nano
  - file transfer: rsync, wget
- concepts and operators:
  - wildcards: \*, ?
  - variable: ${}
  - redirect: |, >, >>

### How to move and rename nested files to one folder?
- You can use a for loop,
```
for f in */*.bw; do cp $f ${f/\/sorted.bam/}; done
```
  - instead of cp, you might try `ln -s`
  - `${string/pattern/replacement}` is a [bash string manipulation](http://www.thegeekstuff.com/2010/07/bash-string-manipulation).
