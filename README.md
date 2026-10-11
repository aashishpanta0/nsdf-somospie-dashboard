# NSDF SOMOSPIE Dashboard

Interactive dashboard for the NSDF SOMOSPIE CONUS 30 m terrain parameters,
streamed with [OpenVisus](https://github.com/sci-visus/OpenVisus) from Wasabi S3.

The dashboard is published as a Docker image. Everything below runs that image;
you do not need to clone this repository or install Python.

| | |
| --- | --- |
| Image | `ghcr.io/aashishpanta0/nsdf-somospie-dashboard` ([package page](https://github.com/aashishpanta0/nsdf-somospie-dashboard/pkgs/container/nsdf-somospie-dashboard)) |
| Tags | `latest` (newest build of `main`) and `X.Y.Z` (releases) |
| Platform | `linux/amd64` (runs under emulation on Apple Silicon and other ARM hosts) |
| Port | `11657`, passed at run time |
| Dashboard URL | `http://<host>:11657/somospie` |

## Run with Docker

You need [Docker](https://docs.docker.com/get-docker/).

```bash
docker run -d --name nsdf-somospie -p 11657:11657 \
  ghcr.io/aashishpanta0/nsdf-somospie-dashboard:latest \
  --address 0.0.0.0 --port 11657 --args 'https://s3.us-east-1.wasabisys.com/scientistcloud/utk/nsdf_somospie/conus_30m_terrain/CONUS_30m_Terrain_Parameters.idx?access_key=Y69B9WJPYXDQBM4DE8LL&secret_key=LJEz1AUsvTW6uNJc67NNgfD3IfNYrIY54zps6PWU&endpoint_url=https://s3.us-east-1.wasabisys.com&cached=arco'
```

Open <http://localhost:11657/somospie>. The first load can take a minute while
data is fetched. Stop and remove it with `docker rm -f nsdf-somospie`.

### How the container starts

The image runs `python -m panel serve somospie`, and everything after the image
name is appended to that command. The image does not fix an address or port, so
pass them every time:

| Argument | Meaning |
| --- | --- |
| `--address 0.0.0.0` | Listen on all interfaces, so traffic from outside the container reaches the server |
| `--port 11657` | Port to listen on; publish the same one with `-p 11657:11657`. Without it, Panel uses `5006` |
| `--args <dataset>` | Dataset to open; must come last. With no arguments at all, the image opens the CONUS 30 m terrain parameters on Wasabi S3 (public read-only keys) |

Other [`panel serve` options](https://panel.holoviz.org/how_to/server/commandline.html)
go before `--args`, for example `--num-procs 4` or `--prefix /somospie`.

| Environment variable | Default | Meaning |
| --- | --- | --- |
| `BOKEH_ALLOW_WS_ORIGIN` | `*` | Host names browsers may use to reach the dashboard, comma-separated. Set it to your public host name in production |
| `VISUS_CACHE` | `/var/cache/visus` | Where OpenVisus caches downloaded data. Mount a volume there to keep it across restarts |

## Run with Docker Compose

Save this as `docker-compose.yml` (the same file is in this repository), then run
`docker compose up -d`:

```yaml
# NSDF SOMOSPIE Dashboard: run `docker compose up -d`, then open http://localhost:11657/somospie
services:
  somospie:
    image: ghcr.io/aashishpanta0/nsdf-somospie-dashboard:latest
    platform: linux/amd64
    restart: unless-stopped
    ports:
      - "11657:11657"
    command:
      - --address
      - "0.0.0.0"
      - --port
      - "11657"
      - --args
      - "https://s3.us-east-1.wasabisys.com/scientistcloud/utk/nsdf_somospie/conus_30m_terrain/CONUS_30m_Terrain_Parameters.idx?access_key=Y69B9WJPYXDQBM4DE8LL&secret_key=LJEz1AUsvTW6uNJc67NNgfD3IfNYrIY54zps6PWU&endpoint_url=https://s3.us-east-1.wasabisys.com&cached=arco"
    volumes:
      - cache:/var/cache/visus

volumes:
  cache:
```

## Run on Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: somospie
spec:
  replicas: 1
  selector:
    matchLabels:
      app: somospie
  template:
    metadata:
      labels:
        app: somospie
    spec:
      containers:
        - name: somospie
          image: ghcr.io/aashishpanta0/nsdf-somospie-dashboard:latest
          args:
            - --address
            - "0.0.0.0"
            - --port
            - "11657"
            - --args
            - "https://s3.us-east-1.wasabisys.com/scientistcloud/utk/nsdf_somospie/conus_30m_terrain/CONUS_30m_Terrain_Parameters.idx?access_key=Y69B9WJPYXDQBM4DE8LL&secret_key=LJEz1AUsvTW6uNJc67NNgfD3IfNYrIY54zps6PWU&endpoint_url=https://s3.us-east-1.wasabisys.com&cached=arco"
          ports:
            - containerPort: 11657
---
apiVersion: v1
kind: Service
metadata:
  name: somospie
spec:
  selector:
    app: somospie
  ports:
    - port: 11657
      targetPort: 11657
```

- Route your Ingress path `/somospie` to the Service. The page also loads its
  JavaScript from `/static/`, so route that too, or start the dashboard with
  `--prefix /<path>` and route only that prefix. The ingress controller must
  allow WebSocket upgrades.
- Keep `replicas: 1`, or enable session affinity: each browser session lives in
  one pod.
- Add probes as you need, e.g. a `tcpSocket` probe on port `11657`.

## Use your own dataset

Pass it after `--args`. For local files, mount their directory at `/data`:

```bash
docker run -d --name nsdf-somospie -p 11657:11657 \
  -v /path/to/datasets:/data:ro \
  ghcr.io/aashishpanta0/nsdf-somospie-dashboard:latest \
  --address 0.0.0.0 --port 11657 --args /data/my-dataset/visus.idx
```

`--args` accepts an OpenVisus `.idx` URL or path, or a JSON scene list.

## Update to the newest image

Docker keeps using the image already on your machine, so pull first:

```bash
docker pull ghcr.io/aashishpanta0/nsdf-somospie-dashboard:latest
docker rm -f nsdf-somospie
```

Then run the same `docker run` command again. With Compose, run
`docker compose pull && docker compose up -d`. To stay on a fixed release instead
of `latest`, use one of the version tags on the [package page](https://github.com/aashishpanta0/nsdf-somospie-dashboard/pkgs/container/nsdf-somospie-dashboard).

## Troubleshooting

- **Nothing answers on port 11657**: pass `--address 0.0.0.0 --port 11657`
  and publish the same port with `-p`. `docker logs nsdf-somospie` should show
  `Bokeh app running at: http://0.0.0.0:11657/somospie`.
- **Warning: `requested image's platform (linux/amd64) does not match`**:
  harmless on Apple Silicon and other ARM machines. OpenVisus has no Linux ARM
  build, so the image runs under emulation, which is slower. Add
  `--platform linux/amd64` to hide the warning. On ARM Linux without Docker
  Desktop, enable emulation once with
  `docker run --privileged --rm tonistiigi/binfmt --install amd64`.
- **Page loads but stays blank**: the browser's WebSocket connection is being
  refused. Behind a proxy or ingress, allow WebSocket upgrades and set
  `BOKEH_ALLOW_WS_ORIGIN` to the host name in the address bar.

## For maintainers

[`.github/workflows/docker.yml`](.github/workflows/docker.yml) builds the image,
starts it with `--address 0.0.0.0 --port 5006` and the default dataset, loads
the dashboard page, and fails if the dashboard logs an error. Only then is the
image published:

| Event | Published tags |
| --- | --- |
| Push to `main` | `latest` |
| Push a `vX.Y.Z` tag | `X.Y.Z` |
| Pull request | none (build and test only) |

```bash
git tag v1.0.0
git push origin v1.0.0
```

To build and run it locally:

```bash
docker build --platform linux/amd64 -t nsdf-somospie-dashboard .
docker run --rm -p 11657:11657 nsdf-somospie-dashboard --address 0.0.0.0 --port 11657 --args 'https://s3.us-east-1.wasabisys.com/scientistcloud/utk/nsdf_somospie/conus_30m_terrain/CONUS_30m_Terrain_Parameters.idx?access_key=Y69B9WJPYXDQBM4DE8LL&secret_key=LJEz1AUsvTW6uNJc67NNgfD3IfNYrIY54zps6PWU&endpoint_url=https://s3.us-east-1.wasabisys.com&cached=arco'
```

The image runs this repository's own copy of openvisuspy (from [sci-visus/openvisuspy](https://github.com/sci-visus/openvisuspy/tree/nsdf-ahm), branch `nsdf-ahm`); the
dashboard itself is in [`src/openvisuspy/dashboards/`](src/openvisuspy/dashboards). For notebooks, local Python installs, and
other dashboards, see [openvisuspy](https://github.com/sci-visus/openvisuspy).
