FROM python:3.13.13-slim-trixie

RUN pip install --no-cache-dir 'litellm[proxy]==1.85.1'

WORKDIR /app

EXPOSE 4445

CMD ["litellm", "--config", "/app/litellm-config.yaml", "--host", "0.0.0.0", "--port", "4445"]
