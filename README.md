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

## More information

This dashboard is built on [openvisuspy](https://github.com/sci-visus/openvisuspy).
For non-Docker installation, running other dashboards, notebooks, and development
instructions, see the [openvisuspy repository](https://github.com/sci-visus/openvisuspy).
