#THIS IS A TEST REPOSITORY FROM https://gitlab.com/barker-lab/EvoPipes . This instance is intended to be used on HPC systems and singularity. Please refer to source gitlab page for information about the original pipeline. 

# EvoPipes Pipeline Collection

This repository contains the scripts for the core EvoPipes pipelines: DupPipe, OrthoPipe, and TransPipe. Also included is a link to a docker image that contains a working version of these pipelines and is the recommended way for most people to use the tools. 

### EvoPipes Docker - Quick Use Guide ###
---

To provide an easy and quick way for users to get up and running with the EvoPipes collection of tools, we have made a docker of the server that should be quick and easy to run. 
EvoPipes is a collection of relatively small scripts that perform different jobs, sometimes using external tools (e.g., BLAST). The pipelines
are simply another script that calls each of these scripts and tools to perform the analysis. Given that each user environment is different, it
can be tricky to deploy all of these scripts and tools. To overcome these issues and make EvoPipes easier to get up and running, we recommend users
install EvoPipes using Docker which will provide a working version of the pipelines and scripts regardless of the host operating system.

**Docker Installation**
Before installing and running EvoPipes from Docker, users will need to install Docker for their system. You can find out more about installing Docker for your particular OS here: https://docs.docker.com/get-docker/

Once Docker is installed on your system, you can download the EvoPipes docker image using the following command (note that you may need to use "sudo" to execute this and other Docker commands on some systems):

`docker pull msbarker/evopipes:evopipes`




**Running EvoPipes from Docker**
Each of the EvoPipes pipelines can be run from Docker using the same basic syntax (again, "sudo" may be necessary to execute the Docker):

`docker run -u $(id -u) -v $(pwd):/home msbarker/evopipes:evopipes <pipelinename.pl> ARG0 ARG1 CPU#`


If you execute the EvoPipes docker with above command, it will use your current working directory as "home" inside of the container and will create files and folders in this location for each pipeline run. The required input for each pipeline (see below) should be located in your current working directory so the EvoPipes scripts in the container locate them. Each of the pipelines take the desired CPU number for the analysis as the last argument. This CPU usage will only apply to some steps of the pipeline that can leverage multiple CPUs. Also note that each pipeline will check your machines current CPU usage to asses if it can run without using more CPUs than currently available. If the load is too high, it will sleep for a minute and check again until their is enough overhead to run the pipeline.

Below are the directions for running each of the core EvoPipes pipelines with the Docker.

---

*Running DupPipe*

To run the DupPipe pipeline, you need to have prepared three sets of input files:

1. The assembled transcriptome/RNAseq or annotated CDS files in fasta format in your current working directory.

2. A simple text file that lists each of the file names you want DupPipe to analyze. Each filename should be on its own line. DupPipe will run on each of these data sets in series. 

3. Provide a collection of protein sequences in fasta format that will be used for translations in the pipelines. We recommend using a broad protein collection, such as all annotated proteins from related reference genomes. For example, we typically use proteins from all of the available plant genomes on JGI for our analyses to esnure protein space is well represented in the database. 

After pulling together these files and placing them in the same working directory, you will also need to indicate on the command line how many CPUs to use. This will depend on the available CPUs on your system and you will not want to use more than are currently available! Once you have these three sets of input, you can run DupPipe using the following command (again "sudo" may be necessary):

`docker run -u $(id -u) -v $(pwd):/home msbarker/evopipes:evopipes duppipe.pl list_file_name protein_file_name CPU#`

The pipeline will make a directory named "DupPipe" in your current working directory. Within this directory, additional directories will be made for each of the datasets analyzed. Inside these directories will be "Data" and "Output" directories that contain the files. Most users will be interested in the "final_ks_NAME" file in the "Output" directory. This contains the type of results used in most published DupPipe analyses. A more complete description of pipeline output can be found in the section below.

---

*Running OrthoPipe*

