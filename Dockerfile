FROM debian:buster

ENV ARCHI_VERSION=4.8.1
ENV COARCHI_VERSION=0.7.1.202102021056

# Install Windows Manager dependecies and tools (wget, tar, zip...)
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends dbus-x11 at-spi2-core libgtk3.0-cil xvfb wget openssh-client rsync ca-certificates tar xzip gzip bzip2 zip unzip && \
		rm -rf /var/lib/apt/lists && \
		mkdir -p /usr/share/desktop-directories 

# Install Archi
RUN wget --post-data="dl=Archi-Linux64-${ARCHI_VERSION}.tgz" -o "Archi-Linux64-${ARCHI_VERSION}.tgz" "https://www.archimatetool.com/downloads/archi/" && \
		tar zxvf "index.html" -C /opt/ && \
		rm "Archi-Linux64-${ARCHI_VERSION}.tgz" && \
		rm "index.html" && \
		chmod +x /opt/Archi/Archi && \
		mkdir -p /root/.archi4/dropins

# Install CoArchi plugin 
RUN wget "https://www.archimatetool.com/downloads/coarchi/org.archicontribs.modelrepository_${COARCHI_VERSION}.archiplugin" && \
    unzip "org.archicontribs.modelrepository_${COARCHI_VERSION}.archiplugin" -d /root/.archi4/dropins && \
		rm "org.archicontribs.modelrepository_${COARCHI_VERSION}.archiplugin" /root/.archi4/dropins/archi-plugin

# User space by default
VOLUME [ /data ]		

# Entrypoint and prepare settings overwrite
COPY entrypoint.sh /entrypoint.sh
COPY archi-wrapper.sh /opt/Archi/archi-wrapper.sh
RUN chmod +x /entrypoint.sh && \
		chmod +x /opt/Archi/archi-wrapper.sh && \
		ln -s /opt/Archi/archi-wrapper.sh /usr/local/bin/archi && \
    mkdir -p "/root/.archi4/.metadata/.plugins/org.eclipse.core.runtime/.settings"
COPY com.archimatetool.script.prefs /root/.archi4/.metadata/.plugins/org.eclipse.core.runtime/.settings

ENTRYPOINT ["/entrypoint.sh"]
CMD [ "archi", "--help" ]