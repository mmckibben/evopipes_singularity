#test docker file

FROM ubuntu:18.04
RUN apt-get update && apt-get install -y \
	muscle \
	bioperl \
	ncbi-blast+ 
ENV LC_ALL = "en_US.UTF-8", \
        LC_CTYPE = "en_US.UTF-8", \
        LANG = "en_US.UTF-8" \
COPY * /bin/
workdir /home/
