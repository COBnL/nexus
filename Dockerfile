FROM alpine:3.9

LABEL maintainer="cavemandaveman <cavemandaveman@protonmail.com>"

ENV SONATYPE_DIR="/opt/sonatype"
ENV NEXUS_VERSION="3.19.0-01" \
    NEXUS_DATA="/nexus-data" \
    NEXUS_HOME="${SONATYPE_DIR}/nexus" \
    SONATYPE_WORK="${SONATYPE_DIR}/sonatype-work" \
    JAVA_MIN_MEM="1200M" \
    JAVA_MAX_MEM="1200M" \
    JKS_PASSWORD="changeit"

RUN set -x \
    && apk --no-cache add \
        openjdk8-jre-base \
        nss \
        libressl \
        su-exec \
    && mkdir -p "${SONATYPE_DIR}" \
    && wget -qO - "https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz" \
    | tar -zxC "${SONATYPE_DIR}" \
    && mv "${SONATYPE_DIR}/nexus-${NEXUS_VERSION}" "${NEXUS_HOME}" \
    && adduser -S -h ${NEXUS_DATA} nexus


# https://github.com/flytreeleft/nexus3-keycloak-plugin
ENV KEYCLOAK_PLUGIN_VERSION="0.3.3-SNAPSHOT"
ENV NEXUS_PLUGINS="${NEXUS_HOME}/system" \
    KEYCLOAK_PLUGIN="org.github.flytreeleft/nexus3-keycloak-plugin/${KEYCLOAK_PLUGIN_VERSION}"

ADD https://github.com/flytreeleft/nexus3-keycloak-plugin/releases/download/${KEYCLOAK_PLUGIN_VERSION}/nexus3-keycloak-plugin-${KEYCLOAK_PLUGIN_VERSION}.jar \
   ${NEXUS_PLUGINS}/org/github/flytreeleft/nexus3-keycloak-plugin/${KEYCLOAK_PLUGIN_VERSION}/nexus3-keycloak-plugin-${KEYCLOAK_PLUGIN_VERSION}.jar
RUN chmod 644 ${NEXUS_PLUGINS}/org/github/flytreeleft/nexus3-keycloak-plugin/${KEYCLOAK_PLUGIN_VERSION}/nexus3-keycloak-plugin-${KEYCLOAK_PLUGIN_VERSION}.jar
RUN echo "mvn\\:${KEYCLOAK_PLUGIN} = 200" >> ${NEXUS_HOME}/etc/karaf/startup.properties

EXPOSE 5000 8081 8443

WORKDIR "${NEXUS_HOME}"

VOLUME "${NEXUS_DATA}"

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["bin/nexus", "run"]
