FROM python:3.10-slim-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt /app
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app
EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]