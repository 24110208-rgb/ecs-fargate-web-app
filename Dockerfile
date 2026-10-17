# ==========================================
# Stage 1: Build dependencies
# ==========================================
FROM python:3.13-slim AS builder

WORKDIR /build

COPY requirements.txt .

RUN python -m pip install \
    --no-cache-dir \
    --prefix=/install \
    -r requirements.txt


# ==========================================
# Stage 2: Runtime
# ==========================================
FROM python:3.13-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=5000

WORKDIR /app

# Create a non-root user
RUN useradd --create-home --uid 10001 appuser

# Copy installed dependencies from builder
COPY --from=builder /install /usr/local

# Copy application source code
COPY --chown=appuser:appuser app/ /app/

# Run the application as a non-root user
USER appuser

EXPOSE 5000

CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:${PORT:-5000} --workers 2 --access-logfile - --error-logfile - app:app"]