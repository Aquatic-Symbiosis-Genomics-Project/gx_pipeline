#!/bin/bash
# USAGE: terrance.bash fasta outdir
# * uses /tmp to store the db
# * runs on the test database
# * uses pwd as additional db storage
# * replace the test-only with all and experience a terabyte download
# * taxid is the one of the target species, all other hits will be reported
# * the thing writes into /app/bin which is read-only in Singulrity, so i pulled the binaries out and mount the directory r/w (which is bad)

prepend_path MODULEPATH /software/modules/
module load ISG/singularity/

SINGULARITY_TMPDIR=/lustre/scratch123/tol/teams/grit/mh6/singularity/
SINGULARITY_CACHEDIR=$SINGULARITY_TMPDIR

DB=all
FASTADIR=${1%/*}
FASTANAME=${1##*/}

echo "FASTADIR $FASTADIR"
echo "FASTANAME $FASTANAME"

OUTDIR=$2
SIF=/lustre/scratch123/tol/teams/grit/mh6/singularity/cgr-fcs-genome.sif
GXDB=/lustre/scratch124/tol/projects/asg/sub_projects/ncbi_decon
DISK=/lustre/scratch124/tol/projects/asg/sub_projects/ncbi_decon
SINGULARITY=/lustre/scratch123/tol/teams/grit/mh6/singularity/cgr-fcs-genome.sif
TAXID=$3

# could be submitted with [select tmp>500000] rusage[tmp=500000]

# docker run --name retrieve_db -v $GXDB:/app/db/gxdb cgr-fcs-genome python3 /app/bin/retrieve_db --gx-db /app/db/gxdb/test-only
singularity exec -B $GXDB:/app/db/gxdb,$DISK:/db-disk-volume $SINGULARITY python3 /app/bin/retrieve_db --gx-db /app/db/gxdb/$DB --gx-db-disk /db-disk-volume/

# docker run --name run_gx -v $GXDB:/app/db/gxdb -v $FASTADIR:/sample-volume -v $OUTDIR:/output-volume ncbi/cgr-fcs-genome:v1alpha1-latest python3 /app/bin/run_gx --fasta /sample-volume/fcsgenome_test.fa.gz --out-dir /output-volume --gx-db /app/db/gxdb/test-only --tax-id 6973 --debug --split-fasta
# singularity exec -B /lustre/scratch123/tol/teams/grit/mh6/ncbi-decon/bleh:/app/bin,$GXDB:/app/db/gxdb,$FASTADIR:/sample-volume,$OUTDIR:/output-volume $SINGULARITY python3 /app/bin/run_gx --fasta /sample-volume/$FASTANAME --out-dir /output-volume --gx-db /app/db/gxdb/$DB --tax-id $TAXID --debug --split-fasta
