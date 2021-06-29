FROM ubuntu
RUN apt-get -y update
RUN apt-get install -y python-yaml

WORKDIR /tmp/ansible
ENV PATH /tmp/ansible/bin:/sbin:/usr/sbin:/usr/bin
ENV ANSIBLE_LIBRARY /tmp/ansible/library
ENV PYTHONPATH /tmp/ansible/lib:$PYTHON_PATH

ADD ansible/project/playbook.yml /etc/ansible/
ADD inventory /etc/ansible/hosts
WORKDIR /etc/ansible

RUN ansible-playbook /etc/ansible/playbook.yml -c local
