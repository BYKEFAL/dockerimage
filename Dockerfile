FROM python:3.10.2-slim-bullseye

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

COPY . .

RUN apt-get update && apt-get install -y libpq-dev postgresql postgresql-contrib postgresql-client nginx \
   && rm -rf /var/lib/apt/lists/*

RUN chmod -R 777 ./ && chmod -R 777 ./* 

RUN rm /etc/nginx/sites-enabled/default

COPY ./conf/projectconf /etc/nginx/sites-enabled/projectconf

RUN pip install -r requirements.txt

USER postgres 

RUN /etc/init.d/postgresql start &&\
   psql --command "CREATE USER admin WITH PASSWORD 'admin';" &&\
   createdb -O admin admin

# CMD cd project && python3 manage.py createsuperuser --no-input && python3 manage.py makemigrations \
#    && python3 manage.py migrate && gunicorn project.wsgi:aplication --bind 127.0.0.1:8000

EXPOSE 8000

CMD /bin/bash && /etc/init.d/postgresql start && cd project \
   && python3 manage.py makemigrations \
   && python3 manage.py migrate \
   && echo "from django.contrib.auth.models import User; \
   User.objects.create_superuser('admin','admin@mail.ru', 'admin')" |  python manage.py shell \
   && echo \
   && echo "admin_login:admin, admin_password:admin" \
   && echo \
   && python3 manage.py runserver

