FROM docker:dind
ENV S6_VERSION v1.18.1.5
ENV S6_URL https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-amd64.tar.gz

RUN apk add --no-cache --virtual .deps curl openssl \
&&  curl -sSL ${S6_URL} | tar -C / -xzf - \
&&  apk del -r .deps

# install compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
&&  chmod +x /usr/local/bin/docker-compose

# install glibc reqs
ENV GLIBC_VERSION '2.23-r3'
RUN curl -Lo /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub \
&&  curl -Lo glibc.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-$GLIBC_VERSION.apk \
&&  curl -Lo glibc-bin.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-bin-$GLIBC_VERSION.apk \
&&  apk add --no-cache glibc.apk glibc-bin.apk \
&&  rm -rf /var/cache/apk/* glibc.apk glibkc-bin.apk \
&& docker-compose version

RUN apk add tzdata --no-cache \
&&  cp /usr/share/zoneinfo/Australia/Melbourne /etc/localtime \
&&  apk del -r tzdata
RUN apk add --no-cache git bash vim sudo

COPY ./include/sudoers /etc/sudoers

RUN apk add --no-cache openssh \
&&  ssh-keygen -A

COPY ./include/sshd_config /etc/ssh/sshd_config
COPY ./include/run_sshd /etc/services.d/sshd/run


COPY ./include/run_dockerd /etc/services.d/dockerd/run


ENV MYUSER stephen

RUN addgroup ${MYUSER} \
&&  adduser ${MYUSER} -s /bin/bash -D -G ${MYUSER} \
&&  echo "${MYUSER}:" | chpasswd \
&&  addgroup ${MYUSER} wheel

RUN apk del -r curl openssl \
&&  rm -rf /tmp/* \
&&  rm -rf /var/cache/apk/*

ENTRYPOINT ["/init"]
#CMD ["dockerd-entrypoint.sh"]
CMD []

