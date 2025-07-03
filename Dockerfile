FROM debian:bullseye-slim

# Install required tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      openjdk-17-jre-headless \
      openjdk-17-jdk-headless \
      wget unzip bash coreutils ca-certificates \
      zip lib32stdc++6 lib32z1 libc6-i386 && \
    rm -rf /var/lib/apt/lists/*

# Install apktool (same version as pinned in nix)
RUN wget https://github.com/iBotPeaches/Apktool/releases/download/v2.11.1/apktool_2.11.1.jar -O /usr/local/bin/apktool.jar && \
    echo '#!/bin/sh\nexec java -jar /usr/local/bin/apktool.jar "$@"' > /usr/local/bin/apktool && \
    chmod +x /usr/local/bin/apktool

# Install Android SDK command-line tools
WORKDIR /opt/android
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
    unzip commandlinetools-linux-*.zip -d cmdline-tools && \
    mkdir -p $HOME/android-sdk/cmdline-tools && \
    mv cmdline-tools/cmdline-tools $HOME/android-sdk/cmdline-tools/latest && \
    ls $HOME/android-sdk/cmdline-tools/latest/bin/ && \
    yes | $HOME/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=$HOME/android-sdk "build-tools;30.0.3" && \
    ln -s $HOME/android-sdk/build-tools/30.0.3/apksigner /usr/local/bin/apksigner && \
    chmod +x /usr/local/bin/apksigner

# Ensure apksigner.jar is available and add symlink for convenience
RUN ln -s $HOME/android-sdk/build-tools/30.0.3/lib/apksigner.jar /usr/local/bin/apksigner.jar && \
    chmod +x /usr/local/bin/apksigner.jar

# Copy our script and make it executable
COPY patch-habitica.sh /usr/local/bin/patch-habitica
RUN chmod +x /usr/local/bin/patch-habitica

# Create working directory
WORKDIR /patcher
VOLUME /patcher

ENTRYPOINT ["/usr/local/bin/patch-habitica"]
