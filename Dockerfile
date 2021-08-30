FROM python:3.8-alpine

RUN pip install --no-cache-dir \
    flask

VOLUME /certs

COPY . /app
WORKDIR /app

EXPOSE 10443/TCP

CMD ["python", "app.py"]
