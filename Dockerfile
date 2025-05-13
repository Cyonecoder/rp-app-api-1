FROM python:3.9-alpine3.13

LABEL maintainer="simocodercyone.com"

# Avoid writing .pyc files and force stdout flush
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/py/bin:$PATH"

# Install build dependencies for Python and virtualenv support
RUN apk add --no-cache \
    build-base \
    libffi-dev \
    gcc \
    musl-dev \
    linux-headers \
    postgresql-dev \
    python3-dev \
    libxml2-dev \
    libxslt-dev \
    && python3 -m venv /py

# Copy project files
ARG DEV=FALSE
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

COPY ./app /app
WORKDIR /app

# Install Python dependencies inside venv
RUN /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "TRUE" ]; then \
        /py/bin/pip install -r /tmp/requirements.dev.txt; \
    fi && \
    rm -rf /tmp

# Create a non-root user
RUN adduser --disabled-password --no-create-home django-user && \
    chown -R django-user /app

USER django-user

EXPOSE 8000
