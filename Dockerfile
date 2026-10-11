FROM python:3.12-slim-bookworm AS builder

RUN python -m venv /opt/venv \
    && /opt/venv/bin/python -m pip install --no-cache-dir --only-binary=OpenVisus \
        bokeh panel ipywidgets OpenVisus ipywidgets_bokeh ipykernel \
        boto3 xmltodict aiohttp colorcet matplotlib \
    && /opt/venv/bin/python -m pip uninstall -y pip

FROM python:3.12-slim-bookworm AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/opt/openvisuspy/src \
    PATH=/opt/venv/bin:$PATH \
    BOKEH_ALLOW_WS_ORIGIN=* \
    VISUS_CACHE=/var/cache/visus

COPY --from=builder /opt/venv /opt/venv
COPY src /opt/openvisuspy/src

RUN python -c "import OpenVisus; import openvisuspy; import matplotlib" \
    && test -f /opt/openvisuspy/src/openvisuspy/dashboards/main.py

RUN useradd --create-home --uid 10001 dashboard \
    && ln -s /opt/openvisuspy/src/openvisuspy/dashboards /opt/openvisuspy/somospie \
    && mkdir -p /var/cache/visus \
    && chown dashboard:dashboard /var/cache/visus

WORKDIR /opt/openvisuspy
USER dashboard

# The dataset URL carries Wasabi credentials, so it is not baked into the
# image; pass it at runtime with `--args <dataset-url>`.
ENTRYPOINT ["python", "-m", "panel", "serve", "somospie"]
