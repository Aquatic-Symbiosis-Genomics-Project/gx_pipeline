#!/bin/bash
# USAGE:gx_mapper_wrapper.bash -f fasta1.gz -f fasta2.gz -o outdir -t taxid ... or something
# * use like that: bsub -q normal -o lsf.log -M 128000 -n 48 -R'select[mem>128000, tmp>500G] rusage[mem=128000, tmp=600G]' gx_wrapper.bash -f /my/fasta.fa.gz -o /my/outdir/ -t 1234
# * as /tmp tends to be either SSD or tmpfs, there is a likelyhood, that we can get away with specifying less memory in the bsub 
# * uses realpath , which should be installed at Sanger by default

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

export LOCAL_DB=/lustre/scratch124/tol/projects/asg/sub_projects/ncbi_decon/0.4.1
export FCS_DEFAULT_IMAGE=/lustre/scratch123/tol/teams/grit/mh6/singularity/fcs-gx.0.4.1.sif

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export GX_PREFETCH=0 
export GXDB="/tmp/gx_mapper_$USER/$$"
mkdir -p $GXDB

python3 ${SCRIPT_DIR}/fcs.py db get --mft "${LOCAL_DB}/all.manifest" --dir $GXDB

for file in "${multi[@]}"; do
	fasta=`realpath $file`
	# check if file does exist
	if [[ -f $fasta ]]; then
                python3 $SCRIPT_DIR/fcs.py screen genome --fasta $fasta --out-dir $OUTDIR --gx-db $GXDB --tax-id $TAXID 
	else
		echo "$fasta doesn't exist"
	fi
done
chmod g+w $OUTDIR/*fcs_gx_report.txt $OUTDIR/*taxonomy.rpt

rm -rf $GXDB
