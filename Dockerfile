FROM python:3.10.2-slim-bullseye
# FROM postgres:15-alpine3.18
# FROM ubuntu

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

COPY . .

RUN apt-get update && \
   apt-get install -y libpq-dev postgresql postgresql-contrib postgresql-client nginx \
   && rm -rf /var/lib/apt/lists/*

RUN chmod -R 777 ./

# RUN apt-get update && \
#    apt-get install -y python3.10 python3-pip libpq-dev postgresql postgresql-contrib postgresql-client nginx \
#    && rm -rf /var/lib/apt/lists/*

# RUN apt-get install -y libpq-dev postgresql postgresql-contrib postgresql-client nginx \
#    && rm -rf /var/lib/apt/lists/*

RUN pip install -r requirements.txt

# RUN CREATE DATABASE dbadmin; 
# RUN CREATE USER adimn WITH PASSWORD 'admin';
# RUN GRANT ALL PRIVILEGES ON DATABASE dbadmin TO admin;
# RUN \q

RUN rm /etc/nginx/sites-enabled/default

COPY ./conf/projectconf /etc/nginx/sites-enabled/projectconf

USER postgres
RUN /etc/init.d/postgresql start &&\
   psql --command "CREATE USER admin WITH PASSWORD 'admin';" &&\
   createdb -O admin admin

# USER root
# ENV POSTGRES_USER admin
# ENV POSTGRES_PASSWORD admin
# ENV POSTGRES_DB dbadmin

# RUN  /etc/init.d/postgresql start

# CMD cd project && python3 manage.py createsuperuser --no-input && python3 manage.py makemigrations \
#    && python3 manage.py migrate && gunicorn project.wsgi:aplication --bind 127.0.0.1:8000

CMD cd project && python3 manage.py runserver

