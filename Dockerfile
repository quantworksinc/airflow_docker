FROM alpine:3.7
LABEL maintainer="it@quantworks.com"


ENV AIRFLOW_VERSION=1.10.2rc3
ENV AIRFLOW_HOME=/usr/local/airflow
ENV AIRFLOW_GPL_UNIDECODE=true

ENV AIRFLOW_USER=airflow
ENV AIRFLOW_PASS=airflow
ENV AIRFLOW_EMAIL=airflow@domain.tld

ENV AIRFLOW_DB_USER=airflow
ENV AIRFLOW_DB_PASS=airflow
ENV AIRFLOW_DB_HOST=postgres
ENV AIRFLOW_DB_PORT=5432
ENV AIRFLOW_DB_NAME=airflow

RUN mkdir /usr/local/airflow \
    && apk update \
    && apk add --no-cache \
        g++ \
        curl \
        bash \
        python3 \
        gfortran \
        musl-dev \
        libstdc++ \
        lapack-dev \
        libffi-dev \
        postgresql-client \
    && apk add --no-cache --virtual .build-deps \
        python3-dev \
        libxml2-dev \
        linux-headers \
        libxslt-dev \
        postgresql-dev \
        libressl-dev \
    && python3 -m ensurepip \
    && rm -r /usr/lib/python*/ensurepip \
    && ln -s \
        /usr/include/locale.h \
        /usr/include/xlocale.h \
    && pip3 install --upgrade \
        pip \
        setuptools \
    && pip3 install --no-binary :all: cython

RUN wget https://github.com/apache/airflow/archive/${AIRFLOW_VERSION}.tar.gz \
    && tar -xzf ${AIRFLOW_VERSION}.tar.gz \
    && cd airflow-${AIRFLOW_VERSION} \
    && pip3 install -e .[crypto,password,postgres,s3,slack] \
    && cd .. \
    && rm ${AIRFLOW_VERSION}.tar.gz

COPY ./requirements.txt .
RUN pip3 install --no-build-isolation -r ./requirements.txt \
    && rm ./requirements.txt \
    && apk del .build-deps

WORKDIR /usr/local/airflow
COPY ./init.py .
COPY ./airflow.cfg .
COPY ./entrypoint.sh .

CMD ["/usr/local/airflow/entrypoint.sh"]
