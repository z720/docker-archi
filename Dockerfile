# GET sources to tagged version
FROM alpine/git as git
ENV ARCHI_VERSION=4.9.3
ENV COARCHI_VERSION=0.8.3
WORKDIR /sources/archi
RUN git clone https://github.com/archimatetool/archi.git .
RUN git fetch --all --tags
RUN git checkout tags/release_${ARCHI_VERSION} -b build

# build with maven podman run -it -v archi-repo:/data -w /data/archi  maven:3.8-openjdk-11 mvn clean package -P product
FROM maven:3.8-openjdk-11 as editor
COPY --from=git /sources/archi /sources/archi
WORKDIR /sources/archi
RUN sed -i 's|</environments>|<environment><os>linux</os><ws>gtk</ws><arch>aarch64</arch></environment></environments>|g'  /sources/archi/pom.xml
RUN mvn clean package -P product

# Start container image
FROM debian:latest

COPY --from=editor /sources/archi/com.archimatetool.editor.product/target/products/com.archimatetool.editor.product/linux/gtk/aarch64/Archi/ /opt/Archi
# RUN mkdir -p /opt/Archi/dropins
COPY plugins/* /opt/Archi/dropins/
# Install required system dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends dbus-x11 at-spi2-core libgtk3.0-cil xvfb wget openssh-client rsync ca-certificates tar xzip gzip bzip2 zip unzip && \
	rm -rf /var/lib/apt/lists && \
	mkdir -p /usr/share/desktop-directories && \
	chmod +x /opt/Archi/Archi && \
	for z in /opt/Archi/dropins/*.archiplugin; do echo "Try to activate plugin $z"; unzip -o "$z" -d /opt/Archi/dropins; done
# User space by default
VOLUME ["/data"]

# https://www.archimatetool.com/downloads/

# Entrypoint and prepare settings overwrite
COPY entrypoint.sh /entrypoint.sh
COPY archi-wrapper.sh /opt/Archi/archi-wrapper.sh
RUN chmod +x /entrypoint.sh  && \
		chmod +x /opt/Archi/archi-wrapper.sh && \
		ln -s /opt/Archi/archi-wrapper.sh /usr/local/bin/archi
RUN mkdir -p /root/.archi4/.metadata/.plugins/org.eclipse.core.runtime/.settings
COPY com.archimatetool.script.prefs /root/.archi4/.metadata/.plugins/org.eclipse.core.runtime/.settings

ENTRYPOINT ["/entrypoint.sh"]
CMD [ "archi", "--help" ]

