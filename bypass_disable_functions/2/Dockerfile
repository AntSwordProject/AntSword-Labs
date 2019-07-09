FROM antswordproject/antsword-labs:bypass_disable_functions_1

ARG GNU_MIRROR=https://ftp.gnu.org/gnu

# China mirror
ARG GNU_MIRROR=http://mirrors.ustc.edu.cn/gnu
COPY ./src/sources.list /etc/apt/sources.list

# ShellShock
RUN set -x \
  && apt-get update \
  && apt-get -y --force-yes install wget build-essential bison autoconf \
  && mkdir /usr/local/src/bash \
  && wget -qO- ${GNU_MIRROR}/bash/bash-4.3.tar.gz | tar zx -C /usr/local/src/bash --strip-components=1 \
  && cd /usr/local/src/bash \
  && wget -qO- $(seq -f "${GNU_MIRROR}/bash/bash-4.3-patches/bash43-%03g" 24) | patch -p0 \
  && ./configure \
  && make \
  && make install \
  && rm -rf /usr/local/src/bash \
  && rm /bin/bash \
  && ln -s /usr/local/bin/bash /bin/bash \
  && rm /bin/sh \
  && ln -s /bin/bash /bin/sh
