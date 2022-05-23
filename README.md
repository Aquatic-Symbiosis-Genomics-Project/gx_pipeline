# gx_pipeline
wrapper for the [NCBI GX pipeline](https://ftp.ncbi.nlm.nih.gov/pub/murphyte/FCS/FCS-genome/fcs_genome_readme.html)

These are wrappers to run the Singularity version of the NCBI GX pipeline at Sanger

Dear Singularity users,
 
Due to popular demand, we have adapted our FCS-genome tool to work with Singularity. This is an early version that we’re making available to get early feedback. It’s built from our latest codebase with a number of improvements over the currently posted Docker version.
 
Please follow the instructions below, and let us know if it works for you or you run into any problems.
 
For documentation on output and other technical information, please refer to the FCS-genome README (https://ftp.ncbi.nlm.nih.gov/pub/murphyte/FCS/FCS-genome/fcs_genome_readme.html).
 
Prerequisites
 
1. FCS-genome is available as a Singularity image. Please ensure Singularity is installed on your terminal, and use Python 3.7 or higher to run FCS-genome.
2. A FASTA file.
3. The taxid of the organism
4. Technical requirements:
  A host with sufficient shared memory to hold the database and accessory files (approximately 460 GiB). Execution can utilize up to 48 CPU cores.
  A Google Cloud Platform (GCP) host such as n2-highmem-64 (64 vCPUs, 512GB) is sufficient for execution. Optionally, sufficient disk space to save
  a local copy of the database files (approximately 460 GB) should avoid repeated downloads from NCBI's FTP site.
 
Quickstart
1) Log into your terminal where Singularity is installed. The current image is made using Singularity v3.4.0.
2) Retrieve the run_fcsgenome script, Singularity image and an example FASTA file from the FCS FTP server.
curl -o run_fcsgenome.py https://ftp.ncbi.nlm.nih.gov/pub/murphyte/FCS/FCS-genome/singularity/run_fcsgenome.py
curl -o fcs-genome.sif https://ftp.ncbi.nlm.nih.gov/pub/murphyte/FCS/FCS-genome/singularity/gx-develop-latest.sif
curl -o fcsgenome_test.fa.gz https://ftp.ncbi.nlm.nih.gov/pub/murphyte/FCS/FCS-genome/examples/fcsgenome_test.fa.gz
 
3) Create a temporary shared memory.
SHM_LOC=/mnt/shm
sudo mkdir -p "$SHM_LOC"
sudo mount -t tmpfs -o size=460g tmpfs "$SHM_LOC"
 
4) Create a directory in your shared memory space. This is where the working copy of the FCS-genome database (GX database) will be stored.
Use the path generated in the previous step:
mkdir -p "${SHM_LOC}/gxdb"
 
3-4 alternative)
In lieu of using shared memory, you can set SHM_LOC=<disk path>
This mode still requires a high-mem server, but will compensate by memory mapping the database at the beginning of the run, basically caching it into memory on the fly. This takes extra time, but doesn’t require sudo permissions.
 
5) Create a directory to store a local backup copy of the FCS-genome database.
The complete all (~500GB) and testing test-only (~5GB) database files will be automatically downloaded once from the NCBI website to this location,
so please ensure you have enough free storage space:
mkdir -p ./gxdb
 
6) Create a directory to store the output of the program.
mkdir -p ./gx_out
 
7) Parameterize and run the run_fcsgenome.py script.
The shared memory database and the local backup database paths are specified using --gx-db and --gx-db-disk, respectively.
The script checks the shared memory path for the database and, if needed, loads it from the local backup database path.
 
Verify functionality by using a small test-only database:
python3 ./run_fcsgenome.py --fasta ./fcsgenome_test.fa.gz --out-dir ./gx_out/ --gx-db "${SHM_LOC}/gxdb/test-only" --gx-db-disk ./gxdb --split-fasta --tax-id 6973 \
--container-engine=singularity --image=fcs-genome.sif
 
For normal runs, use the complete all database:
python3 ./run_fcsgenome.py --fasta ./fcsgenome_test.fa.gz --out-dir ./gx_out/ --gx-db "${SHM_LOC}/gxdb/all" --gx-db-disk ./gxdb --split-fasta --tax-id 6973 \
--container-engine=singularity --image=fcs-genome.sif
 
Note: Downloading and copying to shared memory may require extensive waits due to the large file sizes. These downloads and copies may be monitored with:
ls -hlt ./gxdb
and:
ls -hlt ${SHM_LOC}/gxdb
Note: If you are running this program on a dedicated machine such as a cloud VM, you may not require a backup of the database stored on disk.
To skip making a local copy, simply omit the --gx-db-disk parameter.
 
8) Inspect the output file:
head -n 5 gx_out/fcsgenome_test.6973.taxonomy.rpt
Output content should closely match the example output found in the FTP repository:
https://ftp.ncbi.nlm.nih.gov/pub/murphyte/FCS/FCS-genome/examples/fcsgenome_test.6973.taxonomy.rpt
and
https://ftp.ncbi.nlm.nih.gov/pub/murphyte/FCS/FCS-genome/examples/fcsgenome_test.6973.fcs_genome_report.txt
 
9) Apply run_fcsgenome.py to additional genomes you wish to screen. Once you have finished screening, you may remove the database from shared memory:
rm -rf "${SHM_LOC}/"
 
 
Known bugs:
When using --gx-db-disk ./gxdb option, and when the db is already present in ./gxdb, the program errors out if there is not enough space in ./
If this happens, just skip this parameter, and proceed to download to shared memory using only the --gx-db parameter.
