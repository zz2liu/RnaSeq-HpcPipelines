# RnaSeq-HpcPipelines
RNA-Seq Pipelines live on Yale HPC **clusters**.
## 1. Prepare the unix terminal on your laptop/desktop
### For Windows users
- download and install [babun](http://babun.github.io/), a free cygwin based linux emulator.  Extract and run the install.bat file, it will take a few minutes. 
- And at last you will be at the terminal! You might want to pin it to the task bar (or search and run babun.bat later).
- Paste the following lines into your terminal (Babun Tip: mouse select text to copy, mouse right click to paste)
    ```sh
    babun update
    babun shell /bin/bash        #set bash as default shell
    ln -s $HOMEPATH/Downloads .  #make a shortcut of your Downloads folder
    ```
    Note: Each line is a bash command, # is for comment
- Optional: Alternative unix terminals on windows:
    - Mobaxterm is another option which should suffice this tutorial.  You can download a free and portable (no installation needed) version [here](http://mobaxterm.mobatek.net/download-home-edition.html).
    - windows 10 users have another option to use 'subsystem for linux', [see here](https://www.howtogeek.com/249966/how-to-install-and-use-the-linux-bash-shell-on-windows-10/).

### For Mac OS X users
- Search and run terminal (you might want to pin it to your dock)
- Paste the following lines (each line is a bash command, # is for comment)
    ```sh
    # install Homebrew, the popular free package manager for OSX. It will take a few minutes.
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install wget    #wget will be used later for downloading your RnaSeq data.
    ```
### Prepare your key to yale clusters
- generate the key pair for your terminal: Paste the following lines (including the blank ones) to your terminal.
    ```sh
    [[ -e ~/.ssh/id_rsa ]] || ssh-keygen <<< "
    
    " #to generate your ssh key pairs needed for login to the clusters.
    chmod 600 ~/.ssh/id_rsa   #make your private key safe
    cat ~/.ssh/id_rsa.pub  #print your public key to screen
    ```
    Then copy the lines from your terminal starting from 'ssh-rsa'
- Follow the link to [register your public key to yale HPC clusters](http://gold.hpc.yale.internal/cgi-bin/sshkeys.py).<br>
Paste into the input box.
- Note: your need to prepare/register a key for each computer from which to logon to the cluster.

### OptionalButSuggested: Familiarize yourself with basic linux concepts and commands
This might looks overwhelming if your never use linux, but it will payback. Set aside one hour to follow the tutorial to see how far you can go.
- [Command-line Bootcamp](http://rik.smith-unna.com/command_line_bootcamp) might be a good start.
- [See another tutorial here](http://www.ee.surrey.ac.uk/Teaching/Unix/index.html).

## 2. Request and prepare your account on a yale HPC cluster
### Request an account 
- Go to [account request page of yale center for research computing](http://research.computing.yale.edu/support/hpc/account-reque
- check farnam, also check ruddle if you have sequenced on west campus/YCGA.
- it might takes a few work days for your accounts to be approved.

### First time logon and setup
- After you got the approvement email from ITS, log into your account from your terminal, example 
    ```
    ssh mynetid@farnam.hpc.yale.edu
    ```
    - You can find more instructions for individual clusters [here](http://research.computing.yale.edu/support/hpc/clusters).
- After you log onto the cluster, paste the following lines for a one-time setup to your cluster account:
    ```sh
    # add pipelines folder to your command searching path
    zl99=$(realpath ~/../zl99)
    echo 'export PATH="$zl99/code/ngs/pipelines:$PATH"' >> ~/.bashrc
    # make a tmux shortcut, and configure for mouse usage
    echo "alias tmux='tmux detach -a; tmux a || tmux new -s S0'" >> ~/.bashrc
    echo 'bind m set -g mouse \; display-message "Mouse on/off toggled."' >> ~/.tmux.conf
    source ~/.bashrc
    # list files and folders in your home directory
    ls -l
    ```
    You can exit by closing your terminal window.

- Note: In the following examples, all the results are stored under your scratch60 folder, which be automatically deleted after 60 days. See [FAQs](#faqs) to find how to backup/synchronize to your computer.

## 3. Run RNA-Seq pipelines on a yale HPC cluster
- Log onto the cluster from your local terminal, example:
    ```sh
    ssh mynetid@farnam.hpc.yale.edu
    ```
    Now, you are on your 'cluster terminal'
- Run tmux 
    ```sh
    tmux
    ```
    We are using tmux primarily to keep your working processes running after you disconnect from the cluster. For more 'advanced' usage like tabs and panes, see my brief introduction to tmux in [FAQs](#faqs).
- To run one of the pipelines, request an interactive computing node with 8 CPUs and 32Gb Memory:
    ```sh
    srun --pty -p interactive -c8 --mem-per-cpu=4000 bash
    ```

### Mapping: Bowtie2 local single-end mapping pipeline
Generate a gene x sample read counts matrix for your project.

#### Test with the example project
- Set the parameters: paste the following lines to your cluster terminal on a computing node
    ```sh
    # set up the projectDir and genome
    projectDir="~/../zl99/project/Project_Test1M"
    genome="hg38"
    ```
- Run the pipeline, output to a new folder under scratch60: paste the folowing lines
    ```sh
    # make a new folder in scratch60 for output, using your project name
    mkdir "~/scratch60/$(basename $projectDir)" && cd $_
    # map the reads to genome
    prepare_pipelines
    bowtie2localSeBatch $genome $projectDir  #set in the previous step
    ```
    It will take a few minutes.
- Check the output of the pipeline. Examples:
    ```sh
    ls -l
    head geneCount.csv
    ls -l */*.bam
    ```
    you can check the pipeline documents below for details.
    
#### Run your own project
- Locate your sequence project folder as described in the [FAQs](#faqs), or upload a project folder with the same structure (each of the samples as a subfolder with fastq.gz files).
- Set your projectDir and genome as demonstrated in the example, replacing with your own settings after the `=`
- Then run the pipeline, paste the same lines as with the example. It takes much longer, your might wait overnight.
- Check the output, as with the example
- Check the [FAQs](#faqs) if you want to download the results to your computer.

#### Pipeline Document:
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

### Mapping: STAR + transcriptome mapping pipeline
TBD. High priority <br>
Reference: [STAR](https://github.com/alexdobin/STAR).

### Mapping: Tophat2 + transcriptome mapping pipeline
TBD. Low priority. <br>
Reference: [TopHat](https://ccb.jhu.edu/software/tophat/index.shtml).

### Diferential Expression: DESeq2 pipeline
#### Example/test usage
- Set the parameters: paste the following lines to your cluster terminal on a computing node
    ```sh
    # set up mappingDir and contrasts
    mappingDir="~/scratch60/Project_Test1M" #output directory of the mapping pipeline
    contrasts="A-Ctrl,B-Ctrl,B-A"
    ```
- Run pipeline, output to a new folder under your mappingFolder
    ```sh
    # run pipeline, output to a new folder ./deseq2
    mkdir $mappingDir/deseq2; cd $_
    prepare_pipelines
    deseq2ContrastBatch ../geneCount.csv ../sampleInfo.csv $contrasts
    ```
#### Run your project
- Set your mappingDir and contrasts as demonstrated in the example, replacing with your own setting after the `=`
- Create/upload your own sampleInfo.csv file to your mappingDir (check the format in the pipeline document below)
- Run the pipeline the same as in example
- Check the [FAQs](#faqs) if you want to download the results to your computer.

#### Pipeline Document
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

### Diferential Expression: VoomLimma diferential gene expression pipeline
TBD. Low priority <br>
Reference: [Limma package](https://bioconductor.org/packages/release/bioc/html/limma.html).

## FAQs
### How to synchronize files with the cluster?
You can use rsync, comes with the terminal on your computer. For example:
- set your remoteDir, localDir to synchronize
    ```sh
    remoteDir="yourNetid@farnam.hpc.yale.edu:scratch60"
    localDir="~/scratch60"
    ```
    Tip: you may drag your folder from your file explorer to the terminal to set the localDir.
- backup every file and subfolder from your remoteDir (source) to your localDir (target)
    ```sh
    rsync -azvuP $remoteDir/ $localDir # with /, transfer everything under the source dir.
    ```
- upload a new local folder named 'newFolder' (source) to your remoteDir (target)
    ```sh
    #upload a folder named 'newFolder' to your remoteDir
    rsync -azvuP $localDir/newFolder $remoteDir   #without /, transfer the source dir.
    ```
- For more usage examples of rsync, [see a tutorial](https://www.tecmint.com/rsync-local-remote-file-synchronization-commands/)

### How to bulk download you sequence files (fastq.gz) from west campus (on ruddle)
- Follow the download link provided in their email, copy the link address of your project. 
- set the projectLink, netId, targetDir on your local terminal
    ```sh
    projectLink=__pastehere__
    targetDir=~/Downloads #the local folder to download to
    netId=myNetid
    ```
- Download with rsync
    ```sh
    projectDir="/sequencers/illumina${projectLink##*gpfs_illumina}"
    rsync -azvuP $netId@ruddle.hpc.yale.edu:$projectDir $targetDir
    ```
- Alternatively, if you do not have an account on ruddle. Email to ask for an external link, copy the link address, then
    - set the externalLink and targetDir: replace with your settings
        ```sh
        externalLink=__pastehere__
        targetDir=~/Downloads
        ```
    - Download with wget: paste the following
        ```sh
        cd $targetDir
        wget -e robots=off -r --accept *.fastq.gz $externalLink
        ```

### How to bulk download sequence files (fastq) from Yale Stem Cell Center (on farnam)
- follow the download link provided in their email, copy the link address of your project.
- set the projectLink, targetDir, and netId: replace with your own settings    
    ```sh
    projectLink=__paste here__
    targetDir=~/Downloads
    netId=myNetid
    ```
- Download with rsync: paste the following lines
    ```sh
    projectDir=${projectLink##*dirName=}
    rsync -azvuP --exclude='*.fastq' $netId@farnam.hpc.yale.edu:$projectDir $targetDir
    ```
- Alternatively, if you do not have a farnam account:
    - set the projectLink, targetDir as above
    - Download with wget: paste the following lines
    ```sh
    projectDir=${projectLink##*dirName=}
    cd $targetDir
    wget -e robots=off -r --accept *.fastq.gz http://futo.cs.yale.edu:16023/$projectDir
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
    - split your terminal into windows(tabs) and panes (multple terminals within a window/tab) <br>
    ![windows and panes](https://www.ocf.berkeley.edu/~ckuehl/tmux/tmux-labels.png)

- Using tabs: once in tmux, type ctrl-b then

    |type a key  |to |
    |----:|-----|
    |c              |create a new window (you might call it a tab) |
    |n / number     |select next/specific window |
    |x              |kill the current pane |
    
- More advanced: Using panes 
    
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


