# --------------------------------------------
# ✅ Simplified Dockerfile using Oracle Thin Mode (No Instant Client needed)
# --------------------------------------------

FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# 🧩 Install minimal system dependencies (only what's needed for Python packages)
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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

# 🧩 Collect static files (may fail on first build, that's ok)
RUN python manage.py collectstatic --noinput || true

EXPOSE 8000

# 🧩 Start Gunicorn with migrations
CMD ["bash", "-c", "python manage.py migrate && exec gunicorn weaponpowercloud_backend.wsgi:application --bind 0.0.0.0:8000 --workers 3 --timeout 120 --log-level info"]
