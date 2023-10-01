FROM python:3.10.2-slim-bullseye

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

COPY . .

RUN apt-get update && apt-get install -y libpq-dev postgresql postgresql-contrib postgresql-client nginx \
   && rm -rf /var/lib/apt/lists/*

RUN chmod -R 777 ./
RUN chmod -R 777 ./* 

# && chown root startUpScript.sh \
# && chgrp root startUpScript.sh \
# && chmod 777 startUpScript.sh

RUN rm /etc/nginx/sites-enabled/default

COPY ./conf/projectconf /etc/nginx/sites-enabled/projectconf

RUN pip install -r requirements.txt

# RUN CREATE DATABASE admin; 
# RUN CREATE USER adimn WITH PASSWORD 'admin';
# RUN GRANT ALL PRIVILEGES ON DATABASE admin TO admin;
# RUN \q

USER postgres 

RUN /etc/init.d/postgresql start &&\
   psql --command "CREATE USER admin WITH PASSWORD 'admin';" &&\
   createdb -O admin admin

# RUN service postgresql restart

# CMD cd project && python3 manage.py createsuperuser --no-input && python3 manage.py makemigrations \
#    && python3 manage.py migrate && gunicorn project.wsgi:aplication --bind 127.0.0.1:8000
EXPOSE 8000

CMD /bin/bash && /etc/init.d/postgresql start && cd project && python3 manage.py makemigrations \
   && python3 manage.py migrate && python3 manage.py runserver
# CMD ["/bin/bash","-c","startUpScript.sh"]

