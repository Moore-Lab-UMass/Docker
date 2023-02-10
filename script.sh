#!/bin/bash
set -e

#SBATCH --nodes 1
#SBATCH --time=60:00:00
#SBATCH --mem=10G
#SBATCH --output=~/Job-Logs/jobid_%A.output
#SBATCH --error=~/Job-Logs/jobid_%A.error
#SBATCH --partition=5days

mainDir=/home/USERNAME/project
dataDir=/data/LAB/USERNAME/data
tmpDir=/tmp/USERNAME/project
resultsDir=$mainDir/results

MINWAIT=10
MAXWAIT=120

# sleep to give the server some relief (reallocate memory)
sleep $((MINWAIT+RANDOM % (MAXWAIT-MINWAIT)))

# make sure there is no dangling /tmp folder
echo "Check for dangling data..."
rm -rf $tmpDir 

# make /tmp and navigate to it
echo "Creating /tmp..."
mkdir -p $tmpDir 
cd $tmpDir

# copy and unzip input files in /tmp
echo "Copying input files..."
cp $dataDir/input_data.tar.gz .

echo "Unzipping annotations..."
tar -xzf input_data.tar.gz

# sleep
sleep $((MINWAIT+RANDOM % (MAXWAIT-MINWAIT)))

# execute files using a singularity image
singularity exec -B $dataDir:/data REPO_TAGNAME.sif python3 hello-world.py > output.txt

singularity exec -B $dataDir:/data \
    --env PYTHONPATH=/ /home/USERNAME/bin/ldr.sif python3 \
    -m ldr.h2 \
    --ld-scores Annotations \
    --ld-prefix all \
    --weights /home/USERNAME/data/ldr/weights \
    --weights-prefix weights.hm3_noMHC \
    --frequencies /home/USERNAME/data/ldr/1000G_Phase3_frq \
    --frequencies-prefix 1000G.EUR.QC \
    --snp-list /home/USERNAME/data/ldr/w_hm3.snplist \
    --summary-statistics /home/USERNAME/data/ldr/sumstats/$trait.sumstats.gz \
    --print-coefficients \
    --skip-munge > output.txt

# you can also wrap scripts with sbatch instead of the sbatch headers
for x in $(cat halLiftover-L.txt | cut -f1); do 
    echo $x; 
    sbatch -N 1 \ 
        -nodes 24 \ 
        -time 240 \ 
        --mem=90G \
        -partition 4hours \
        -J $x \
        -error /home/USERNAME/logs/$x.err \
        -output /home/USERNAME/logs/$x.out \
        --wrap="bash run.sh $x"; 
    sleep 5; done

# copy results and remove /tmp
echo "Copying results..."
cp output.txt $resultsDir/$trait.txt

echo "Removing /tmp..."
cd $mainDir
rm -rf $tmpDir

echo "Done!"