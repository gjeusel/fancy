FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install -y \
  wget libcurses-perl make vim nmap git curl ruby-full

RUN \
# Install deps for asciiquarium
  wget http://search.cpan.org/CPAN/authors/id/K/KB/KBAUCOM/Term-Animation-2.4.tar.gz --no-check-certificate \
  && tar -zxvf Term-Animation-2.4.tar.gz \
  && cd Term-Animation-2.4/ && perl Makefile.PL && make && make test && make install && cd ../ \
# Actually install the binary
  && wget http://www.robobunny.com/projects/asciiquarium/asciiquarium.tar.gz --no-check-certificate \
  && tar -zxvf asciiquarium.tar.gz \
  && chmod 0755 asciiquarium_1.1/asciiquarium \
  && cp asciiquarium_1.1/asciiquarium /bin

# Other fun commands
RUN apt-get install -y \
  aalib-bin cmatrix toilet

# Hollywood
RUN apt-get install -y software-properties-common \
  && apt-add-repository ppa:hollywood/ppa \
  && apt-get update -y \
  && apt-get install -y byobu hollywood


RUN gem install lolcat

RUN echo "toilet --metal E T S Rox." >> ~/.bashrc
RUN echo "echo '> asciiquarium' \necho '> aafire' \n echo '> cmatrix' \necho '> hollywood'" >> ~/.bashrc

CMD ["bash"]
