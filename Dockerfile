FROM python:3.10.2-slim-bullseye

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

COPY . .

RUN apt-get update && apt-get install -y libpq-dev postgresql \
   postgresql-contrib postgresql-client nginx gunicorn \
   && rm -rf /var/lib/apt/lists/*

RUN chmod -R 777 ./ && chmod -R 777 ./* 

RUN rm /etc/nginx/sites-enabled/default
RUN rm /etc/nginx/sites-available/default
COPY ./conf/projectconf /etc/nginx/sites-available/projectconf
RUN ln -s /etc/nginx/sites-available/projectconf /etc/nginx/sites-enabled/

RUN pip install -r requirements.txt

COPY ./conf/gunicorn.socket /etc/systemd/system/
COPY ./conf/gunicorn.service /etc/systemd/system/

USER postgres 
RUN /etc/init.d/postgresql start &&\
   psql --command "CREATE USER admin WITH PASSWORD 'admin';" &&\
   createdb -O admin admin

EXPOSE 80

USER root

CMD /bin/bash && /etc/init.d/postgresql start \ 
   && service nginx start \
   && nginx -s reload \
   && cd project \
   && python3 manage.py collectstatic --noinput \
   # && python3 manage.py makemigrations \
   && python3 manage.py migrate \
   && echo "from django.contrib.auth.models import User; \
   User.objects.create_superuser('admin','admin@mail.ru', 'admin')" |  python manage.py shell \
   && echo \
   && echo "admin_login:admin, admin_password:admin" \
   && echo \
   # && service nginx restart \
   && gunicorn project.wsgi:application --bind 127.0.0.1:8000
# && python3 manage.py runserver

