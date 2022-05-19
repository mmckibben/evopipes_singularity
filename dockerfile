#test docker file HPC

FROM ubuntu:18.04
RUN apt-get update && apt-get install -y \
	muscle \
	bioperl \
	ncbi-blast+ \
	locales \
	
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8
ENV LANGUAGE=en

RUN dpkg-reconfigure locales

COPY * /bin/
workdir /home/
