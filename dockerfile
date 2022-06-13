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

COPY * /bin/
RUN cd /bin && unzip Atha.zip && rm Atha.zip && mv Atha.fa ath.fasta && makeblastdb -in ath.fasta -dbtype nucl
RUN cd /bin && wget http://abacus.gene.ucl.ac.uk/software/paml4.9j.tgz && tar xf paml4.9j.tgz && cd paml4.9j && rm bin/*.exe && cd src && make -f Makefile && ls -lF && rm *.o && mv baseml basemlg codeml pamp evolver yn00 chi2 ../bin
RUN cd /bin rm -r paml4.9j/

workdir /home/
