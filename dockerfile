#test docker file HPC

FROM ubuntu:18.04
RUN apt-get update && apt-get install -y \
	muscle \
	bioperl \
	ncbi-blast+ \
	locales \
	unzip
	
RUN export LC_ALL=en_US.UTF-8
RUN export LANG=en_US.UTF-8
RUN locale-gen en_US.UTF-8
RUN unzip scripts/Atha.zip -d scripts/

COPY * /bin/
workdir /home/
