FROM debian:8

LABEL maintainer="Emanuel Felipe <emanuelflp@gmail.com>"

WORKDIR /app

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

ENV NOMINATIM_VERSION 2.5.1

ADD https://www.postgresql.org/media/keys/ACCC4CF8.asc /app/

COPY local.php /tmp/nominatim/local.php
COPY nominatim.conf /tmp/nominatim/nominatim.conf
COPY startup.sh /tmp/nominatim/startup.sh
COPY settings.php /tmp/nominatim/settings.php

RUN set -x && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" >> /etc/apt/sources.list && \
    cat ./ACCC4CF8.asc | apt-key add - && \
    apt-get -y update && \
    apt-get install --no-install-recommends --fix-missing -y build-essential ca-certificates curl libxml2-dev libpq-dev libbz2-dev \
    libtool automake libproj-dev libboost-dev libboost-system-dev libboost-filesystem-dev \
    libboost-thread-dev libexpat-dev gcc proj-bin libgeos-c1 libgeos++-dev \
    libexpat-dev php5 php-pear php5-pgsql php5-json php-db libapache2-mod-php5 liblua5.1-0-dev postgresql-server-dev-9.6 \
    zlib1g-dev && \
    curl -s -o ./Nominatim-$NOMINATIM_VERSION.tar.bz2 http://www.nominatim.org/release/Nominatim-$NOMINATIM_VERSION.tar.bz2 && \
    tar xf Nominatim-$NOMINATIM_VERSION.tar.bz2 && \
    rm -rf Nominatim-$NOMINATIM_VERSION.tar.bz2 && \
    mv ./Nominatim-$NOMINATIM_VERSION/ ./nominatim && \
    cd ./nominatim && \
    ./autogen.sh && ./configure && make && \
    cp /tmp/nominatim/local.php ./settings/local.php && \
    cp /tmp/nominatim/nominatim.conf /etc/apache2/sites-enabled/000-default.conf && \
    cp /tmp/nominatim/startup.sh ./ && \
    cp /tmp/nominatim/settings.php ./settings/settings.php && \
    apt-get clean && \
    apt-get remove -y --purge build-essential zlib1g-dev liblua5.1-0-dev postgresql-server-dev-9.6 \
    automake gcc libxml2-dev libexpat-dev libgeos++-dev libpq-dev libbz2-dev libproj-dev libboost-dev \
    libboost-system-dev libboost-filesystem-dev libboost-thread-dev libexpat-dev && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/www/html/* && \
    rm -rf /app/ACCC4CF8.asc && \
    ./utils/setup.php --create-website /var/www/html

EXPOSE 8080

ENTRYPOINT ["/app/nominatim/startup.sh"]