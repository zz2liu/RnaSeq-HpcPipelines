# RnaSeq-HpcPipelines
RNA-Seq Pipelines live on Yale HPC **clusters**.
## 1. Prepare the unix terminal on your laptop/desktop
### for Windows users
- download and install [babun](http://babun.github.io/), a free cygwin based linux emulator on windows.  Extract and run the install.bat file, it will take a while. 
- And at last you will be at the terminal! You might want to pin it to the task bar (or search and run babun.bat later).
- Then paste the following lines into your terminal (each line is a bash command, # is for comment):
    - Babun Tip: mouse select text to copy, mouse right click to paste
    ```sh
    babun update
    babun shell /bin/bash        #set bash as default shell
    ln -s $HOMEPATH/Downloads .  #make a shortcut of your Downloads folder
    [[ -e ~/.ssh/id_rsa ]] || ssh-keygen <<< "
    
    " #to generate your ssh key pairs needed for login to the clusters.
    chmod -R 600 ~/.ssh/id_rsa   #make your private key safe
    ```
- Alternative unix terminals on windows:
    - Mobaxterm is another option which should suffice this tutorial.  You can download a free and portable (no installation needed) version [here](http://mobaxterm.mobatek.net/download-home-edition.html).
    - windows 10 users have another option to use 'subsystem for linux', [see here](https://www.howtogeek.com/249966/how-to-install-and-use-the-linux-bash-shell-on-windows-10/).

### for Mac OS X users
- run terminal, then type the following lines (each line is a bash command, # is for comment)
    ```sh
    # install Homebrew, the popular free package manager for OSX
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install wget    #wget will be used later for downloading your RnaSeq data.
    [[ -e ~/.ssh/id_rsa ]] || ssh-keygen  <<< "\n\n\n"     #to generate your ssh key pairs needed for login to the clusters.
    ```
## 2. Request an account on a yale HPC cluster, and get preprared for the pipelines
- Go to [account request page of yale center for research computing](http://research.computing.yale.edu/support/hpc/account-reque
- check farnam, also check ruddle if you have sequenced on west campus/YCGA.
- While waiting for your accounts, familiarize yourself with basic linux concepts and commands on the local terminal you just prepared. 
    - [Command-line Bootcamp](http://rik.smith-unna.com/command_line_bootcamp) might be a good start.
    - [See another tutorial here](http://www.ee.surrey.ac.uk/Teaching/Unix/index.html).
- After your account is approved, you'll receive an email with [a link to upload your public key](http://gold.hpc.yale.internal/cgi-bin/sshkeys.py). 
    - open your terminal,
        ```sh
        cat ~/.ssh/id_rsa.pub  #print your public key to screen
        ```
        Then copy the lines starting from 'ssh-rsa' and paste into the box. 
- log into your account from your terminal, example 
    ```
    ssh mynetid@farnam.hpc.yale.edu
    ```
  - You can find more instructions for individual clusters [here](http://research.computing.yale.edu/support/hpc/clusters).
- after you log onto the cluster, type/paste the following lines for a one-time setup to your cluster account:
    ```sh
    zl99=$(realpath ~/../zl99)
    echo 'export PATH="$zl99/code/ngs/pipelines:$PATH"' >> ~/.bashrc
    echo "alias tmux='tmux detach -a; tmux a || tmux new -s S0'" >> ~/.bashrc
    # echo ".libPaths(c('$zl99/R/x86_64-pc-linux-gnu-library/3.2', .libPaths()))" >> ~/.Rprofile
    echo 'bind m set -g mouse \; display-message "Mouse on/off toggled."' >> ~/.tmux.conf
    ```
    then exit by closing your terminal.
- Then every time after log on, run tmux for access to your working processes. See my brief introduction to tmux in [FAQs](#faqs). 
    ```tmux```
- To run one of the pipelines, request an interactive computing node with 8 CPUs and 32Gb Memory:
    ```
    srun --pty -p interactive -c8 --mem-per-cpu=4000 bash
    ```
- In the following examples, all the results are stored under your scratch60 folder, which be automatically deleted after 60 days. See [FAQs](#faqs) to find how to backup/synchronize to your computer.

## 3. Fastq to Gene Count pipelines on a HPC cluster

### 3.1 Bowtie2 local single-end pipeline

- Example/test usage for mapping and counting on Project level
    ```sh
    projectDir="~/../zl99/project/Project_Test1M"
    # make a new folder in scratch60 for output, using your project name
    mkdir "~/scratch60/$(basename $projectDir)" && cd $_
    # mapping using the hg38 genome
    prepare_pipelines
    bowtie2localSeBatch hg38 $projectDir  #set in the previous step
    ```
- Usage: 
    `bowtie2localSeBatch <genome> <projectDir>`
- Arguments:
    * genome: one of {hg38, hg19, mm10, mm9}
    * projectDir: the Project folder with all you samples, each as folder with fastq.gz files.  Note that only R1 files are used for this single ended (Se) pipeline.
- Output: write to the current directory
    * a summary report of the mapping pipeline: summary.report.csv, summary.report.pdf
    * a count matrix of [geneId x sampleName]: geneCount.csv, geneInfo.csv
    * the normalized gene expression matrices: geneRpkm.csv, geneExpr.vst.csv
    * sample output folders, each with: 
        - BAM file: the alignments.
        - bigwig file: the coverage at each base normalized to Counts Per Million Reads mapped (CPM).
- To run your own project, locate your sequence project folder as described in the [FAQs](#faqs), and type after the `projectDir=` to replace the test project dir.

### 3.2 STAR + transcriptome pipeline
TBD.
Reference: [STAR](https://github.com/alexdobin/STAR).

### 3.3 Tophat2 + transcriptome pipeline
TBD.
Reference: [TopHat](https://ccb.jhu.edu/software/tophat/index.shtml).

## 4. Differential Gene Expression pipelines
### 4.1 DESeq2 pipeline
- Example/test usage
    ```sh
    cd ~/scratch60/Project_Test1M #cd to your output directory of the mapping pipeline
    mkdir deseq2; cd $_
    prepare_pipelines
    deseq2ContrastBatch ../geneCount.csv ../sampleInfo.csv A-Ctrl,B-Ctrl,B-A
    ```
- Usage: `deseq2ContrastBatch <geneCountFile> <sampleInfoFile> <contrast1>[,<contrast2>[,...]]`
- Arguments:
    - geneCountFile: a csv file with raw read counts of geneID x sampleName
    - sampleInfoFile: a csv file with sample info. The first three columns are required.
        - sampleName should match that of geneCountFile
        - sampleShortName will be used in plots
        - sampleGroup will be used in a comparision/contrast.
    - a contrast: a comparison between two 'sampleGroup's in the format of groupNumerator-groupDenominator
- Output: write to the current directory
    - A normalized count matrix
    - PCA plot
    - Differential expression results as seperate folders, each for a comparison
        
Reference: [DESeq2 package](http://bioconductor.org/packages/release/bioc/html/DESeq2.html).

### 4.2 VoomLimma pipeline
TBD.
Reference: [Limma package](https://bioconductor.org/packages/release/bioc/html/limma.html).

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
    rsync -azvu $netId@ruddle.hpc.yale.edu:$projectDir .
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
    rsync -azvuP --exclude='*.fastq' $netId@farnam.hpc.yale.edu:$projectDir .
    ```
- Alternatively, if you do not have a farnam account:
    ```sh
    cd Downloads
    wget -e robots=off -r --accept *.fastq.gz http://futo.cs.yale.edu:16023/__paste here__
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

### Tmux: why to use and how?
- Why whould i use tmux?
    - keep programs running after you disconnect (e.g. when working on a remote server via ssh)
    - split your terminal into windows(tabs) and panes <br>
    ![windows and panes](https://www.ocf.berkeley.edu/~ckuehl/tmux/tmux-labels.png)

- once in tmux, type ctrl-b then

    |type a key  |to |
    |----:|-----|
    |c              |create a new window (you might call it a tab) |
    |n / number     |select next/specific window |
    |x              |kill the current pane |
    
- More advanced: to use panes (multple terminals within a window/tab)
    
    |type ctrl-b, then | to |
    | ---: | --- |
    |" / %            |create a new pane vertically/horizontally |
    |o / arrow   |select next/specific pane |
    |ctrl+arrow  |resize a pane |
    |z  |toggle maximize/unmaximize a pane |
    |d  |detach and leave everthing running in the background |
    |?              |see a shortcut list |
    
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
- You can use a for loop, for example
  ```
  # move each sorted.bam.bw in the subfolders to the current folder and rename as the_subfolder.bw
  for f in */*.bw; do mv $f ${f/\/sorted.bam/}; done
  ```
  - `${string/pattern/replacement}` is a [bash string manipulation](http://www.thegeekstuff.com/2010/07/bash-string-manipulation). The pattern will be deleted without replacement.

### How to filter the gene count data by an arbitrary criteria?
You can do this in a spreadsheet.  An autofilter following [countif function](https://www.ablebits.com/office-addins-blog/2014/07/02/excel-countif-examples/) might suffice.


