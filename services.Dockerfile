FROM python:2-alpine

RUN apk add --no-cache musl-dev gcc
RUN pip install "incremental<22" && pip install --no-build-isolation twisted==20.3.0

COPY . /app
WORKDIR /app

# TODO: verify if these ports are correct
EXPOSE 8000 9000 9002 9003 9009

ENTRYPOINT ["python", "master_server.py"]