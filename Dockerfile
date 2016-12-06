# base docker-in-docker (alpine)
FROM docker:dind
# s6-overlay
ENV S6_VERSION v1.18.1.5
ENV S6_URL https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-amd64.tar.gz

RUN apk add --no-cache --virtual .deps curl openssl \
&&  curl -sSL ${S6_URL} | tar -C / -xzf - \
&&  apk del -r .deps

# docker-compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
&&  chmod +x /usr/local/bin/docker-compose

# install glibc reqs (https://github.com/sgerrand/alpine-pkg-glibc)
ENV GLIBC_VERSION '2.23-r3'
RUN curl -Lo /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub \
&&  curl -Lo glibc.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-$GLIBC_VERSION.apk \
&&  curl -Lo glibc-bin.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-bin-$GLIBC_VERSION.apk \
&&  apk add --no-cache glibc.apk glibc-bin.apk \
&&  rm -rf /var/cache/apk/* glibc.apk glibkc-bin.apk \
&& docker-compose version

# australia/melbourne timezone
RUN apk add tzdata --no-cache \
&&  cp /usr/share/zoneinfo/Australia/Melbourne /etc/localtime \
&&  apk del -r tzdata

# packages
RUN apk add --no-cache git bash vim sudo

COPY ./include/sudoers /etc/sudoers

# ssh & config
RUN apk add --no-cache openssh \
&&  ssh-keygen -A

COPY ./include/sshd_config /etc/ssh/sshd_config
COPY ./include/run_sshd /etc/services.d/sshd/run

# docker service
COPY ./include/run_dockerd /etc/services.d/dockerd/run

# custom user (-e MYUSER)
COPY include/createuser /etc/cont-init.d/
RUN chmod +x /etc/cont-init.d/createuser

# cleanup
RUN apk del -r curl openssl \
&&  rm -rf /tmp/* \
&&  rm -rf /var/cache/apk/*

# s6-overlay init
ENTRYPOINT ["/init"]
CMD []

