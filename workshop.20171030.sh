# from your labtop terminal
###############################################################
ssh netid@ruddle1.hpc.yale.edu
#> [ruddle1 ~]


# from cluster head node
###############################################################
srunI
#> [zl99@c23n07 ~]


# from the computing node 
###############################################################
## prepare workspace
. load_pipelines
cd scratch60
mkdir tmpTurorial
cd tmpTurorial/

## mapping and counting
projectDir=$pipelinesDir/Project_testSmall
genome=hg38  #mm10 also available
bowtie2localSeBatch $genome $projectDir
# Note for your own project, find you own projectDir here:
# YCGA: http://research.computing.yale.edu/support/hpc/clusters/ruddle
# it may take overnight with the current pipeline, so keep connected.

## differential expression
cp $pipelinesDir/Project_testSmall/sampleInfo.csv .
contrasts=A-B,B-A
deseq2ContrastBatch geneCount.csv sampleInfo.csv $contrasts
# Note for your own project: your can create a template for sampleInfo.csv with
# the following line, then edit the group col and contrasts accordingly
# ls $projectDir | grep 'Sample_' | sort -V | sed -E 's%$%,A%' | sed '1isample,group' > sampleInfo.csv

## get the transfer command
tmp=$USER@${HOSTNAME%%[0-9].*}.hpc.yale.edu
echo "rsync -azvuP $tmp:$PWD ."


# transfer files to laptop: from laptop terminal
################################################################
cd '__drag a folder with enough space here__'
#__paste the rsync command here__

