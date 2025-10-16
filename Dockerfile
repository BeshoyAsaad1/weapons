# --------------------------------------------
# ✅ Robust Dockerfile for Django + Gunicorn + Oracle
# --------------------------------------------

FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# 🧩 Install system dependencies with retry logic
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
        gcc \
        g++ \
        libc6-dev \
        make \
        curl \
        wget \
        unzip \
        libaio1 \
        libaio-dev \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 🧩 Install Oracle Instant Client (with error handling)
RUN mkdir -p /opt/oracle && \
    cd /opt/oracle && \
    wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 3 \
        https://download.oracle.com/otn_software/linux/instantclient/2113000/instantclient-basic-linux.x64-21.13.0.0.0dbru.zip && \
    unzip instantclient-basic-linux.x64-21.13.0.0.0dbru.zip && \
    rm -f instantclient-basic-linux.x64-21.13.0.0.0dbru.zip && \
    cd /opt/oracle/instantclient* && \
    rm -f *jdbc* *occi* *mysql* *README *jar uidrvci genezi adrci && \
    echo /opt/oracle/instantclient* > /etc/ld.so.conf.d/oracle-instantclient.conf && \
    ldconfig

# 🧩 Set Oracle environment variables
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_21_13:$LD_LIBRARY_PATH \
    PATH=/opt/oracle/instantclient_21_13:$PATH

# 🧩 Install Python packages
COPY requirements.txt .
RUN python -m pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir gunicorn

# 🧩 Copy the Django project
COPY . .

# 🧩 Create necessary directories
RUN mkdir -p /app/staticfiles /app/media /app/logs && \
    chmod -R 755 /app/staticfiles /app/media /app/logs

# 🧩 Collect static files
RUN python manage.py collectstatic --noinput || true

EXPOSE 8000

# 🧩 Start Gunicorn with migrations
CMD ["bash", "-c", "python manage.py migrate && exec gunicorn weaponpowercloud_backend.wsgi:application --bind 0.0.0.0:8000 --workers 3 --timeout 120"]
