FROM rockylinux:9
ARG NOBUILD=0
LABEL CODENAME="Blue Onyx"
RUN dnf update --assumeyes && dnf install --assumeyes \
    dnf-plugins-core \
    epel-release \
    ansible-core \
    git \
    vim \
    && dnf distro-sync --assumeyes

WORKDIR /root/source/ansible
COPY . ./
RUN ansible-galaxy collection install --requirements-file=requirements.yml \
    && ./mythtv.yml --limit=localhost --extra-vars='{"venv_active":true}'

WORKDIR /root/source
RUN git clone https://github.com/MythTV/mythtv.git

WORKDIR /root/source/mythtv
RUN if [ "${NOBUILD}" -eq 1 ]; then \
        echo "Not doing a build." ;\
    else \
        git checkout fixes/35 \
        && cmake --preset qt5 \
        && VIRTUAL_ENV=/usr/local/dist cmake --build build-qt5 ;\
    fi
