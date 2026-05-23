FROM python:3.12

RUN mkdir /app

WORKDIR /app

RUN apt update
RUN apt upgrade -y
RUN apt-get install -y libjpeg-dev zlib1g-dev default-libmysqlclient-dev pkg-config default-mysql-client

RUN pip install --upgrade pip

COPY requirements.txt /app/

RUN pip install -r requirements.txt

COPY . /app/

RUN chmod +x /app/docker-entrypoint.sh

EXPOSE 8000

CMD ["/app/docker-entrypoint.sh"]