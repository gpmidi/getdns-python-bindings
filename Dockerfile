FROM  ubuntu:14.04
MAINTAINER Melinda Shore <melinda.shore@nomountain.net>

RUN set -ex \
    && apt-get update \
    && apt-get install -y   curl git wget libssl-dev libidn11-dev python-dev make automake \
                            autoconf libtool shtool

RUN curl -fOSL "https://unbound.net/downloads/unbound-1.5.8.tar.gz" \
    && mkdir -p /usr/src/unbound \
    && tar -xzC /usr/src/unbound --strip-components=1 -f unbound-1.5.8.tar.gz \
    && rm unbound-1.5.8.tar.gz \
    && cd /usr/src/unbound \
    && ./configure \
    && make \
    && make install \
    && ldconfig

RUN cd /usr/src \
    && git clone https://github.com/getdnsapi/getdns.git \
    && cd /usr/src/getdns \
    && git checkout develop \
    && git submodule update --init \
    && libtoolize -ci \
    && autoreconf -fi \
    && ./configure \
    && make \
    && make install \
    && ldconfig

RUN mkdir -p /etc/unbound \
COPY getdns-root.key /etc/unbound/getdns-root.key

RUN cd /usr/src \
    && git clone https://github.com/getdnsapi/getdns-python-bindings.git \
    && cd /usr/src/getdns-python-bindings \
    && git checkout develop \
    && python setup.py build \
    && python setup.py install


CMD ["/usr/bin/python"]
