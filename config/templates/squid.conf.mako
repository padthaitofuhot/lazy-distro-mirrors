# Kudos to http://ma.ttwagner.com/lazy-distro-mirrors-with-squid/ most
# of the parameters here were taken from that.
#
# Kudos to Ryan McGuire for the original Docker image scripts.
# https://github.com/EnigmaCurry/lazy-distro-mirrors

% for name, subnet in networks.items():
acl ${name} src ${subnet}
http_access allow ${name}
% endfor

http_access deny all

http_port ${port} accel defaultsite=kernel-mirror.weave.local vhost

# This needs to be specified before the cache_dir, otherwise it's ignored ?!
maximum_object_size ${maximum_object_size}

# Cache directory settings (storage)
cache_dir ${cache_access_scheme} ${cache_dir} ${cache_size} 16 256

# Set cache policy to optimize bytecount over hitcount.
cache_replacement_policy heap LFUDA

# Set cache policy to override expiration timers for blobs unlikely to change.
refresh_pattern -i .rpm$ 129600 100% 129600 refresh-ims override-expire
refresh_pattern -i .iso$ 129600 100% 129600 refresh-ims override-expire
refresh_pattern -i .deb$ 129600 100% 129600 refresh-ims override-expire
refresh_pattern -i .tar.xz$ 129600 100% 129600 refresh-ims override-expire
refresh_pattern -i .tar.gz$ 129600 100% 129600 refresh-ims override-expire
refresh_pattern -i .tar.bz2$ 129600 100% 129600 refresh-ims override-expire
refresh_pattern -i .tar.7z$ 129600 100% 129600 refresh-ims override-expire
refresh_pattern -i .txz$ 129600 100% 129600 refresh-ims override-expire
refresh_pattern -i .tgz$ 129600 100% 129600 refresh-ims override-expire
refresh_pattern -i .tbz$ 129600 100% 129600 refresh-ims override-expire
refresh_pattern -i .t7z$ 129600 100% 129600 refresh-ims override-expire
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .               0       20%     4320


% if proxy is None:
    % for mirror, url in mirrors.items():
    <%
        import urllib
        url_parsed = urllib.parse.urlparse(url)
        hostname = url_parsed.hostname
        port = url_parsed.port
        if port is None:
            port = 80
    %>
    cache_peer ${hostname} parent ${port} 0 no-query originserver name=${mirror}
    cache_peer_domain ${mirror} ${mirror}
    % endfor
% endif

% if proxy is not None:
    % for mirror in mirrors.items():
    <%
        import urllib
        url_parsed = urllib.parse.urlparse(proxy)
        hostname = url_parsed.hostname
        port = url_parsed.port
        if port is None:
            port = 80
    %>
    cache_peer ${hostname} parent ${port} 0 no-query name=${mirror}
    cache_peer_domain ${mirror} ${mirror}
    % endfor
% endif
