#FROM docker:17.06
FROM innoq/docker-alpine-java8

MAINTAINER Ashley Aitken <ashley.aitken@hedventures.com>

ARG "version=0.2.0"
ARG "build_date=unknown"
ARG "commit_hash=unknown"
ARG "vcs_url=unknown"
ARG "vcs_branch=unknown"

LABEL org.label-schema.vendor="vfarcic" \
    org.label-schema.name="jenkins-swarm-agent" \
    org.label-schema.description="Jenkins agent based on the Swarm plugin" \
    org.label-schema.usage="/src/README.md" \
    org.label-schema.url="https://github.com/vfarcic/docker-jenkins-slave-dind/blob/master/README.md" \
    org.label-schema.vcs-url=$vcs_url \
    org.label-schema.vcs-branch=$vcs_branch \
    org.label-schema.vcs-ref=$commit_hash \
    org.label-schema.version=$version \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date=$build_date

ENV SWARM_CLIENT_VERSION="3.3" \
    DOCKER_COMPOSE_VERSION="1.15.0" \
    SBT_VERSION="0.13.13" \
    COMMAND_OPTIONS="" \
    USER_NAME_SECRET="" \
    PASSWORD_SECRET=""

RUN adduser -G root -D jenkins && \
    apk --update --no-cache add bash attr python py-pip git openssh ca-certificates openssl curl zip tar && \
#    apk --update --no-cache add bash attr openjdk8-jre python py-pip git openssh ca-certificates openssl curl zip tar && \
#    apk --update --no-cache add bash paxctl setfattr openjdk8-jre python py-pip git openssh ca-certificates openssl && \
#    paxctl -c /usr/lib/jvm/java-8-openjdk/jre/bin/java && \
#    paxctl -m /usr/lib/jvm/java-8-openjdk/jre/bin/java && \
#    setfattr -n user.pax.flags -v "mr" /usr/lib/jvm/java-8-openjdk/jre/bin/java && \
#    sysctl -w kernel.pax.softmode=1 && \
#    setfattr -n user.pax.flags -v "mr" /usr/bin/java && \
#    setfattr -n user.pax.flags -v "pemrs" /usr/bin/java && \
    wget -q https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/${SWARM_CLIENT_VERSION}/swarm-client-${SWARM_CLIENT_VERSION}.jar -P /home/jenkins/ && \
   pip install docker-compose

# Install cURL
RUN apk --update add curl ca-certificates tar && \
    curl -Ls https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk > /tmp/glibc-2.21-r2.apk && \
    apk add --allow-untrusted /tmp/glibc-2.21-r2.apk

# Java Version
#ENV JAVA_VERSION_MAJOR 8
#ENV JAVA_VERSION_MINOR 45
#ENV JAVA_VERSION_BUILD 14
#ENV JAVA_PACKAGE       jdk

# Download and unarchive Java
#RUN mkdir /opt && curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie"\
#  http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
#    | tar -xzf - -C /opt &&\
#    ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/jdk &&\
#    rm -rf /opt/jdk/*src.zip \
#          /opt/jdk/lib/missioncontrol \
#           /opt/jdk/lib/visualvm \
#           /opt/jdk/lib/*javafx* \
#           /opt/jdk/jre/lib/plugin.jar \
#           /opt/jdk/jre/lib/ext/jfxrt.jar \
#           /opt/jdk/jre/bin/javaws \
#           /opt/jdk/jre/lib/javaws.jar \
#           /opt/jdk/jre/lib/desktop \
#           /opt/jdk/jre/plugin \
#           /opt/jdk/jre/lib/deploy* \
#           /opt/jdk/jre/lib/*javafx* \
#           /opt/jdk/jre/lib/*jfx* \
#           /opt/jdk/jre/lib/amd64/libdecora_sse.so \
#           /opt/jdk/jre/lib/amd64/libprism_*.so \
#           /opt/jdk/jre/lib/amd64/libfxplugins.so \
#           /opt/jdk/jre/lib/amd64/libglass.so \
#           /opt/jdk/jre/lib/amd64/libgstreamer-lite.so \
#           /opt/jdk/jre/lib/amd64/libjavafx*.so \
#           /opt/jdk/jre/lib/amd64/libjfx*.so

# Set environment
#ENV JAVA_HOME /opt/jdk
#ENV PATH ${PATH}:${JAVA_HOME}/bin

# Install SBT
RUN apk add --no-cache --virtual=build-dependencies curl && \
    curl -sL "http://dl.bintray.com/sbt/native-packages/sbt/$SBT_VERSION/sbt-$SBT_VERSION.tgz" | gunzip | tar -x -C /usr/local && \
    ln -s /usr/local/sbt/bin/sbt /usr/local/bin/sbt && \
    chmod 0755 /usr/local/bin/sbt && \
    apk del build-dependencies

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
