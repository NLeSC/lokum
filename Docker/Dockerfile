FROM alpine:3.9

# add user filo
RUN addgroup -g 1000 filo && \
    adduser -D -u 1000 -G filo filo
#USER filo

# install packages
RUN apk update && \
  apk add --no-cache \
  terraform=0.11.8-r0 \
  git \
  python2 python2-dev py2-pip \
  python3 python3-dev py3-pip \
  openssh \
  go bzr \
  musl-dev libffi-dev openssl-dev \
  make \
  vim \
  bash

# make sure ansible is not installed by the system
RUN apk del ansible

# cleanup
RUN rm -rf /tmp/* /var/cache/apk/*

# opennebula provider
RUN go get -v github.com/runtastic/terraform-provider-opennebula && \
    go install -v github.com/runtastic/terraform-provider-opennebula

# add opennebula provider to .terraformrc
RUN echo -e 'providers {\n\
 opennebula = "/root/go/bin/terraform-provider-opennebula"\n\
 }'\
>> /root/.terraformrc

# change from sh to bash 
RUN rm /bin/sh && ln -sf /bin/bash /bin/sh

# WORKDIR
WORKDIR /lokum

# Copy custom inventory builder
COPY inventory_builder /lokum/inventory_builder

# clone emma repo
# RUN git clone https://github.com/nlesc-sherlock/emma.git && \
#     pwd
RUN git clone https://github.com/fdiblen/emma.git && cd emma && git checkout lokum_fixes

# install kubespray requirements
RUN pip2 install --upgrade pip && \
    pip2 uninstall ansible && \
    cd /lokum/inventory_builder && pip3 install -r requirements.txt && \
    pip2 install ansible-modules-hashivault && \
    cd /lokum

# set environment variables
ENV LOKUM_HOME /lokum
ENV LOKUM_CONFIG /lokum/config
#ENV ANSIBLE_LIBRARY /usr/lib/python2.7/site-packages/ansible/modules
#ENV ANSIBLE_MODULE_UTILS /usr/lib/python2.7/site-packages/ansible/module_utils
#export PATH=$PATH:/lokum/kubespray/library


COPY scripts/lokum-init.sh /usr/local/bin/
RUN ln -s usr/local/bin/lokum-init.sh / # back compatibility
ENTRYPOINT ["lokum-init.sh"]
CMD ["deploy"]