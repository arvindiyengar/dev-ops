FROM ubuntu 
MAINTAINER Arvind Iyengar <iyengara@vmware.com>

# Let's ensure that all package repositories are up to date 
RUN apt-get update

# We need ssh server so that Jenkins Master can connect to slave jenkins docker image
RUN apt-get install -y openssh-server
RUN sed -i 's|session required pam_loginuid.so|session optional pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd

# Create an user named jenkins with admin privileges
RUN adduser --quiet jenkins
RUN adduser jenkins sudo

# Set password for the jenkins user as jenkins
RUN echo "jenkins:jenkins" | chpasswd

# Create Maven Local Repository directory and ensure jenkins user is the owner
RUN mkdir /home/jenkins/.m2 ; cd /home/jenkins/
RUN wget http://redrockdigimark.com/apachemirror/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz ; tar -xvzf apache-maven-3.3.9-bin.tar.gz ; cd apache-maven-3.3.9/ ; export PATH=/home/jenkins/apache-maven-3.3.9/bin/:$PATH
RUN export PATH=/home/jenkins/apache-maven-3.3.9/bin/:$PATH
RUN chown -R jenkins:jenkins /home/jenkins/


# Create a project directory volume mount point inside the container 
RUN mkdir -p /home/jenkins/workspace/HelloDevOps
#RUN git clone https://github.com/arvindiyengar/dev-ops.git ; cd dev-ops ; mv * ../
RUN chown -R jenkins:jenkins /home/jenkins/workspace/HelloDevOps

# Create a directory inside docker container for mounting your host machine JAVA_HOME 
RUN mkdir -p /usr/lib/jvm/java-8-openjdk-amd64
RUN chown -R jenkins:jenkins /usr/lib/jvm/java-8-openjdk-amd64

# Create a directory inside docker continer if you prefer mounting your host machine M3_HOME
RUN mkdir -p /usr/share/maven
RUN chown -R jenkins:jenkins /usr/share/maven

# Open SSH Port for jenkins master to ssh into this slave machine
EXPOSE 22

# Lauch SSH Server once the container is booted as a daemon
CMD ["/usr/sbin/sshd", "-D"]