To run the OrthoPipe pipeline, you need to have prepard three sets of input files:

1. The assembled transcriptome/RNAseq or annotated CDS files in fasta format in your current working directory. For this pipeline, each of these should be named with a unique three letter code followed by ".unigenes". This three letter code will distinguish genes from this species in the analyses.

2. A simple text file that lists each of the ortholog analsyes you want OrthoPipe to analyze. Each line of species codes will be an independent analysis. The three letter code for each species should be used with a space between codes for an analysis (e.g., arg ann lat ). OrthoPipe will run on each of these data sets in series. 

3. Provide a collection of protein sequences in fasta format that will be used for translations in the pipelines. We recommend using a broad protein collection, such as all annotated proteins from related reference genomes. For example, we typically use proteins from all of the available plant genomes on JGI for our analyses to esnure protein space is well represented in the database. 

After pulling together these files and placing them in the same working directory, you will also need to indicate on the command line how many CPUs to use. This will depend on the available CPUs on your system and you will not want to use more than are currently available! Once you have all of these inputs, you can run OrthoPipe using the following command (again "sudo" may be necessary):

`docker run -u $(id -u) -v $(pwd):/home msbarker/evopipes:evopipes orthopipe.pl list_file_name protein_file_name CPU#`

The pipeline will make a directory named "OrthoPipe" in your current working directory. Within this directory, additional directories will be made for each of the analyses with the three letter codes for each species grouped together (e.g., arg_an_lat). Inside the will be an "Output" directory that contains the results. Most users will be interested in the "codeml_output#NAMES" file. Each row of this file contains a set of reciprical best BLAST hit orthologs for the input data including Ka/Ks estimates from PAML. There will also be a "hit_parser" directory created that will contain a list of previously parsed pairwise orthologs for a set of taxa.  A more complete description of pipeline output can be found in the section below.


---

*Running TransPipe*

To run the TransPipe pipeline, you need to have prepared three sets of input files:

1. The assembled transcriptome/RNAseq or annotated CDS files in fasta format in your current working directory.

2. A simple text file that lists each of the file names you want TransPipe to analyze. Each filename should be on its own line. TransPipe will run on each of these data sets in series. 

3. Provide a collection of protein sequences in fasta format that will be used for translations. We recommend using a broad protein collection, such as all annotated proteins from related reference genomes. For example, we typically use proteins from all of the available plant genomes on JGI for our analyses to esnure protein space is well represented in the database. 

After pulling together these files and placing them in the same working directory, you will also need to indicate on the command line how many CPUs to use. This will depend on the available CPUs on your system and you will not want to use more than are currently available! Once you have these three sets of input, you can run TransPipe using the following command (again "sudo" may be necessary):

`docker run -u $(id -u) -v $(pwd):/home msbarker/evopipes:evopipes transpipe.pl list_file_name protein_file_name CPU#`

The pipeline will make a directory named "Translated" in your current working directory. Within this directory, additional directories will be made for each of the datasets analyzed. Inside these directories will be an "Output" directory that contains the results files. Most users will be interested in the "\*.faa" and the "\*.fna" files. These are the amino acid (.faa) translations and paired nucleic acid (.fna) sequences in fasta format. A more complete description of pipeline output can be found in the section below.



### Local Installation ###
---

To install the EvoPipes pipelines locally, it is recomended that users are running a linux operating system. Users running apple or microsoft operating systems should use the Docker version above to run the pipelines locally. Linux users installing locally are assumed to understand how to install dependencies and have sudo/root priviliges.

Before installing the EvoPipes scripts, please install the following dependencies. You may wish to install from official repositories, or download from project websites as needed for your system. I recommend installing from the official repositories because it is much easier!

