#!/bin/bash
# USAGE:gx_mapper_wrapper.bash -f fasta1.gz -f fasta2.gz -o outdir -t taxid ... or something
# * use something like that: bsub -q normal -o lsf.log -M 128000 -n 48 -R'select[mem>128000, tmp>500G] rusage[mem=128000, tmp=600G]' gx_wrapper.bash -f /my/fasta.fa.gz -o /my/outdir/ -t 1234
# * as /tmp tends to be either SSD or tmpfs, there is a likelyhood, that we can get away with specifying less memory in the bsub 
# * uses realpath , which should be installed at Sanger by default
# * a copy of /app/bin is kept at /lustre/scratch123/tol/teams/grit/mh6/ncbi-decon/bleh/ , so it can be mounted r/w later
# * $DISK is where the database is stored
# * original docker image is here: https://hub.docker.com/r/ncbi/cgr-fcs-genome

usage() { 
cat << EOF
Usage: $0 [REQUIRED -f input.fasta, -t taxonid -o outputdir]

REQUIRED:
	-f [file] gzipped Fasta file (can be specified more than once)
	-t [int]  NCBI taxonomy id
	-o [dir]  output directory
OPTIONAL:
	-h show this help
EOF
	exit 1
}

while getopts "f:t:ho:" opt; do
    case $opt in
        f ) multi+=("$OPTARG");;
        t ) TAXID=$OPTARG;;
	o ) OUTDIR=`realpath $OPTARG`;;
	h | *) usage;;
    esac
done

DISK=/lustre/scratch124/tol/projects/asg/sub_projects/ncbi_decon
SINGULARITY=/lustre/scratch123/tol/teams/grit/mh6/singularity/cgr-fcs-genome.sif

# speed up things
GXDB="/tmp/gx_mapper/$$"
mkdir -p $GXDB
cp $DISK/* $GXDB/

# so it can run in parallel
mkdir -p $GXDB/bin
cp -r /lustre/scratch123/tol/teams/grit/mh6/ncbi-decon/bleh/* $GXDB/bin

for file in "${multi[@]}"; do
	fasta=`realpath $file`
	# check if file does exist
	if [[ -f $fasta ]]; then
		FASTADIR=${fasta%/*}
		FASTANAME=${fasta##*/}

		singularity exec -B $GXDB/bin:/app/bin,$GXDB:/app/db/gxdb,$FASTADIR:/sample-volume,$OUTDIR:/output-volume $SINGULARITY python3 /app/bin/run_gx --fasta /sample-volume/$FASTANAME --out-dir /output-volume --gx-db /app/db/gxdb/all --tax-id $TAXID --debug --split-fasta
	else
		echo "$fasta doesn't exist"
	fi
done

rm -rf $GXDB
