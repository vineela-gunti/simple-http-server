FROM rabbitmq:3-management


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
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/* /var/lib/apt/cache/*.deb



RUN wget https://bintray.com/rabbitmq/community-plugins/download_file?file_path=rabbitmq_delayed_message_exchange-0.0.1.ez -O  "/usr/lib/rabbitmq/lib/rabbitmq_server-$RABBITMQ_VERSION/plugins/rabbitmq_delayed_message_exchange-0.0.1.ez"



RUN rabbitmq-plugins enable rabbitmq_delayed_message_exchange --offline



# Add passwd template file for nss_wrapper

#RUN chmod +x /tmp/src/.s2i/bin/assemble
#RUN /tmp/src/.s2i/bin/assemble

RUN chmod +x /tmp/scripts/assemble
RUN /tmp/scripts/assemble
#RUN chmod +x /opt/app-root/s2i/run
#CMD [ "/opt/app-root/s2i/run" ]


#

# entrypoint/cmd for container

#CMD ["/tmp/rabbitmq/run-rabbitmq-server.sh"]


