FROM debian:bullseye-slim

# Install required tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      openjdk-17-jre-headless \
      openjdk-17-jdk-headless \
      wget unzip bash coreutils ca-certificates \
      zip lib32stdc++6 lib32z1 libc6-i386 && \
    rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Install apktool
RUN wget https://github.com/iBotPeaches/Apktool/releases/download/v2.11.1/apktool_2.11.1.jar -O /usr/local/bin/apktool.jar && \
    echo '#!/bin/sh\nexec java -jar /usr/local/bin/apktool.jar "$@"' > /usr/local/bin/apktool && \
    chmod +x /usr/local/bin/apktool

# Install Android SDK command-line tools
ENV ANDROID_SDK_ROOT=/opt/android-sdk
WORKDIR /opt/android

RUN wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
    unzip commandlinetools-linux-*.zip && \
    mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm commandlinetools-linux-*.zip

# Install build-tools and create apksigner symlink
ENV PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/build-tools/30.0.3:${PATH}"

RUN yes | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "build-tools;30.0.3" && \
    ln -sf ${ANDROID_SDK_ROOT}/build-tools/30.0.3/apksigner /usr/local/bin/apksigner

# Copy our script and make it executable
COPY patch-habitica.sh /usr/local/bin/patch-habitica
RUN chmod +x /usr/local/bin/patch-habitica

# Create working directory with proper permissions
WORKDIR /

ENTRYPOINT ["/usr/local/bin/patch-habitica"]
