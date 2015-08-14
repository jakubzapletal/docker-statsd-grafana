FROM jakubzapletal/ubuntu:14.04.3

# Install all prerequisites
RUN \
    apt-get -y install software-properties-common && \
    add-apt-repository -y ppa:chris-lea/node.js && \
    apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install python-django-tagging python-simplejson python-memcache python-ldap python-cairo python-pysqlite2 python-support \
        python-pip gunicorn supervisor nginx-light nodejs git wget curl openjdk-7-jre build-essential python-dev

RUN \
    pip install Twisted==11.1.0 && \
    pip install Django==1.5

RUN mkdir /src

# Install Whisper
RUN \
    git clone https://github.com/graphite-project/whisper.git /src/whisper && \
    cd /src/whisper && \
    git checkout 0.9.x && \
    python setup.py install

# Install Carbon
RUN \
    git clone https://github.com/graphite-project/carbon.git /src/carbon && \
    cd /src/carbon && \
    git checkout 0.9.x && \
    python setup.py install

# Install Graphite
RUN \
    git clone https://github.com/graphite-project/graphite-web.git /src/graphite-web && \
    cd /src/graphite-web && \
    git checkout 0.9.x && \
    python setup.py install

# Install StatsD
RUN \
    git clone https://github.com/etsy/statsd.git /src/statsd && \
    cd /src/statsd && \
    git checkout v0.7.2

# Install Grafana
RUN \
    wget http://grafanarel.s3.amazonaws.com/builds/grafana_latest_amd64.deb && \
    dpkg -i grafana_latest_amd64.deb && \
    rm grafana_latest_amd64.deb

# Configure Whisper, Carbon and Graphite-Web
ADD graphite/initial_data.json /opt/graphite/webapp/graphite/initial_data.json
ADD graphite/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
ADD graphite/carbon.conf /opt/graphite/conf/carbon.conf
ADD graphite/storage-schemas.conf /opt/graphite/conf/storage-schemas.conf
ADD graphite/storage-aggregation.conf /opt/graphite/conf/storage-aggregation.conf
RUN mkdir -p /opt/graphite/storage/whisper
RUN touch /opt/graphite/storage/graphite.db /opt/graphite/storage/index
RUN chown -R www-data /opt/graphite/storage
RUN chmod 0775 /opt/graphite/storage /opt/graphite/storage/whisper
RUN chmod 0664 /opt/graphite/storage/graphite.db
RUN cd /opt/graphite/webapp/graphite && python manage.py syncdb --noinput

# Confiure StatsD
ADD statsd/config.js /src/statsd/config.js

# Confiure Grafana
ADD grafana/grafana.ini /etc/grafana/grafana.ini
ADD grafana/import_datasource.sh /etc/grafana/import_datasource.sh
ADD grafana/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN /etc/grafana/import_datasource.sh

# Configure nginx and supervisord
ADD nginx/nginx.conf /etc/nginx/nginx.conf
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ports
#   - 3000: Grafana 2 web interface
#   - 8125/udp: StatsD port
#   - 8126: StatsD administrative port
EXPOSE 3000 8125/udp 8126

# Add the dashboards
RUN mkdir -p /src/dashboards
VOLUME /src/dashboards

# Folder with data
VOLUME /opt/graphite/storage/whisper

# Define default command
CMD ["/usr/bin/supervisord"]
