FROM ubuntu:trusty
MAINTAINER Aharon Amir

# Install necessary packages for me!
USER root
RUN apt-get update \
      && apt-get install -y sudo supervisor curl wget g++ cmake \
      && rm -rf /var/lib/apt/lists/*

#Install node (needed for web projects)
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
RUN apt-get install -y nodejs build-essential

#Install jenkins
RUN wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
RUN sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
RUN apt-get update \
      && apt-get install -y jenkins \
      && rm -rf /var/lib/apt/lists/*

# Install docker-engine
# According to Petazzoni's article:
# ---------------------------------
# "Former versions of this post advised to bind-mount the docker binary from
# the host to the container. This is not reliable anymore, because the Docker
# Engine is no longer distributed as (almost) static libraries."
#ARG docker_version=1.11.2
RUN curl -sSL https://get.docker.com/ | sh && \
    apt-get purge -y docker-ce && \
    apt-get install docker-ce

# Make sure jenkins user has docker privileges
RUN usermod -aG docker jenkins

# Install initial plugins
#USER jenkins
#COPY plugins.txt /usr/share/jenkins/plugins.txt
#RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

# supervisord
USER root

# Create log folder for supervisor and jenkins
RUN mkdir -p /var/log/supervisor
RUN mkdir -p /var/log/jenkins

# allow jenkins to run sudo
RUN echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copy the supervisor.conf file into Docker
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Start supervisord when running the container
CMD /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
