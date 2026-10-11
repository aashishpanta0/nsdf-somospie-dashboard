# NSDF Somospie Dashboard

Interactive Panel/Bokeh dashboard for exploring the NSDF SOMOSPIE CONUS 30 m
terrain parameters dataset, streamed from Wasabi S3 with OpenVisus.

The Docker image is published at
[`ghcr.io/aashishpanta0/nsdf-somospie-dashboard`](https://github.com/aashishpanta0/nsdf-somospie-dashboard/pkgs/container/nsdf-somospie-dashboard).

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) with Docker Compose (Docker Desktop includes both)
- Git

Check that Docker is running:

```sh
docker --version
docker compose version
```

## Option A: Run with Docker Compose (recommended)

**1. Clone the repository**

```sh
git clone https://github.com/aashishpanta0/nsdf-somospie-dashboard.git
cd nsdf-somospie-dashboard
```

**2. Create your `.env` file**

```sh
cp .env.example .env
```

The defaults work as-is. Edit `.env` only if you want a different port,
dataset, or to expose the dashboard on your network (see [Configuration](#configuration)).

**3. Pull the image**

```sh
docker compose pull
```

**4. Start the dashboard**

```sh
docker compose up -d
```

**5. Open the dashboard**

Go to <http://localhost:11657/somospie> in your browser.
The first load can take a few seconds while the dataset is fetched.

**6. View logs (optional)**

```sh
docker compose logs -f
```

Press `Ctrl+C` to stop following the logs (the dashboard keeps running).

**7. Stop the dashboard**

```sh
docker compose down
```

To also delete the cached data volume:

```sh
docker compose down --volumes
```

**Updating to the latest image**

```sh
git pull
docker compose pull
docker compose up -d
```

## Option B: Run with Docker only (no Compose)

**1. Pull the image**

```sh
docker pull ghcr.io/aashishpanta0/nsdf-somospie-dashboard:latest
```

**2. Run the container**

Replace `<dataset-url>` with the value of `SOMOSPIE_DATASET` from
[`.env.example`](.env.example). Keep the quotes, since the URL contains `&`.

```sh
docker run -d --name nsdf-somospie -p 11657:11657 \
    ghcr.io/aashishpanta0/nsdf-somospie-dashboard:latest \
    --address 0.0.0.0 --port 11657 --args "<dataset-url>"
```

**3. Open the dashboard**

Go to <http://localhost:11657/somospie>.

**4. Stop and remove the container**

```sh
docker stop nsdf-somospie
docker rm nsdf-somospie
```

## Option C: Build the image yourself

Use this if you changed the source code.

```sh
git clone https://github.com/aashishpanta0/nsdf-somospie-dashboard.git
cd nsdf-somospie-dashboard
cp .env.example .env
docker compose up --build -d
```

Then open <http://localhost:11657/somospie>.

The image targets `linux/amd64`. On Apple Silicon Macs it runs under
emulation and the first build takes a few minutes.

## Configuration

All settings live in `.env`:

| Variable | Default | Purpose |
| --- | --- | --- |
| `SOMOSPIE_DATASET` | *(required)* | OpenVisus dataset URL the dashboard opens |
| `SOMOSPIE_IMAGE` | `ghcr.io/aashishpanta0/nsdf-somospie-dashboard:latest` | Image to pull or tag |
| `SOMOSPIE_PLATFORM` | `linux/amd64` | Image platform |
| `SOMOSPIE_BIND_ADDRESS` | `127.0.0.1` | Host interface; set `0.0.0.0` to allow access from other machines |
| `SOMOSPIE_PORT` | `11657` | Port on the host and in the container |
| `SOMOSPIE_LISTEN_ADDRESS` | `0.0.0.0` | Listen address inside the container (leave as is) |
| `SOMOSPIE_ALLOW_WS_ORIGIN` | `*` | Allowed WebSocket origin(s); set to your public hostname in production |

After editing `.env`, apply the changes with `docker compose up -d`.

## Troubleshooting

- **Port already in use:** change `SOMOSPIE_PORT` in `.env`, then open
  `http://localhost:<new-port>/somospie`.
- **Page loads but stays blank behind a proxy or on a server:** set
  `SOMOSPIE_ALLOW_WS_ORIGIN` to the hostname you browse to (for example
  `dashboard.example.org`).
- **Can't reach it from another machine:** set `SOMOSPIE_BIND_ADDRESS=0.0.0.0`.
- **Check whether it is running:** `docker compose ps`

## Releases

Every push to `main` publishes `:latest` and `:sha-<commit>` through
[GitHub Actions](.github/workflows/docker.yml). Tagging `vX.Y.Z` also
publishes `:X.Y.Z`:

```sh
git tag v1.0.0 && git push origin v1.0.0
```

## More information

This dashboard is built on [openvisuspy](https://github.com/sci-visus/openvisuspy).
For non-Docker installation, other dashboards, notebooks, and development
instructions, see the [openvisuspy repository](https://github.com/sci-visus/openvisuspy).
