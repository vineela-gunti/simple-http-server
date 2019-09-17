#FROM rabbitmq:3-management
FROM rabbitmq:3.8-rc
USER root
COPY . /tmp/src

#RUN mkdir -p /tmp/scripts

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
#RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/* /var/lib/apt/cache/*.deb



#RUN wget https://bintray.com/rabbitmq/community-plugins/download_file?file_path=rabbitmq_delayed_message_exchange-0.0.1.ez -O  "/usr/lib/rabbitmq/lib/rabbitmq_server-$RABBITMQ_VERSION/plugins/rabbitmq_delayed_message_exchange-0.0.1.ez"



#RUN rabbitmq-plugins enable rabbitmq_delayed_message_exchange --offline





RUN rabbitmq-plugins enable --offline rabbitmq_management
RUN set -eux; \

        erl -noinput -eval ' \

                { ok, AdminBin } = zip:foldl(fun(FileInArchive, GetInfo, GetBin, Acc) -> \

                        case Acc of \

                                "" -> \

                                        case lists:suffix("/rabbitmqadmin", FileInArchive) of \

                                                true -> GetBin(); \

                                                false -> Acc \

                                        end; \

                                _ -> Acc \

                        end \

                end, "", init:get_plain_arguments()), \

                io:format("~s", [ AdminBin ]), \

                init:stop(). \

        ' -- /plugins/rabbitmq_management-*.ez > /usr/local/bin/rabbitmqadmin; \

        [ -s /usr/local/bin/rabbitmqadmin ]; \

        chmod +x /usr/local/bin/rabbitmqadmin; \

        apt-get update; apt-get install -y --no-install-recommends python; rm -rf /var/lib/apt/lists/*; \

        rabbitmqadmin --version

EXPOSE 15671 15672
RUN chmod +x /tmp/scripts/assemble
RUN /tmp/scripts/assemble
#RUN chmod +x /opt/app-root/s2i/run
#CMD [ "/opt/app-root/s2i/run" ]
#ADD run.sh /run.sh
#RUN chmod +x /*.sh
#CMD ["/run.sh"]


USER 1001

