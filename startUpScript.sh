#!/bin/bash
/etc/init.d/postgresql start
cd project
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py runserver