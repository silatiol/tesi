FROM openjdk:15-jdk-buster

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /root

RUN apt-get -qqy update && \
    apt-get -qqy --no-install-recommends install \
    ca-certificates \
    zip \
    unzip \
    curl \
    wget \
    libqt5webkit5 \
    xvfb \
    xterm \
    supervisor \
    socat \
    x11vnc \
    openbox \
    python-numpy \
    net-tools \
    libpulse0

RUN cat /etc/apt/sources.list
RUN apt -qqy --no-install-recommends install qemu-kvm \
    libvirt-clients \
    libvirt-daemon-system \
    libvirt-bin \
    ubuntu-vm-builder \
    bridge-utils \
  && rm -rf /var/lib/apt/lists/*
 
	
ARG SDK_VERSION=commandlinetools-linux-6514223_latest
ARG ANDROID_BUILD_TOOLS_VERSION=29.0.2
ARG ANDROID_PLATFORM_VERSION="android-29"

ENV SDK_VERSION=$SDK_VERSION \
    ANDROID_BUILD_TOOLS_VERSION=$ANDROID_BUILD_TOOLS_VERSION \
    ANDROID_HOME=/root

RUN wget -O tools.zip https://dl.google.com/android/repository/${SDK_VERSION}.zip && \
    unzip tools.zip -d ./cmdline-tools/ && rm tools.zip && \
    chmod a+x -R $ANDROID_HOME && \
    chown -R root:root $ANDROID_HOME

ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/cmdline-tools/tools/bin

RUN ls

RUN echo y | sdkmanager "platform-tools" && \
    echo y | sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION" && \
    echo y | sdkmanager "platforms;$ANDROID_PLATFORM_VERSION"

ENV PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools

ENV NOVNC_SHA="b403cb92fb8de82d04f305b4f14fa978003890d7" \
    WEBSOCKIFY_SHA="558a6439f14b0d85a31145541745e25c255d576b"
RUN  wget -nv -O noVNC.zip "https://github.com/kanaka/noVNC/archive/${NOVNC_SHA}.zip" \
 && unzip -x noVNC.zip \
 && rm noVNC.zip  \
 && mv noVNC-${NOVNC_SHA} noVNC \
 && wget -nv -O websockify.zip "https://github.com/kanaka/websockify/archive/${WEBSOCKIFY_SHA}.zip" \
 && unzip -x websockify.zip \
 && mv websockify-${WEBSOCKIFY_SHA} ./noVNC/utils/websockify \
 && rm websockify.zip \
 && ln noVNC/vnc_auto.html noVNC/index.html
 
ARG ANDROID_VERSION=5.0.1
ARG API_LEVEL=29
ARG SYS_IMG=x86_64
ARG IMG_TYPE=google_apis
ARG BROWSER=android
ARG CHROME_DRIVER=2.40
ARG GOOGLE_PLAY_SERVICE=12.8.74
ARG GOOGLE_PLAY_STORE=11.0.50
ARG APP_RELEASE_VERSION=1.5-p0

ENV ANDROID_VERSION=$ANDROID_VERSION \
    API_LEVEL=$API_LEVEL \
    SYS_IMG=$SYS_IMG \
    IMG_TYPE=$IMG_TYPE \
    BROWSER=$BROWSER \
    CHROME_DRIVER=$CHROME_DRIVER \
    GOOGLE_PLAY_SERVICE=$GOOGLE_PLAY_SERVICE \
    GOOGLE_PLAY_STORE=$GOOGLE_PLAY_STORE
	
ENV PATH ${PATH}:${ANDROID_HOME}/build-tools

RUN yes | sdkmanager --licenses && \
    sdkmanager "platforms;android-${API_LEVEL}" "system-images;android-${API_LEVEL};${IMG_TYPE};${SYS_IMG}" "emulator"

ENV DISPLAY=:0 \
    SCREEN=0 \
    SCREEN_WIDTH=1600 \
    SCREEN_HEIGHT=900 \
    SCREEN_DEPTH=24+32 \
    LOCAL_PORT=5900 \
    TARGET_PORT=6080 \
    TIMEOUT=1 \
    VIDEO_PATH=/tmp/video \
    LOG_PATH=/var/log/supervisor

ENV QTWEBENGINE_DISABLE_SANDBOX=1
	
ADD src/rc.xml /etc/xdg/openbox/rc.xml

EXPOSE 6080 5554 5555

COPY devices /root/devices

COPY src /root/src	
COPY supervisord.conf /root/
COPY entrypoint.sh /root/
RUN chmod -R +x /root/src && chmod +x /root/supervisord.conf && chmod +x /root/entrypoint.sh

HEALTHCHECK --interval=2s --timeout=40s --retries=1 \
    CMD timeout 40 adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done'

ENTRYPOINT ["/root/entrypoint.sh"]
CMD /usr/bin/supervisord --configuration supervisord.conf

