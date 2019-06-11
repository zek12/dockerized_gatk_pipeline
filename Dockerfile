FROM ubuntu:bionic

LABEL maintainer="Ezequiel.Anokian@icr.ac.uk"

USER root

ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /opt
COPY build/build_base.sh /opt
WORKDIR /opt
RUN ./build_base.sh && rm build_base.sh
COPY scripts /opt
RUN chmod a+rx -R /opt

# switch back to the ubuntu user so this tool (and the files written) are not owned by root
RUN groupadd -r -g 1000 ubuntu && useradd -r -g ubuntu -u 1000 -m ubuntu

USER ubuntu
ENV PATH "$PATH:/opt"
WORKDIR /home/ubuntu

CMD ["/bin/bash"]