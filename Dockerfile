# these args are adjustable to update the images without changing the Dockerfile
ARG UBUNTU_RELEASE=24.04
ARG MSSQL_RELEASE=18

FROM ubuntu:${UBUNTU_RELEASE}
ARG UBUNTU_RELEASE
ARG MSSQL_RELEASE

ARG LANG=en_US.UTF-8

# these come from the build environment on GitHub
ARG GIT_COMMIT
ARG GIT_TAG

# these args are just used during the build
ARG ACCEPT_EULA="Y"
ARG DEBIAN_FRONTEND="noninteractive"
ARG AG="apt-get -yq --no-install-recommends"

RUN set -eux; \
    $AG update; \
    $AG upgrade; \
    $AG install \
        apt-transport-https \
        build-essential \
        debconf-utils \
        gnupg2 \
        locales \
        python3 \
        python3-pip \
        wget \
    ; \
    # add MS apt repo
    REPO_DEB="/tmp/packages-microsoft-prod.deb"; \
    wget -q https://packages.microsoft.com/config/ubuntu/${UBUNTU_RELEASE}/packages-microsoft-prod.deb \
        -O "${REPO_DEB}"; \
    dpkg -i "${REPO_DEB}"; \
    rm "${REPO_DEB}"; \
    # install SQL Server drivers and tools
    $AG update; \
    $AG install \
        msodbcsql${MSSQL_RELEASE} \
        mssql-tools${MSSQL_RELEASE} \
    ; \
    $AG autoremove; \
    $AG clean; \
    rm -rf /var/lib/apt/lists/*;

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/mssql-tools${MSSQL_RELEASE}/bin
RUN ln -s /usr/bin/python3 /usr/bin/python

RUN set -eux; \
    locale-gen ${LANG}; \
    update-locale LANG=${LANG}

COPY requirements.txt /
RUN pip install --no-cache-dir --break-system-packages -r /requirements.txt

# create a non-root account for the code to run with
ARG NONROOT_UID=65532
ARG NONROOT_GID=65532
RUN set -eux; \
  groupadd --gid "${NONROOT_GID}" "nonroot"; \
  useradd \
    --no-log-init \
    --base-dir / \
    --home-dir "/home/nonroot" \
    --create-home \
    --shell "/bin/bash" \
    --uid "${NONROOT_UID}" \
    --gid "${NONROOT_GID}" \
    "nonroot" \
  ; \
  passwd --lock "nonroot";

WORKDIR /work
