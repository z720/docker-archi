######################################################################################################################
# Sources ############################
# GET sources to tagged version
FROM alpine/git as git
ENV ARCHI_VERSION=5.0.2
WORKDIR /sources/archi
RUN git clone https://github.com/archimatetool/archi.git .
RUN git fetch --all --tags
RUN git checkout tags/release_${ARCHI_VERSION} -b build

######################################################################################################################
# Plugins download ############################
FROM debian:11 as dl
ENV COARCHI_VERSION=0.8.8

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends  unzip curl ca-certificates

# https://www.archimatetool.com/downloads/coarchi/coArchi_0.8.8.archiplugin
WORKDIR /downloads
RUN curl -#Lo coArchi_${COARCHI_VERSION}.archiplugin --request POST "https://www.archimatetool.com/downloads/coarchi/coArchi_${COARCHI_VERSION}.archiplugin"


######################################################################################################################
# Build with Maven ###################### 
# podman run -it -v archi-repo:/data -w /data/archi  maven:3.8-openjdk-11 mvn clean package -P product
FROM maven:3-eclipse-temurin-17 as editorbuilder
COPY --from=git /sources/archi /sources/archi
WORKDIR /sources/archi
RUN sed -i 's|</environments>|<environment><os>linux</os><ws>gtk</ws><arch>aarch64</arch></environment></environments>|g'  /sources/archi/pom.xml
RUN mvn clean package -P product

######################################################################################################################
# Runtime ########################
# Start container image
FROM debian:11

# Install required system dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends dbus-x11 at-spi2-core libgtk3.0-cil xvfb wget openssh-client rsync ca-certificates tar xzip gzip bzip2 zip unzip curl && \
		apt-get install -y --no-install-recommends openjdk-17-jre && \
		apt-get clean && \
		rm -rf /var/lib/apt/lists && \
		mkdir -p /usr/share/desktop-directories

ENV ARCHI_VERSION=5.0.2
ENV COARCHI_VERSION=0.8.8

ARG TARGETPLATFORM
COPY --from=editorbuilder /sources/archi/com.archimatetool.editor.product/target/products/com.archimatetool.editor.product/linux/gtk/aarch64/Archi/ /archi/arm64
COPY --from=editorbuilder /sources/archi/com.archimatetool.editor.product/target/products/com.archimatetool.editor.product/linux/gtk/x86_64/Archi/ /archi/amd64
RUN TARGET=$(echo "${TARGETPLATFORM}" | cut -d "/" -f 2); echo $TARGET; ln -s /archi/${TARGET} /archi/app;
RUN mkdir -p /archi/app/dropins
COPY --from=dl /downloads/coArchi_${COARCHI_VERSION}.archiplugin /archi/app/dropins/
COPY plugins/* /archi/app/dropins/

RUN chmod +x /archi/app/Archi;


# RUN shopt -s nullglob; 
RUN for z in /archi/app/dropins/*.archiplugin; do echo "Try to activate plugin $z"; unzip -o "$z" -d /archi/app/dropins; done
# User space by default
VOLUME ["/data"]

# Entrypoint and prepare settings overwrite
COPY entrypoint.sh /entrypoint.sh
COPY archi-wrapper.sh /archi/app/archi-wrapper.sh

RUN chmod +x /entrypoint.sh  && \
		chmod +x /archi/app/archi-wrapper.sh && \
		ln -s /archi/app/archi-wrapper.sh /usr/local/bin/archi
# RUN mkdir -p /root/.archi4/.metadata/.plugins/org.eclipse.core.runtime/.settings
# RUN mkdir -p /archi/.archi4/.metadata/.plugins/org.eclipse.core.runtime/.settings
# COPY com.archimatetool.script.prefs /archi/.archi4/.metadata/.plugins/org.eclipse.core.runtime/.settings

ARG UID=1000

RUN set -eux; \
    # mv /root/.archi /archi/; \
    groupadd --gid "$UID" archi; \
    useradd --uid "$UID" --gid archi --shell /bin/bash \
      --home-dir /archi --create-home archi; \
    mkdir -p /archi/app; \
    chown -R "$UID:0" /archi; \
    chmod -R g+rw /archi;

USER archi

WORKDIR /data

ENTRYPOINT ["/entrypoint.sh"]
CMD [ "archi", "--help" ]

