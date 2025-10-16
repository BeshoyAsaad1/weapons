# --------------------------------------------
# ✅ Final fixed Dockerfile for Django + Gunicorn + Oracle
# --------------------------------------------

FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# 🧩 Install system dependencies including Oracle Instant Client
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc build-essential curl libaio1 wget unzip \
    && rm -rf /var/lib/apt/lists/*

# 🧩 Install Oracle Instant Client
RUN mkdir -p /opt/oracle && \
    cd /opt/oracle && \
    wget https://download.oracle.com/otn_software/linux/instantclient/2113000/instantclient-basic-linux.x64-21.13.0.0.0dbru.zip && \
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
RUN python -m ensurepip --upgrade && \
    pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt && \
    pip install gunicorn

# 🧩 Copy the Django project
COPY . .

# 🧩 Collect static files
RUN python manage.py collectstatic --noinput || true

EXPOSE 8000

# 🧩 Start Gunicorn
CMD ["bash", "-c", "python manage.py migrate && exec gunicorn weaponpowercloud_backend.wsgi:application --bind 0.0.0.0:8000 --workers 3"]
