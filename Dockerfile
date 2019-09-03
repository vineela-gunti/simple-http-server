FROM centos:centos7

MAINTAINER The CentOS Project <cloud-ops@centos.org>


COPY . /tmp/src

RUN mkdir -p /tmp/scripts

RUN rm -rf /tmp/src/.git* && \
    chown -R 1001 /tmp/src && \
    chgrp -R 0 /tmp/src && \
    chmod -R g+w /tmp/src && \
    rm -rf /tmp/scripts && \
    mv /tmp/src/.s2i/bin /tmp/scripts

#USER 1001

LABEL io.k8s.description="Rabbitmq Server" \

      io.k8s.display-name="Rabbitmq Server" \

      io.openshift.s2i.scripts-url="image:///opt/app-root/s2i" \

      io.openshift.expose-services="8080:http" \

      io.openshift.tags="builder,http"

RUN yum -y install epel-release && yum -y update && yum -y install pwgen wget logrotate && yum -y install nss_wrapper gettext && yum clean all

# Setup rabbitmq-server
RUN useradd -d /var/lib/rabbitmq -u 1001 -o -g 0 rabbitmq && \
    yum -y install rabbitmq-server && yum clean all


# Send the logs to stdout
ENV RABBITMQ_LOGS=- RABBITMQ_SASL_LOGS=-
RUN mkdir -p /tmp/rabbitmq
RUN /usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_management

ADD run-rabbitmq-server.sh /tmp/rabbitmq/run-rabbitmq-server.sh
# Set permissions for openshift run
RUN chown -R 1001:0 /etc/rabbitmq && chown -R 1001:0 /var/lib/rabbitmq  && chmod -R ug+rw /etc/rabbitmq && \
    chmod -R ug+rw /var/lib/rabbitmq && find /etc/rabbitmq -type d -exec chmod g+x {} + && \
    find /var/lib/rabbitmq -type d -exec chmod g+x {} +

WORKDIR /var/lib/rabbitmq


#
# expose some ports
#
# 5672 rabbitmq-server - amqp port
# 15672 rabbitmq-server - for management plugin
# 4369 epmd - for clustering
# 25672 rabbitmq-server - for clustering

EXPOSE 5672 15672 4369 25672


# Add passwd template file for nss_wrapper

ADD passwd.template /tmp/rabbitmq/passwd.template

# Set permissions for scripts directory
RUN chown -R 1001:0 /tmp/rabbitmq && chmod -R ug+rwx /tmp/rabbitmq && \

    find /tmp/rabbitmq -type d -exec chmod g+x {} +
RUN chmod +x /tmp/scripts/assemble
RUN /tmp/scripts/assemble
#RUN chmod +x /opt/app-root/s2i/run
#CMD [ "/opt/app-root/s2i/run" ]
USER 1001

#

# entrypoint/cmd for container

CMD ["/tmp/rabbitmq/run-rabbitmq-server.sh"]


