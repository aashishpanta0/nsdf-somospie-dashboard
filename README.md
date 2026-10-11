# NSDF Somospie Dashboard

Interactive [Panel](https://panel.holoviz.org/)/Bokeh dashboard, built on
OpenVisus and `openvisuspy`, for exploring the NSDF SOMOSPIE
CONUS 30 m terrain parameters dataset streamed from Wasabi S3.

The repo includes the source code, a `Dockerfile`, a `docker-compose.yml`, and a
GitHub Actions workflow ([`.github/workflows/docker.yml`](.github/workflows/docker.yml))
that builds the image and publishes it to
[`ghcr.io/aashishpanta0/nsdf-somospie-dashboard`](https://github.com/aashishpanta0/nsdf-somospie-dashboard/pkgs/container/nsdf-somospie-dashboard).

## Quick start (published image)

```sh
cp .env.example .env      # adjust if needed
docker compose pull
docker compose up -d
```

Open <http://localhost:11657/somospie>. Follow logs with `docker compose logs -f`;
stop with `docker compose down` (add `--volumes` to also drop the OpenVisus cache).

## Build locally

```sh
cp .env.example .env
docker compose up --build -d
```

The image is built for `linux/amd64` (OpenVisus wheels). On Apple Silicon it
runs under emulation; the first build takes a few minutes.

## Run with Docker only

```sh
docker run --rm -p 11657:11657 ghcr.io/aashishpanta0/nsdf-somospie-dashboard:latest \
    --address 0.0.0.0 --port 11657 --args "<dataset-url>"
```

Quote the dataset URL, since it contains `&`. The container's entrypoint is
`python -m panel serve somospie`, so any extra arguments go to `panel serve`.

## Configuration (`.env`)

| Variable | Default | Purpose |
| --- | --- | --- |
| `SOMOSPIE_DATASET` | *(required)* | OpenVisus dataset URL passed via `--args` |
| `SOMOSPIE_IMAGE` | `ghcr.io/aashishpanta0/nsdf-somospie-dashboard:latest` | Image to pull/tag |
| `SOMOSPIE_PLATFORM` | `linux/amd64` | Image platform |
| `SOMOSPIE_BIND_ADDRESS` | `127.0.0.1` | Host interface to publish on (`0.0.0.0` to expose) |
| `SOMOSPIE_PORT` | `11657` | Container and host port |
| `SOMOSPIE_LISTEN_ADDRESS` | `0.0.0.0` | Address the server listens on inside the container |
| `SOMOSPIE_ALLOW_WS_ORIGIN` | `*` | Allowed WebSocket origin(s); set to your public hostname in production |

`.env` is git-ignored and excluded from the image.

## Releases

Every push to `main` publishes `:latest` and `:sha-<commit>`. Tagging `vX.Y.Z`
also publishes `:X.Y.Z`:

```sh
git tag v1.0.0 && git push origin v1.0.0
```

Pull requests build the image (a smoke test, since the build imports
OpenVisus and `openvisuspy`) without pushing it.

## Run without Docker

```sh
python -m pip install bokeh panel ipywidgets ipywidgets_bokeh OpenVisus boto3 xmltodict aiohttp colorcet matplotlib
PYTHONPATH=src BOKEH_ALLOW_WS_ORIGIN='*' \
    python -m panel serve src/openvisuspy/dashboards --dev --args "<dataset-url>"
```

This serves the app at <http://localhost:5006/dashboards>.

---

# Instructions


## Windows PIP installation

(OPTONAL) Remove old environment:

```bat
.venv\Scripts\deactivate
rmdir /s /q  .venv
rmdir /s /q  "%USERPROFILE%\.jupyter"
```

Install new version:
- use python `3.10` or `3.11`. 
- **DO NOT** use `python312` does not have a good match for `libzmq`
- use  JupyterLab v3 (**NOT v4**) because bokeh does not work
  - https://github.com/bokeh/jupyter_bokeh/issues/197

```bash
python -m venv .venv
.venv\Scripts\activate
where python

# OPTIONAL
# python.exe -m pip install --upgrade pip

# removed `itkwidgets`, since pyvista seems to be better maintained/compatible
#   see https://github.com/imjoy-team/imjoy-jupyterlab-extension/issues/6#issuecomment-1898703563
#      `imjoy` is needed for itkwidgets on jupyterlab
python -m pip install --verbose --no-cache --no-warn-script-location boto3 colorcet fsspec numpy imageio urllib3 pillow xarray xmltodict  plotly requests scikit-image scipy seaborn tifffile pandas tqdm matplotlib  zarr altair cartopy dash fastparquet folium geodatasets geopandas geoviews lxml numexpr scikit-learn sqlalchemy statsmodels vega_datasets xlrd yfinance pyarrow pydeck h5py hdf5plugin netcdf4 nexpy nexusformat nbgitpuller intake ipysheet ipywidgets bokeh ipywidgets-bokeh panel holoviews hvplot datashader vtk pyvista trame trame-vtk trame-vuetify notebook "jupyterlab==3.6.6" jupyter_bokeh jupyter-server-proxy  jupyterlab-system-monitor "pyviz_comms>=2.0.0,<3.0.0" "jupyterlab-pygments>=0.2.0,<0.3.0" 


# in debug just use local paths
# set PYTHONPATH=C:\projects\OpenVisus\build\RelWithDebInfo;.\src
python -m pip install OpenVisusNoGui openvisuspy

# test import 
python -c "import OpenVisus"
python -c "import openvisuspy"

# save the output for the future
pip freeze 
```

## Test Volume rendering

```bash
# test pyvista
python examples/python/test-pyvista.py

# test vtk volume
python examples/python/test-vtkvolume.py 
```


## Run Dashboards 


Change as needed:

```bash
set BOKEH_ALLOW_WS_ORIGIN=*
set BOKEH_LOG_LEVEL=debug
set VISUS_CPP_VERBOSE=1
set VISUS_NETSERVICE_VERBOSE=1
set VISUS_VERBOSE_DISKACCESS=0
set VISUS_CACHE=c:/tmp/visus-cache

python -m panel serve src/openvisuspy/dashboards --dev --args "D:/visus-datasets/david_subsampled/visus.idx"
python -m panel serve src/openvisuspy/dashboards --dev --args "D:/visus-datasets/2kbit1/zip/hzorder/visus.idx"

python -m panel serve src/openvisuspy/dashboards --dev --args "D:/visus-datasets/signal1d/visus.idx"

python -m panel serve src/openvisuspy/dashboards --dev --args "D:/visus-datasets/chess/nsdf-group/dashboards.json"


python -m panel serve src/openvisuspy/dashboards --dev --args "D:\visus-datasets\chess\nsdf-group\datasets\near-field-nexus\visus.idx"

# not sure why I cannot cache in arco an IDX that is NON arco
python -m panel serve src/openvisuspy/dashboards --dev --args "https://atlantis.sci.utah.edu/mod_visus?dataset=david_subsampled&cached=idx" 
python -m panel serve src/openvisuspy/dashboards --dev --args "https://atlantis.sci.utah.edu/mod_visus?dataset=2kbit1&cached=idx"

```

## Run notebooks

### Setup Jupyter Lab

```bash

# check jupyter paths
where jupyter
jupyter kernelspec list

# Check extensions:
#   **all extensions should show `enabled ok...`**
#   e.g you will need @bokeh/jupyter_bokeh    for bokeh   (installed by `jupyter_bokeh``)
#   e.g you will need @pyviz/jupyterlab_pyviz for panel   (installed by `pyviz_comms``)
#   avoid any message `is not compatible with the current JupyterLab` message at the bottom
jupyter labextension list

# Build recommended, please run `jupyter lab build`:
#   @plotly/dash-jupyterlab needs to be included in build
pip install nodejs-bin[cmd]
jupyter lab clean --all
jupyter lab build 
# rmdir /s /q C:\Users\scrgi\AppData\Local\Yarn 
# Look also for additional extensions loaded from here
# dir .venv\share\jupyter\lab\extensions\*
jupyter labextension list
```

```bash

# is this avoiding any caching/security problem? not sure
python scripts/run_command.py "jupyter nbconvert --clear-output --inplace {notebook}" "examples/notebooks/*.ipynb"
python scripts/run_command.py "jupyter trust {notebook}"                              "examples/notebooks/*.ipynb"

jupyter lab .
```


## Developers only

Deploy new binaries

- **Update the `PROJECT_VERSION` inside `pyproject.toml`**

```bash
# source .venv/bin/activate
./scripts/new_tag.sh
```

