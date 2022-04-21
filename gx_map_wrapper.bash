#!/bin/bash
# USAGE:gx_mapper_wrapper.bash -f fasta1 -f fasta2 -o outdir -t taxid ... or something
# * use something like that: bsub -q long -o lsf.log -M 683000 -n 48 -R'select[mem>683000, tmp>500G] rusage[mem=683000, tmp=600G]' gx_wrapper.bash -f /my/fasta.fa.gz -o /my/outdir/ -t 1234
# * as /tmp tends to be either SSD or tmpfs, there is a likelyhood, that we can get away with specifying less memory in the bsub 
# * uses realpath , which should be installed at Sanger by default

usage() { 
cat << EOF
Usage: $0 [REQUIRED -f input.fasta, -t taxonid -o outputdir]

REQUIRED:
	-f [file] Fasta file (can be specified more than once)
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

for f in "${multi[@]}"; do
	fasta = `realpath $f`
	# check if file does exist
	if [[ ! -f $fasta ]]; then
		echo "$fasta doesn't exist"
		rm -rf $GXDB
		exit 1
	fi
	
	FASTADIR=${fasta%/*}
	FASTANAME=${fasta##*/}

	singularity exec -B $GXDB/bin:/app/bin,$GXDB:/app/db/gxdb,$FASTADIR:/sample-volume,$OUTDIR:/output-volume $SINGULARITY python3 /app/bin/run_gx --fasta /sample-volume/$FASTANAME --out-dir /output-volume --gx-db /app/db/gxdb/all --tax-id $TAXID --debug --split-fasta
done

rm -rf $GXDB
