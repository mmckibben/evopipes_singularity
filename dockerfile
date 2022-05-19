#test docker file

FROM ubuntu:18.04
RUN apt-get update && apt-get install -y \
	muscle \
	bioperl \
	ncbi-blast+ 
	
ENV LANG=en_US.UTF-8

COPY * /bin/
workdir /home/
