# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
FROM phusion/baseimage:0.9.18
#FROM phusion/passenger-ruby22
MAINTAINER Elifarley Cruz <elifarley@gmail.com>

ENV _USER app
ENV LANG en_US.UTF-8

ENV RUBY_MAJOR "2.3"
ENV RUBY_VERSION "2.3.0"
ENV RUBYGEMS_VERSION "2.5.2"
ENV BUNDLER_VERSION "1.11.2"

ENV APT_PACKAGES "\
gcc g++ make patch binutils libc6-dev \
  libjemalloc-dev libffi-dev libssl-dev libyaml-dev zlib1g-dev libgmp-dev libxml2-dev \
  libxslt1-dev libreadline-dev libsqlite3-dev \
  libpq-dev unixodbc unixodbc-dev unixodbc-bin ruby-odbc freetds-bin freetds-common freetds-dev postgresql-client \
  git \
"

ENV APT_REMOVE_PACKAGES "openssh-server"

ENV RM_ITEMS "\
/tmp/* /var/tmp/* /var/lib/apt/lists/* /var/lib/apt /var/lib/dpkg /var/backups/* /usr/share/man /usr/share/doc\
"

RUN locale-gen $LANG && dpkg-reconfigure locales && /usr/sbin/update-locale LANG=$LANG

RUN printf 'APT::Get::Install-Recommends "false";\nDpkg::Options {\n"--force-confdef";\n"--force-confold";\n}' \
> /etc/apt/apt.conf.d/local && apt-get update && apt-get -y dist-upgrade && \
apt-get install -y --no-install-recommends $APT_PACKAGES && \
apt-get remove --purge -y $APT_REMOVE_PACKAGES && apt-get autoremove --purge -y && apt-get clean && \
rm -rf $RM_ITEMS /etc/my_init.d/00_regen_ssh_host_keys.sh /etc/service/sshd /etc/cron.daily/{apt,passwd}

WORKDIR /tmp
RUN curl "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR}/ruby-${RUBY_VERSION}.tar.gz" |\
  tar -xz && \
  cd ruby-${RUBY_VERSION} && \
  ./configure --enable-shared --with-jemalloc --disable-install-doc && \
  make -j4 && make install && \
  rm /usr/local/lib/libruby-static.a && \
  rm -rf $RM_ITEMS

ENV HOME /$_USER
RUN adduser --disabled-password --home=$HOME --gecos "" $_USER && mkdir $HOME/webapp && chown $_USER:$_USER -R $HOME

WORKDIR $HOME
ENV GEM_SPEC_CACHE "/tmp/gemspec"
ENV GEM_HOME "$HOME/gem-home"
ENV PATH "$GEM_HOME/bin:$PATH"

RUN printf 'gem: --no-document' > .gemrc && gem --config-file .gemrc update --system ${RUBYGEMS_VERSION} && \
  gem --config-file .gemrc install -v ${BUNDLER_VERSION} bundler && \
  rm -rf "$GEM_HOME"/cache && \
  rm -rf $RM_ITEMS


RUN printf "#!/bin/sh\ndate > /tmp/boot-time.txt" > /etc/my_init.d/00-log-boot-time.sh

COPY syslog-ng-$_USER.conf /etc/syslog-ng/conf.d/$_USER.conf

# Use baseimage-docker's init system.
ENTRYPOINT ["/sbin/my_init"]

#PUSH elifarley/docker-rails:ruby-2.3.0

