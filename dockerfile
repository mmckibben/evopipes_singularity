#test docker file

FROM ubuntu:18.04
RUN apt-get update && apt-get install -y \
	muscle \
	bioperl \
	ncbi-blast+ 
COPY * /bin/
workdir /home/

ENV LANG pl_PL.UTF-8
ENV LANGUAGE pl_PL
ENV LC_ALL pl_PL.UTF-8
