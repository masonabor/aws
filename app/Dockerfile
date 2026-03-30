FROM python:3.11-slim
WORKDIR /usr/src/app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]