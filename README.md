<!-- 
TODO: rewrite with Snakemake: https://github.com/slowkow/snakefiles
TODO:
    add guide for GSEA and Fastqc
    IGV
TODO: bowtie2Pipeline <geneome name/dir> <project link/dir>
    > scratch60/projectName.bowtie2Pipeline.YMD-HMS

-->
# RnaSeq-HpcPipelines
RNA-Seq Pipelines live on Yale HPC clusters. <br>
**Note about the `code block`s in this tutorial**:
- Each line is a bash command: program + options + arguments
- Anything after a `#` is a comment
- For most of the blocks, you can just copy and paste everything to your terminal, then type enter.
- The <span><ins>underlined part<ins></span> or `_partBetweenUnderline_` need your action instead of just copy and paste. 
- You can type ctrl-c to cancel the execution of a command.

To see a demo [during a workshop on 7/28/2017 here](workshop.20170728.log)
## 1. Prepare the unix terminal on your laptop/desktop
### For Windows users
- download and install [babun](http://babun.github.io/), a free cygwin based linux emulator.  Extract and run the install.bat file, it will take a few minutes to finish. 
- And at last you will be at the terminal! You might want to pin it to the task bar (or search and run babun.bat later).
- Paste the following lines into your terminal (Babun Tip: mouse select text to copy, mouse right click to paste)
    ```sh
    babun update
    babun shell /bin/bash        #set bash as default shell
    ln -s $HOMEPATH/Downloads .  #make a shortcut of your Downloads folder
    ```
- Optional: Alternative unix terminals on windows:
    - Mobaxterm is another option which should suffice this tutorial.  You can download a free and portable (no installation needed) version [here](http://mobaxterm.mobatek.net/download-home-edition.html).
    - windows 10 users have another option to use 'subsystem for linux', [see here](https://www.howtogeek.com/249966/how-to-install-and-use-the-linux-bash-shell-on-windows-10/).

### For Mac OS X users
- Search and run terminal (you might want to pin it to your dock)
- Optional: Paste the following lines
    ```sh
    # install Homebrew, the popular free package manager for OSX. It will take a few minutes.
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install wget    #wget will be used later for downloading your RnaSeq data.
    ```
### Prepare your key files to yale clusters
- generate the key pair for your terminal:
    ```sh
    keyFile=~/.ssh/id_rsa
    # generate a key pair if necessary
    [[ -e $keyFile ]] || ssh-keygen -f $keyFile -t rsa -N ''
    chmod 600 $keyFile  #make your private key safe
    cat $keyFile.pub  #print your public key to screen
    ```
    Then copy the lines from your terminal starting from 'ssh-rsa', an example below:<br>
    ![id_rsa.pub example](Selection_013.png)
- Follow the link to [register your public key to yale HPC clusters](http://gold.hpc.yale.internal/cgi-bin/sshkeys.py), then
    - Paste into the input box, then click \<Make changes\>
Note: your need to prepare/register a key for each computer from which to logon to the cluster.

## 2. Request and prepare your account on a yale HPC cluster
### Request an account 
- Go to [account request page of yale center for research computing](http://research.computing.yale.edu/support/hpc/account-request)
    - check farnam, also check ruddle if you have sequenced on west campus/YCGA.
Note: it might takes a few work days for your accounts to be approved.

### First time logon and setup
- After you got the approvement email from ITS, log into your account from your terminal, example 
``` sh
ssh _yourNetid_@farnam.hpc.yale.edu
```

- After you log onto the cluster, paste the following lines:
    ```sh
    cmdLine='PATH="/home/zl99/code/ngs/pipelines:$PATH"'
    [[ -n $(grep '/home/zl99/code/ngs/pipelines:$PATH' ~/.bashrc) ]] || echo $cmdLine >> ~/.bashrc
    ```
    You can then exit by type `exit`.

Note for the HPC folders: 
    - project: 4T for the lab
    - scratch60: 10T for the lab, files stored here will be automaticly deleted after 60 days
    - In the following examples, most of results are stored under your scratch60 folder. See [FAQs](#faqs) to find how to backup/synchronize to your computer using `rsync`.
    

## 3. Run RNA-Seq pipelines on a yale HPC cluster
- Log onto a specific head node from your local terminal, example:
```
ssh -X _yourNetid_@farnam2.hpc.yale.edu
```

- Optional: Run tmux 
    ```sh
    tmuxa
    ```
    Note: We are using tmux primarily to keep your working processes running after you disconnect from the cluster. To detach from tmuxa, type ctrl-b then d. For more 'advanced' usage like tabs and panes, see my brief introduction to tmux in [FAQs](#faqs).
- To run one of the pipelines, request an interactive computing node with 8 CPUs, each with 4Gb Memory:
    ```sh
    srunI
    ```
    Note: your will be kicked out of the the computing node after the 'walltime', which default to be 24 hours. 
- Then prepare the dependicies of the pipelines, on the computing node
    ```sh
    source load_pipelines
    ```
### Mapping: Bowtie2 local single-end mapping pipeline
Generate a gene x sample read counts matrix for your project.

#### Optional: Test with the example project
- Set the parameters: paste the following lines in a computing node
    ```sh
    # set up the projectDir and genome
    projectDir="/home/zl99/project/Project_Test1M"
    genome="hg38"
    ```
- Run the pipeline, output to a new folder under scratch60:
    ```sh
    # make a new folder in scratch60, cd there and do the mapping
    outDir="$HOME/scratch60/$(basename $projectDir).bowtie2"
    mkdir $outDir && cd $outDir && bowtie2localSeBatch $genome $projectDir
    ```
    It will take a few minutes.
- Optional: check the output of the pipeline. Examples:
    ```sh
    ls -l
    less geneCount.csv #q to quit
    ls -l */*.bam
    ```
    you can check the pipeline documents below for details.
    
#### Run your own project
- Follow link provided by the sequencing center, copy the link address of your project. Example:
![copy the link to your sequence project](copy-seq-project-link.png), Then type
```sh
# extract the projectDir from the link address
projectDir=$(echoProjectDir '_pastehere_')
genome=_genome_ # hg38 or mm10
```
- Then paste the following to run the pipeline. It takes much longer, your might wait overnight.
    ```sh
    # make a new folder in scratch60, cd there and do the mapping
    outDir="$HOME/scratch60/$(basename $projectDir).bowtie2"
    mkdir $outDir && cd $outDir && bowtie2localSeBatch $genome $projectDir
    ```
- Tranfer the results to your computer: 
    - construct the rsync command on the cluster terminal: paster the following lines and copy the output:
       ```sh
       tmp=$USER@${HOSTNAME%%[0-9].*}.hpc.yale.edu
       echo "rsync -azvuP $tmp:$outDir ."
       ```
       .. Tip: to figure out the size of the outDir, type `cd $outDir; du -hs`.
    - open **your local terminal on your laptop** (Babun for windows, terminal for OSX), then type the following
        ```sh
        cd "_targetDir_"
        _pasteHere_
         ```
       .. Tip: instead of typing, you can drag a folder to your terminal window. 

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
    # cd to mappingDir and set contrasts
    cd "~/scratch60/Project_Test1M.bowtie2" #output directory of the mapping pipeline
    contrasts="A-B" #example of multiple contrasts: constrasts="A-Ctrl,B-Ctrl"
    ```
- Run pipeline, output to a new folder under your mappingFolder
    ```sh
    # run pipeline, output to a new folder ./deseq2
    mkdir deseq2; cd deseq2
    deseq2ContrastBatch ../geneCount.csv ../sampleInfo.csv $contrasts
    ```
#### Run your project
- Set your mappingDir and set contrasts:
    ```sh
    cd _your/mappingdir_
    contrasts="_yourContrasts_"  #example: "A-Ctrl,B-Ctrl"
    ```
- Create/upload your own sampleInfo.csv file to your mappingDir (check the format in the pipeline document below): for example
    ```sh
    ls -d Sample* > sampleInfo.csv
    nano sampleInfo.csv
    ```
    See an example file [here](https://raw.githubusercontent.com/zz2liu/RnaSeq-HpcPipelines/master/sampleInfoExample.csv).

- Run the pipeline:
    ```bash
    mkdir deseq2 && cd deseq2 && deseq2ContrastBatch ../geneCount.csv ../sampleInfo.csv $contrasts
    ```
- Download the results to your computer, as demonstrated in the mapping pipeline.

#### Pipeline Document
- Usage: `deseq2ContrastBatch <geneCountFile> <sampleInfoFile> <contrast1>[,<contrast2>[,...]]`
- Arguments:
    - geneCountFile: a csv file with raw read counts of geneID x sampleName
    - sampleInfoFile: a csv file with sample info. The first two columns are required, and the first row will be ignored.
        - sampleName should match that of geneCountFile
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
Reference: http://bioinf.wehi.edu.au/RNAseqCaseStudy/

## FAQs
### How to synchronize files with the cluster?
You can use rsync, comes with the terminal on your computer. For example:
- set your remoteDir, localDir to synchronize <pre>
remoteDir="<ins>yourNetid@farnam.hpc.yale.edu:scratch60</ins>"
localDir="<ins>~/scratch60</ins>"</pre>
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

### How to bulk download raw sequencing data from Yale Center for Genome Analysis (YCGA) on West campus or Yale Stem Cell Center?
- Get an account on farnam (for YSCC) and/or ruddle (for YCGA). See [Request an account](#request-an-account).
- Prepare the unix termial on your computer. See [Prepare your local terminal](#1-prepare-the-unix-terminal-on-your-laptopdesktop)
- Follow the download link provided in their email, copy the link address of your project. Example:
![copy the link to your sequence project](copy-seq-project-link.png)
    - An example from YCGA: `http://sysg1.cs.yale.edu:2011/gen?fullPath=gpfs_illumina/sequencerS/runs/.../Data/Intensities/BaseCalls/Unaligned/Project_xxx&dirName=...`
    - An example from YSC: `http://futo.cs.yale.edu:16023/genRFLForm.rpy?fullPath=/ysm-gpfs/pi/haifan_lin/.../Project_xxx&dirName=Project_xxx`
- set a target folder with enough disk space
```sh
    cd _yourTargetFolder_ 
```
Tip: you can drag a folder on your computer (including external drive) to the terminal window after typing `cd `

- set the netid and projectLink 
```sh
    projectLink="_pastehere_"
    netId=_yourNetId_
```
- Download with rsync: just paste the following lines
    ```sh
    usage() {
        echo 'Usage: PROG <netid> <projectDir>'
        exit 0
    }

    echoProjectHostDir() {
        if [[ $projectLink =~ 'haifan_lin' ]]; then   #from farnam
            echo $projectLink | sed -E 's/.*fullPath=(.*)&.*/farnam.hpc.yale.edu:\1/'
        else  #from ruddle
            echo $projectLink | sed -E 's/.*fullPath=(.*)&.*/\1/;s%gpfs_illumina%ruddle.hpc.yale.edu:/sequencers/illumina%'
        fi
    }

    downloadYaleSeqHere() { #globals: netid, projectLink
        #echo $# $@
        [[ $# == 2 ]] || usage
        netid=$1
        projectLink=$2
        HostDir=$(echoProjectHostDir)
        if [[ $HOSTNAME == *"${HostDir%%.edu*}" ]]; then
            rsync -azvP --exclude='*.fastq' "${HostDir#*.edu:}" .
        else
            rsync -azvP --exclude='*.fastq' "$netid@$HostDir" .
        fi
    }

    downloadYaleSeqHere $netid "$projectLink"

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

### Familiarize yourself with basic linux concepts and commands
This might looks overwhelming if your never use linux terminal, but it is rewarding. Set aside one hour to follow the tutorial to see how far you can go, you might find yourself at the end of the tutorial before the hour run off.
- [Command-line Bootcamp](http://rik.smith-unna.com/command_line_bootcamp) might be a good start.
- [See another tutorial here](http://www.ee.surrey.ac.uk/Teaching/Unix/index.html).

Excercise with the very basic linux commands (program + options + arguments), type each command except the <span><ins>italized part</ins></span> (you should act on it) and the comment (after #), followed by an enter.
- list the folders and files: ls
<pre>
ls
ls -l #long form: filesize, last modified time
ls -la #see the hidden: ., .., .ssh
ls --help
man ls
</pre>
Tip of man: / to search; arrows to navigate; q to quit

- navigate in the tree: cd
<pre>
pwd  #find where you are
cd /  #go to root
ls -l
cd ~  #go to home, or just type cd
cd <ins>drag a folder from your file manager</ins> #go to a local folder
</pre>

- moving things around: mkdir, mv, cp
<pre>
cd
mkdir RnaseqTutorial
cd Rna<ins>click tab on yourkeyboard for autocompletion</ins>
cp ~/.ssh/id_rsa.pub . #. is for current directory
cd .. #.. is for parent directory
mv RnaseqTutorial ~/Downloads
ls ~/Downloads | less  # | is called pipe. less is file viewer 
</pre>
Tip of less: / to search; arrows to navigate; q to quit

### How to move and rename nested files to one folder?
- You can use a for loop, for example
  ```
  # move each sorted.bam.bw in the subfolders to the current folder and rename as the_subfolder.bw
  for f in */*.bw; do mv $f ${f/\/sorted.bam/}; done
  ```
  - `${string/pattern/replacement}` is a [bash string manipulation](http://www.thegeekstuff.com/2010/07/bash-string-manipulation). The pattern will be deleted without replacement.

### How to filter the gene count data by an arbitrary criteria?
You can do this in a spreadsheet.  An autofilter following [countif function](https://www.ablebits.com/office-addins-blog/2014/07/02/excel-countif-examples/) might suffice.


