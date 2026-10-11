# Pact MCP endpoint. Configure with environment variables (.env) and a config folder.
FROM python:3.12-slim-bookworm

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PACT_HOST=0.0.0.0 \
    PACT_PORT=8080 \
    PACT_CONFIG_DIR=/config

WORKDIR /app

COPY pyproject.toml README.md LICENSE ./
COPY src ./src
RUN pip install . && useradd --system --uid 10001 --no-create-home pact

# Example permissions; mount your own folder (or a git-sync checkout) over /config.
COPY config /config

USER 10001
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s \
  CMD python -c "import urllib.request,os; urllib.request.urlopen(f'http://127.0.0.1:{os.environ.get(\"PACT_PORT\",\"8080\")}/health', timeout=2)"

CMD ["python", "-m", "pact_mcp"]
