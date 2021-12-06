# FROM launcher.gcr.io/google/ubuntu20_04
FROM ubuntu:latest


RUN apt-get update && apt-get -y install \
    curl \
    tmux \
    gcc \
    vim \
    python \
    python3 \
    libgmp3-dev \
    python-pkg-resources \
    python3-pkg-resources \
    software-properties-common \
    unzip && \

    # Install Git >2.0.1
    add-apt-repository ppa:git-core/ppa && \
    apt-get -y update && \
    apt-get -y install git

ADD fetch-bazel-bindist /tmp/fetch-bazel-bindist
ADD bazel-4.1.0-linux-x86_64.sha256 /tmp/bazel-4.1.0-linux-x86_64.sha256

RUN mkdir /opt/bazel && BAZEL_DIR="$(/tmp/fetch-bazel-bindist)" && mv $BAZEL_DIR/bazel /opt/bazel
RUN chmod 777 -R /opt/bazel

# Store the Bazel outputs under /workspace so that the symlinks under bazel-bin (et al) are accessible
# to downstream build steps.
RUN mkdir -p /workspace
RUN echo 'startup --output_base=/workspace/.bazel' > ~/.bazelrc

ENV PATH="/opt/bazel:${PATH}"

RUN apt-get -y install build-essential libtinfo5
RUN apt-get -y install default-jre
RUN apt-get -y install default-jdk
RUN apt-get -y install libtinfo-dev
ENTRYPOINT ["/opt/bazel/bazel"]
