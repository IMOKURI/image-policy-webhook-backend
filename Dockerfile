FROM python:3.8-alpine

RUN pip install --no-cache-dir \
    flask

COPY . /app
WORKDIR /app

EXPOSE 8000/TCP

CMD ["python", "app.py"]
