FROM ubuntu:18.04
LABEL maintainer="av.tregubov@gmail.com"
# Вasic system layer
ENV DOCKER_USER=tm \
    DOCKER_GROUP=tm
ENV DOCKER_USER_HOME=/home/${DOCKER_USER} \
    DOCKER_USER_GECOS=development
RUN adduser --force-badname --disabled-password --gecos ${DOCKER_USER_GECOS} --home ${DOCKER_USER_HOME} --shell /bin/bash --quiet ${DOCKER_USER} \
    && apt update && apt-get install -y \
    curl \ 
    cron  \
    locales \
    gnupg \
    wget \
    tar \
    gcc \
    make \
    openssl \
    build-essential \
    apt-utils \
    libcurl4-openssl-dev \
    libbz2-dev \
    zlib1g \
    libpcre3 \
    libpcre3-dev \
    libpcrecpp0v5 \
    libssl-dev \
    libperl-dev\
    libpng-dev \
    libjpeg-dev \
    libfontconfig-dev \
    libtiff-dev \
    libgd-dev \
    libgdbm-dev \
    libxml2-dev \
    mysql-client \
    libmysqlclient-dev \
    && apt-get autoclean -y && apt-get autoremove -y \
    && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archives/*.deb \
    && locale-gen en_US.UTF-8 ru_RU.UTF-8
# Nodejs system layer
ENV NODE_PPA_VERSION=8 \
    NODE_VERION=8.17.0-1nodesource1
RUN curl -sL https://deb.nodesource.com/setup_${NODE_PPA_VERSION}.x | bash \
    && apt-get install --yes nodejs=${NODE_VERION} \
    && apt-get autoclean -y && apt-get autoremove -y \
    && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archives/*.deb
# Imagemagick system layer
ENV IMAGEMAGICK_VERSION=6.8.9-10
RUN cd /usr/src \
    && wget https://www.imagemagick.org/download/releases/ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz \
    && tar -xvf ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz \
    && cd ImageMagick-${IMAGEMAGICK_VERSION} \
    && ./configure --with-perl \
    && make \
    && make install \
    && ldconfig \
    && rm -rf /usr/src/*
# Change root home dir
# USER ${DOCKER_USER}
ENV HOME=${DOCKER_USER_HOME}
WORKDIR ${DOCKER_USER_HOME}
# Perlbrew user layer
RUN curl -L https://install.perlbrew.pl | bash
ENV PERLBREW_SHELLRC_VERSION=0.87 \
    PERLBREW_HOME=${DOCKER_USER_HOME}/.perlbrew \
    PATH=${DOCKER_USER_HOME}/perl5/perlbrew/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    PERLBREW_ROOT=${DOCKER_USER_HOME}/perl5/perlbrew
# Install perl layer
ENV PERL_VERSION=5.22.1 \
    PERLBREW_VERSION=${PERLBREW_SHELLRC_VERSION}
RUN perlbrew --notest install perl-${PERL_VERSION} \
    && perlbrew install-cpanm \
    && perlbrew switch perl-${PERL_VERSION} \
    && rm -f ${DOCKER_USER_HOME}/perl5/perlbrew/build.perl-${PERL_VERSION}.log
ENV PERLBREW_PERL=perl-${PERL_VERSION} \
    PERLBREW_SKIP_INIT=1
ENV PERLBREW_MANPATH=${DOCKER_USER_HOME}/perl5/perlbrew/perls/${PERLBREW_PERL}/man \
    PERLBREW_PATH=${DOCKER_USER_HOME}/perl5/perlbrew/bin:${DOCKER_USER_HOME}/perl5/perlbrew/perls/${PERLBREW_PERL}/bin \
    MANPATH=${DOCKER_USER_HOME}/perl5/perlbrew/perls/${PERLBREW_PERL}/man \
    PATH=${DOCKER_USER_HOME}/perl5/perlbrew/bin:${DOCKER_USER_HOME}/perl5/perlbrew/perls/${PERLBREW_PERL}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    # PERLBREW_LIB= \
    # PERL_LOCAL_LIB_ROOT= \
    # PERL5LIB=
RUN set -x \
   && cpanm Carton \
   && cpanm List::MoreUtils::XS \
   && cpanm Ubic \
   && cpanm POSIX::strftime::Compiler --force \
   && cpanm Apache::LogFormat::Compiler --force \
   && cpanm Plack \
   && cpanm Ubic::Service::Plack --force \
   && cpanm Ubic::Service::Starman \
   && ubic-admin setup --batch-mode \
   && printenv | egrep -v '^LS_COLORS|^_|^$' > ${DOCKER_USER_HOME}/.enviroment.env \
   && echo "* * * * * bash -c 'source ${DOCKER_USER_HOME}/perl5/perlbrew/etc/bashrc \
   && source ${DOCKER_USER_HOME}/.enviroment.env \
   && ${DOCKER_USER_HOME}/perl5/perlbrew/perls/perl-5.22.1/bin/ubic-watchdog ubic.watchdog' \ 
   >>/var/log/ubic/watchdog.log 2>>/var/log/ubic/watchdog.err.log" > '/var/spool/cron/crontabs/root'

CMD [ "/usr/sbin/cron", "-f" ]
