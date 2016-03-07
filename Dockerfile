FROM sameersbn/squid
MAINTAINER padthaitofuhot

RUN apt-get update && apt-get install -y python3 python3-yaml python3-mako

ADD config /docker_configurator
# add hardcopy to repo rather than pulling down, since we may be behind one (or seven) proxies.
ADD scripts/start.sh /

EXPOSE 3142/tcp
VOLUME ["/var/spool/squid3"]

ENTRYPOINT ["/start.sh"]
