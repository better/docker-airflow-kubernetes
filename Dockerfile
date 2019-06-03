# Modified from puckel/docker-airflow

FROM python:3.6-slim
LABEL maintainer="Better"

ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8

ARG AIRFLOW_VERSION=1.10.3
ARG AIRFLOW_HOME=/usr/local/airflow
ARG PYTHON_DEPS=""
ENV AIRFLOW_GPL_UNIDECODE yes
ENV AIRFLOW_HOME=${AIRFLOW_HOME}

ENV BUILD_DEPS 'freetds-dev libkrb5-dev libsasl2-dev libssl-dev libffi-dev libpq-dev git'
RUN apt-get update -yqq && \
  apt-get upgrade -yqq && \
  apt-get install -yqq --no-install-recommends ${BUILD_DEPS} \
    apt-utils \
    build-essential \
    curl \
    default-libmysqlclient-dev \
    freetds-bin \
    locales \
    netcat \
    rsync && \
  sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen && \
  locale-gen && \
  update-locale LANG=${LANG} LC_ALL=${LC_ALL} && \
  useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow && \
  pip install -U pip setuptools wheel && \
  pip install pytz pyOpenSSL ndg-httpsclient pyasn1 && \
  pip install apache-airflow[all] && \
  pip install 'redis>=2.10.5,<3' && \
  if [ -n "${PYTHON_DEPS}" ]; then pip install ${PYTHON_DEPS}; fi && \
  apt-get purge --auto-remove -yqq ${BUILD_DEPS} && \
  apt-get autoremove -yqq --purge && apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man /usr/share/doc /usr/share/doc-base

EXPOSE 8080 8793
USER airflow

RUN mkdir -p ${AIRFLOW_HOME}/airflow/dags
WORKDIR ${AIRFLOW_HOME}
