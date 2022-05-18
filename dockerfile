#test docker file

FROM ubuntu:18.04
RUN apt-get update && apt-get install -y \
	muscle \
	bioperl \
	ncbi-blast+ 
	
ENV LANG pl_PL.UTF-8
ENV LANGUAGE pl_PL
ENV LC_ALL pl_PL.UTF-8	
ENV LC_CTYPE en_US.UTF-8

COPY * /bin/
workdir /home/