- NCBI BLAST+ (https://packages.ubuntu.com/focal/ncbi-blast+)

- Muscle (https://packages.ubuntu.com/focal/muscle)

- BioPerl (https://packages.ubuntu.com/focal/bioperl)

- Genewise (https://www.ebi.ac.uk/seqdb/confluence/display/THD/GeneWise)

- Paml (https://packages.ubuntu.com/focal/paml)

- RevTrans (https://gitlab.com/barker-lab/RevTrans_Python3)


Once these dependencies are installed, download all of the scripts in the "scripts" directory (https://gitlab.com/barker-lab/EvoPipes/-/tree/master/scripts) and chmod to 755. Next, copy them into /bin. If you wish to install these in another location on your machine, it should work fine although you may run into path issues with some scripts that look for code in /bin (e.g., iterativegenewise.pl). You should be able to run each of these scripts as described above in the docker section, but locally by just dropping the docker specific syntax (e.g, just "duppipe.pl list_file protein_file CPU#"). Similar to the docker execution above, you will need to have the necessary input files in your current working directory for the pipelines to execute properly.


### Pipeline Examples & Output ###
---

Example input files for each of the pipelines are included in the "examples/example_input" directory. Example output of EvoPipes pipeline runs are available in the "examples/evopipes_test" directory. Users may use the example data and lists to test out their own installations of EvoPipes. The "arg.unigenes" file is a subset of the Helianthus argophyllus transcriptome (Barker et al. 2008 http://dx.doi.org/10.1093/molbev/msn187), the "pla.unigenes" file is an assembly of the Plantago lanceolata transcriptome (Marx et al. 2020 https://doi.org/10.1101/2020.03.31.018945), and the "test_prots.fasta" file is a small collection of amino acid sequences for testing the pipelines. The "list" file is an example of the text file input to run DupPipe and TransPipe. The "list2" file is an example of the text file input to run OrthoPipe. 


*Screen/stdout Messages*

Each of the pipelines will produce a series of messages on the screen as it runs (unless you have directed stdout to a log file). There will be messages about BLAST searches starting, alignments, genewise results, and paml results. Interspersed among these messages will be errors. These are due to, for example, pairs of sequences in DupPipe that were ultimately failed a length or other quality filtering step in the middle of the pipeline, but due to the bookkeeping the pipeline continues to look for that pair at later steps. It will produce these sporadic errors on stdout when the programs called at different steps can't find the sequences, alignments, or other files it is expecting. If there is a pipeline failure, you will see empty files in the "Output" directory.

---

*DupPipe Output*

The primary output from the DupPipe pipeline will be located in the /DupPipe/TAXON/Output directory. The file of most interest is the "final_ks_values_TAXON" file. This contains the Ks values for duplication events in gene family clusters within the data set. In this output, Ks is calculated using a simple distance matrix from a single linkage clustered gene family. The first two columns - "branch1" and "branch2" - indicate the two halves of the branches in these clusters with "_x_" indicating different members of the cluster. This is similar to the nested layers of a Newick formatted tree. The Ks value on this row corresponds to the value estimated at that node in the tree. The "Largest SE" is the larget standard error for a Ks estimate from PAML in this part of the cluster. "ATH Annotation" is the best hitting protein from Arabidopsis thaliana to this gene family cluster. This is mostly a legacy results column and should be largely ignored because more sophisticated annotation approaches are now available that should be used! Similarly, the "GenBank Annotation" columns are a legacy result that provides the description and protein ID of the best hitting protein in the user supplied database. Historically, the pipelines used a large collection of proteins from GenBank NR, but with user input files the script may not parse many details and can be ignored. The "pamloutput_TAXON" file contains the simple pairwise duplicate results, including Ks, Ka, and Ka/Ks calculated by paml for the pair of sequences (query and hit). The annotations columns are largely a legacy similar to those in the "final_ks_values_TAXON" file and can be mostly ignored. Finally, there is an "indices.TAXON" file for each analysis. This provides a table of translations to go from the original input file fasta headers to the numbered index that the EvoPipes piplines use. In EvoPipes, each sequence is numbered in the order they appear in the input fasta file. This is done because some programs limit the length of sequence names and to simplify parsing. Users may use the index file to convert between headers and EvoPipes index as needed.

In the /DupPipe/TAXON/Data folder, you will find a variety of files that are produced at intermediate steps in the pipeline. These include "DNA1" and "DNA2" that are paired lists of duplicated genes. "DNApairnumber" is the number of paralog pairs. Also included are the raw BLAST results and other lists of parsed output with self-explanatory titles that are produced throughout the pipeline run. These can largely be ignored, but can be useful in helping sort out pipeline failures.

---

*OrthoPipe Output*

The primary output from the OrthoPipe pipeline will be located in the /OrthoPipe/TAX_TAX_TAX/Output/ directory. The primary output of interest is the "codeml_outputTAX_TAX_TAX" file. This contains columns for each pair of reciprical best BLAST hit orthologs with associated Ka, Ks, and Ka/Ks estimates inferred by paml. Similar to the DupPipe output files above, there are legacy columns for annotations based on the best hit protein sequence in the database. These may be ignored. There are also "indices.TAX" files for each dataset analyzed. Similar to the DupPipe, these files provide a table of translations to go from the original input file fasta headers to the numbered index that the EvoPipes piplines use. In EvoPipes, each sequence is numbered in the order they appear in the input fasta file. This is done because some programs limit the length of sequence names and to simplify parsing. Users may use the index file to convert between headers and EvoPipes index as needed.

In the /OrthoPipe/TAX_TAX_TAX/ directory are a variety of files produced at intermediate steps in the pipeline. These include BLAST output and parsed results, and the names of paired reciprical best BLAST hit orthologs ("orthologs.TAX_TAX_TAX" file). Most of the time these can be ignored, but they can be useful if evaluating pipeline failures.

(Note that the /OrthoPipe/TAX_TAX_TAX/hit_parser directory is empty. It will be deleted in a future update of the pipeline.)

---

*TransPipe Output*

The output for the TransPipe will be located in the /Translated/TAXON/Output directory. There will be three files in this directory. "taxon.faa" and "taxon.fna" are paired fasta files that contain the translated amino acid (.faa) and paired nucleic acid (.fna) sequence for each of the input files. Compared to the original input sequences, the .fna files contain trimmed sequences that start in-frame and can be useful for downstream analyses. There is also an "indices.TAXON" file. Similar to the DupPipe, this file provides a table of translations to go from the original input file fasta headers to the numbered index that the EvoPipes piplines use. In EvoPipes, each sequence is numbered in the order they appear in the input fasta file. This is done because some programs limit the length of sequence names and to simplify parsing. Users may use the index file to convert between headers and EvoPipes index as needed.



### Citations ###
---

If you use EvoPipes in your research, please cite:

[Barker, M. S., K. M. Dlugosch, L. Dinh, R. S. Challa, N. C. Kane, M. G. King, and L. H. Rieseberg. 2010. EvoPipes.net: Bioinformatic tools for ecological and evolutionary genomics. _Evolutionary Bioinformatics_ 6: 143–149.](http://dx.doi.org/10.4137/EBO.S5861)


You should also cite the software packages used in the pipelines:

- NCBI BLAST+ (https://packages.ubuntu.com/focal/ncbi-blast+)

- Muscle (https://packages.ubuntu.com/focal/muscle)

- BioPerl (https://packages.ubuntu.com/focal/bioperl)

- Genewise (https://www.ebi.ac.uk/seqdb/confluence/display/THD/GeneWise)

- Paml (https://packages.ubuntu.com/focal/paml)

- RevTrans (https://gitlab.com/barker-lab/RevTrans_Python3)



### License ###
---

All scripts are provided as is with no guarantee they will run correctly without modification on a particular operating system.

Scripts are released, except where otherwise noted in their leading comments, under the GNU General Public License (https://www.gnu.org/licenses/gpl-3.0.txt). You can redistribute them and/or modify them under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
    
