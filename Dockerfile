# ---------- Base ----------
FROM node:20-bullseye

# ---------- Environment ----------
ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

# ---------- System Dependencies ----------
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    curl \
    unzip \
    git \
    gradle \
    && rm -rf /var/lib/apt/lists/*

# ---------- Enable Yarn via Corepack ----------
RUN corepack enable && corepack prepare yarn@stable --activate

# ---------- React Native CLI ----------
RUN npm install -g react-native-cli

# ---------- Android SDK ----------
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    curl -o cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
    unzip cmdline-tools.zip -d $ANDROID_SDK_ROOT/cmdline-tools && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    rm cmdline-tools.zip

# ---------- Accept Licenses ----------
RUN yes | sdkmanager --licenses

# ---------- Install Android Components ----------
RUN sdkmanager \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0"

# ---------- Workdir ----------
WORKDIR /app

# ---------- Build Command ----------
CMD ["bash", "-c", "cd android && ./gradlew assembleRelease"]
