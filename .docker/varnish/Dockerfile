FROM 369129824209.dkr.ecr.eu-west-1.amazonaws.com/magebit-docker:varnish-7.5
# Changing entrypoint to ours to pass additional parameters
# Volume didn't work because of permissions error
RUN rm /usr/local/bin/docker-varnish-entrypoint
COPY default.vcl /etc/varnish/default.vcl
COPY docker-varnish-entrypoint /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-varnish-entrypoint
