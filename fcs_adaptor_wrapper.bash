#!/bin/bash
# USAGE:fcs_adaptor_wrapper.bash -f fasta2.gz -o outdir
#

usage() { 
cat << EOF
Usage: $0 [REQUIRED -f input.fasta, -o outputdir]
REQUIRED:
	-f [file] gzipped Fasta file
	-o [dir]  output directory
OPTIONAL:
	-h show this help
EOF
	exit 1
}

while getopts "f:ho:" opt; do
    case $opt in
        f ) FASTA=`realpath $OPTARG`;;
	o ) OUTDIR="$OPTARG";;
	h | *) usage;;
    esac
done

SINGULARITY=/lustre/scratch123/tol/teams/grit/mh6/singularity/fcs-adaptor.0.3.0.sif

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir -p $OUTDIR

bash $SCRIPT_DIR/run_fcsadaptor.sh --fasta-input $FASTA --output-dir $OUTDIR --image $SINGULARITY --container-engine singularity --euk
