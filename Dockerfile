# NSDF SOMOSPIE Dashboard, served as "somospie" (ghcr.io/aashishpanta0/nsdf-somospie-dashboard).
# The address and port are not baked in; pass them at run time (see README.md):
#   docker run -p 11657:11657 <image> --address 0.0.0.0 --port 11657 --args <dataset>

# Build stage: install the Python dependencies into a virtualenv.
FROM python:3.12-slim-bookworm AS build

# OpenVisus ships Linux wheels for x86_64 only, so the image is linux/amd64.
# OpenVisusNoGui is OpenVisus without the Qt viewer, which the dashboard never uses.
RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir --no-warn-script-location --only-binary=:all: \
        panel bokeh param numpy requests xmltodict colorcet \
        ipywidgets ipywidgets-bokeh ipykernel OpenVisusNoGui \
        matplotlib \
    && /opt/venv/bin/pip uninstall -y pip

# Runtime stage: only the virtualenv and the dashboard code.
FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH=/opt/venv/bin:$PATH \
    PYTHONPATH=/opt/openvisuspy/src \
    BOKEH_ALLOW_WS_ORIGIN=* \
    VISUS_CACHE=/var/cache/visus

COPY --from=build /opt/venv /opt/venv
COPY src /opt/openvisuspy/src
COPY src/openvisuspy/dashboards /opt/openvisuspy/somospie

RUN python -c "import OpenVisus, openvisuspy" \
    && useradd --create-home --uid 10001 dashboard \
    && mkdir -p /var/cache/visus /data \
    && chown dashboard:dashboard /var/cache/visus /data

WORKDIR /opt/openvisuspy
USER dashboard

ENTRYPOINT ["python", "-m", "panel", "serve", "somospie"]
CMD ["--args", "https://s3.us-east-1.wasabisys.com/scientistcloud/utk/nsdf_somospie/conus_30m_terrain/CONUS_30m_Terrain_Parameters.idx?access_key=Y69B9WJPYXDQBM4DE8LL&secret_key=LJEz1AUsvTW6uNJc67NNgfD3IfNYrIY54zps6PWU&endpoint_url=https://s3.us-east-1.wasabisys.com&cached=arco"]
