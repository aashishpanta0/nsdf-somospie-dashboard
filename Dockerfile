# NSDF SOMOSPIE Dashboard (ghcr.io/aashishpanta0/nsdf-somospie-dashboard).
# Runtime defaults are the ENV values below; README.md documents how to run it.

FROM python:3.12-slim-bookworm AS builder

# OpenVisus publishes Linux wheels for x86_64 only, so the image is linux/amd64.
RUN python -m venv /opt/venv \
    && /opt/venv/bin/python -m pip install --no-cache-dir --no-warn-script-location --only-binary=:all: \
        bokeh panel ipywidgets OpenVisus ipywidgets_bokeh ipykernel \
        boto3 xmltodict aiohttp colorcet matplotlib \
    && /opt/venv/bin/python -m pip uninstall -y pip

FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH=/opt/venv/bin:$PATH \
    PYTHONPATH=/opt/dashboard/src \
    VISUS_CACHE=/var/cache/visus \
    DASHBOARD_APP=/opt/dashboard/somospie \
    DATASET="https://s3.us-east-1.wasabisys.com/scientistcloud/utk/nsdf_somospie/conus_30m_terrain/CONUS_30m_Terrain_Parameters.idx?access_key=Y69B9WJPYXDQBM4DE8LL&secret_key=LJEz1AUsvTW6uNJc67NNgfD3IfNYrIY54zps6PWU&endpoint_url=https://s3.us-east-1.wasabisys.com&cached=arco" \
    PORT=8080 \
    BOKEH_ALLOW_WS_ORIGIN=*

COPY --from=builder /opt/venv /opt/venv
COPY src /opt/dashboard/src
COPY src/openvisuspy/dashboards /opt/dashboard/somospie
COPY --chmod=0755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Fail the build early if the dashboard cannot be imported.
RUN python -c "import OpenVisus, openvisuspy, panel" \
    && test -f "$DASHBOARD_APP/main.py" \
    && useradd --create-home --uid 10001 dashboard \
    && mkdir -p /var/cache/visus /data \
    && chown dashboard:dashboard /var/cache/visus

WORKDIR /opt/dashboard
USER dashboard
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD python -c "import os, urllib.request; urllib.request.urlopen('http://127.0.0.1:%s/liveness' % os.environ['PORT'], timeout=4)"

ENTRYPOINT ["docker-entrypoint.sh"]
