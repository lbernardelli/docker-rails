FROM debian:jessie
MAINTAINER Elifarley Cruz <elifarley@gmail.com>

#ENV RM_APT '/var/lib/apt/lists/* /var/lib/apt /var/lib/dpkg'
ENV RM_ITEMS '/tmp/* /var/tmp/* /var/backups/* /usr/share/man /usr/share/doc'

# --- Ruby ---
ENV APT_PACKAGES "\
curl gcc g++ make patch binutils libc6-dev \
  libjemalloc-dev libffi-dev libssl-dev libyaml-dev zlib1g-dev libgmp-dev libxml2-dev \
  libxslt1-dev libreadline-dev libsqlite3-dev \
  libpq-dev unixodbc unixodbc-dev unixodbc-bin ruby-odbc freetds-bin freetds-common freetds-dev postgresql-client \
 "

RUN printf 'APT::Get::Install-Recommends "false";\nDpkg::Options {\n"--force-confdef";\n"--force-confold";\n}' \
> /etc/apt/apt.conf.d/local && apt-get update && apt-get -y dist-upgrade && \
apt-get install -y --no-install-recommends $APT_PACKAGES && \
apt-get autoremove --purge -y && apt-get clean && rm -rf $RM_ITEMS

ENV RUBY_MAJOR "2.3"
ENV RUBY_VERSION "2.3.0"
ENV RUBYGEMS_VERSION "2.5.2"

WORKDIR /tmp
RUN curl "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR}/ruby-${RUBY_VERSION}.tar.gz" |\
  tar -xz && \
  cd ruby-${RUBY_VERSION} && \
  ./configure --enable-shared --with-jemalloc --disable-install-doc && \
  make -j4 && make install && \
  rm /usr/local/lib/libruby-static.a && \
  rm -rf $RM_ITEMS
# --- Ruby ---

ENV TINI_SHA 066ad710107dc7ee05d3aa6e4974f01dc98f3888
# Use tini as subreaper in Docker container to adopt zombie processes 
RUN curl -fsSL https://github.com/krallin/tini/releases/download/v0.5.0/tini-static -o /bin/tini && chmod +x /bin/tini && \
  echo "$TINI_SHA  /bin/tini" | sha1sum -wc -

ENV GOSU_SHA 18cced029ed8f0bf80adaa6272bf1650ab68f7aa
# Grab gosu for easy step-down from root.
RUN curl -fsSL https://github.com/tianon/gosu/releases/download/1.5/gosu-amd64 -o /bin/gosu && chmod 755 /bin/gosu && \
  echo "$GOSU_SHA  /bin/gosu" | sha1sum -wc -

ENV _USER app
ENV HOME /$_USER
RUN adduser --disabled-password --home "$HOME" --shell /bin/bash --gecos "" $_USER && \
  curl -fsSL https://github.com/elifarley/shellbase/archive/1.0.tar.gz \
  | tar --exclude README.md --exclude LICENSE --strip=1 --overwrite -zxvC "$HOME" && \
  gpasswd -a $_USER sudo && printf "$_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
  mkdir -p $HOME/.ssh && chmod go-w $HOME && chmod 700 $HOME/.ssh

WORKDIR $HOME
ENV PATH ".gem/bin:$PATH"

ENV BUNDLER_VERSION "1.11.2"
ENV RAILS_VERSION 4.2.5.1
RUN printf 'gem: --no-document' > .gemrc && \
  gem --config-file .gemrc update --system ${RUBYGEMS_VERSION} && \
  gem --config-file .gemrc install -v ${BUNDLER_VERSION} bundler && \
  gem --config-file .gemrc install rails --version "$RAILS_VERSION" && \
  gem --config-file .gemrc install rspec-rails simplecov simplecov-cobertura simplecov-rcov factory_girl && \
  gem --config-file .gemrc install puma --version 3.1.0 && \
  rm -rf $RM_ITEMS

RUN chown -R $_USER:$_USER /usr/lib/ruby /usr/local/lib/ruby

RUN apt-get install -y --no-install-recommends openssh-server && \
apt-get autoremove --purge -y && apt-get clean && \
rm -rf /etc/cron.daily/{apt,passwd} $RM_ITEMS

# --- Configure SSHD ---
RUN sed -e '/Port/d;/UsePrivilegeSeparation/d;/PermitRootLogin/d;/PermitUserEnvironment/d;/UsePAM/d;/PasswordAuthentication/d;/ChallengeResponseAuthentication/d;/Banner/d' /etc/ssh/sshd_config > /etc/ssh/sshd_config.tmp && \
printf "\nPort 2200\nUsePrivilegeSeparation no\nPermitRootLogin no\nPermitUserEnvironment yes\nUsePAM no\nPasswordAuthentication no\nChallengeResponseAuthentication no\n\n#---\n" > /etc/ssh/sshd_config && \
cat /etc/ssh/sshd_config.tmp >> /etc/ssh/sshd_config && rm /etc/ssh/sshd_config.tmp && \
  cp -a /etc/ssh /etc/ssh.cache

EXPOSE 2200
# --- Configure SSHD ---

RUN apt-get install -y --no-install-recommends vim less locate sudo git && \
apt-get autoremove --purge -y && apt-get clean && rm -rf $RM_ITEMS && \
updatedb

# Install Pathogen - https://github.com/tpope/vim-pathogen
RUN mkdir -p "$HOME"/.vim/autoload "$HOME"/.vim/bundle && \
curl -fsSL https://tpo.pe/pathogen.vim > "$HOME"/.vim/autoload/pathogen.vim && \
sed -i '1 i\execute pathogen#infect()\ncall pathogen#helptags()\n' "$HOME"/.vimrc && \
( cd ~/.vim/bundle && \
  git clone git://github.com/tpope/vim-rails.git && \
  git clone git://github.com/tpope/vim-bundler.git && \
  git clone git://github.com/tpope/vim-fugitive.git \
) && vim -u NONE -c "helptags vim-fugitive/doc" -c q

ENV LANG en_US.UTF-8
#RUN locale-gen $LANG && dpkg-reconfigure locales && /usr/sbin/update-locale LANG=$LANG

ENV TZ ${TZ:-Brazil/East}
RUN echo "TZ set to '$TZ'" && echo $TZ > /etc/TZ && rm -f /etc/localtime && ln -s /usr/share/zoneinfo/"$TZ" /etc/localtime

ENV TERM=xterm-256color

RUN printf "PATH=$PATH\n" >> "$HOME"/.ssh/environment && \
  printf ". '$HOME'/.ssh/environment\ncd /data\ntest ! -d vendor/bundle && bundle install --path vendor/bundle && du -hs vendor/*\npwd" \
    >> "$HOME"/.bashrc

RUN chown -R $_USER:$_USER "$HOME"

ADD https://raw.githubusercontent.com/elifarley/docker-jenkins-slaves/master/entry.sh /entry.sh
RUN chmod +x /entry.sh
ENTRYPOINT ["/entry.sh"]

CMD ["/usr/sbin/sshd", "-D", "-f", "/etc/ssh/sshd_config"]

#VOLUME $HOME/.rbenv
