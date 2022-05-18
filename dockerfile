#test docker file

FROM ubuntu:18.04
RUN apt-get update && apt-get install -y \
	muscle \
	bioperl \
	ncbi-blast+ 
	
ENV LC_ALL C

COPY * /bin/
workdir /home/
