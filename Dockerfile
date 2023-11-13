FROM python:3.9.12-slim-bullseye

ARG dbt_bigquery_ref=dbt-bigquery@v1.7.1

# System setup
RUN apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y --no-install-recommends \
    git \
    ssh-client \
    software-properties-common \
    make \
    build-essential \
    ca-certificates \
    libpq-dev \
    vim \
  && apt-get clean \
  && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

# Env vars
ENV PYTHONIOENCODING=utf-8
ENV LANG=C.UTF-8
ENV GOOGLE_APPLICATION_CREDENTIALS=/usr/app/dbt/project/.secret/secret.json

# Update python
RUN python -m pip install --upgrade pip setuptools wheel --no-cache-dir

# dbt-bigquery
RUN python -m pip install --no-cache-dir "git+https://github.com/dbt-labs/${dbt_bigquery_ref}#egg=dbt-bigquery"

WORKDIR /usr/app/dbt/project
VOLUME /usr/app

ENTRYPOINT tail -f /dev/null
