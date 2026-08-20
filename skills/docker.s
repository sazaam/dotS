# Docker Knowledge Base
@meta |topic:docker|lastUpdated:2026-08-17|confidence:high|
@basics |
  daemon:dockerd
  cli:docker
  compose:docker compose (v2)
  config:~/.docker/config.json
  hub:docker.io
  registry:ghcr.io (GitHub), ecr (AWS)
|
@containers |
  run:docker run -d --name myapp image
  runInteractive:docker run -it image sh
  runPort:docker run -d -p 8080:80 image
  runEnv:docker run -d -e KEY=value image
  runVolume:docker run -d -v /host:/container image
  runNetwork:docker run -d --network mynet image
  stop:docker stop container
  start:docker start container
  restart:docker restart container
  remove:docker rm container
  forceRemove:docker rm -f container
  exec:docker exec -it container sh
  logs:docker logs container
  logsFollow:docker logs -f container
  inspect:docker inspect container
  stats:docker stats
  top:docker top container
  cp:docker cp container:/path /host
|
@images |
  build:docker build -t name:tag .
  buildNoCache:docker build --no-cache -t name:tag .
  buildArg:docker build --build-arg KEY=value -t name:tag .
  pull:docker pull image:tag
  push:docker push image:tag
  tag:docker tag image:tag new:tag
  list:docker images
  remove:docker rmi image
  prune:docker image prune -a
  history:docker history image
  save:docker save image > image.tar
  load:docker load < image.tar
|
@dockerfile |
  from:FROM node:22-alpine
  workdir:WORKDIR /app
  copy:COPY package*.json ./
  run:RUN npm ci --production
  copy2:COPY . .
  expose:EXPOSE 3000
  cmd:CMD ["node", "server.js"]
  entrypoint:ENTRYPOINT ["node"]
  arg:ARG NODE_ENV=production
  env:ENV NODE_ENV=production
  user:USER node
  healthcheck:HEALTHCHECK --interval=30s CMD curl -f http://localhost/
  multiStage:use multiple FROM for smaller images
|
@compose |
  version:3.8
  up:docker compose up -d
  upBuild:docker compose up -d --build
  down:docker compose down
  downVolumes:docker compose down -v
  ps:docker compose ps
  logs:docker compose logs -f
  logsService:docker compose logs -f service
  exec:docker compose exec service sh
  restart:docker compose restart service
  scale:docker compose up -d --scale service=3
|
@volumes |
  create:docker volume create myvol
  list:docker volume ls
  inspect:docker volume inspect myvol
  remove:docker volume rm myvol
  prune:docker volume prune
  bindMount:-v /host/path:/container/path
  namedVolume:-v myvol:/container/path
  readOnly:-v /host:/container:ro
  tmpfs:--tmpfs /container/path
|
@networks |
  create:docker network create mynet
  list:docker network ls
  inspect:docker network inspect mynet
  remove:docker network rm mynet
  prune:docker network prune
  bridge:default network type
  host:--network host
  none:--network none
  connect:docker network connect mynet container
|
@multiStage |
  builder:FROM node:22 AS builder
  buildStage:COPY --from=builder /app/dist ./dist
  scratch:FROM scratch (empty image)
  alpine:FROM alpine:3.19 (small base)
  distroless:FROM gcr.io/distroless (no shell)
|
@optimization |
  layerCache:copy package.json before npm install
  multiStage:build in one stage, copy to smaller stage
  .dockerignore:exclude node_modules, .git
  alpine:use alpine variants for smaller images
  prune:RUN npm cache clean --force
  combine:combine RUN commands with &&
|
@composeExample |
  version:3.8
  services.app.build:.
  services.app.ports:3000:3000
  services.app.volumes:./src:/app/src
  services.app.environment:NODE_ENV=development
  services.app.depends_on:db
  services.db.image:postgres:16-alpine
  services.db.volumes:pgdata:/var/lib/postgresql/data
  services.db.environment:POSTGRES_PASSWORD=secret
  volumes.pgdata:defined
|
@debugging |
  logs:docker logs container
  inspect:docker inspect container
  exec:docker exec -it container sh
  stats:docker stats --no-stream
  events:docker events
  diff:docker diff container
  port:docker port container
  top:docker top container
  df:docker system df
|
@gotchas |
  containerRemoval:docker rm container (stop first or use -f)
  imageCleanup:docker system prune -a (removes all unused)
  permIssues:match USER in Dockerfile with host UID
  permFix:chown -R 1000:1000 /app (match node user)
  networkAccess:containers see each other by service name
  volumePerms:init containers to fix permissions
  envOrder:env vars override Dockerfile ENV
  buildContext:. is the build context, use .dockerignore
  layerBloat:combine RUN, minimize layers
  debugShell:docker exec -it container /bin/sh
  noCurl:alpine images lack curl, use wget or add it
  healthcheck:HEALTHCHECK prevents "unhealthy" in compose
|
@run buildPush |
  1.cmd:docker build -t $IMAGE:$TAG .
  1.onFail:build failed — check Dockerfile and build context
  2.cmd:docker tag $IMAGE:$TAG $REGISTRY/$IMAGE:$TAG
  3.cmd:docker push $REGISTRY/$IMAGE:$TAG
  3.onFail:push failed — check registry login and permissions
  4.cmd:docker image prune -f
  4.note:clean up dangling images
|
@run composeUp |
  1.cmd:docker compose ps
  1.note:check current state before starting
  2.cmd:docker compose up -d --build
  2.onFail:start failed — check docker compose logs
  3.cmd:docker compose ps
  3.onFail:not all containers running — check logs
  4.cmd:docker compose logs --tail=20
  4.note:verify startup output
|
@run composeRestart |
  1.cmd:docker compose down
  2.cmd:docker compose up -d --build
  2.onFail:restart failed — check docker compose logs
  3.cmd:docker compose ps
  3.onFail:containers not healthy — investigate logs
|
@run cleanSlate |
  1.cmd:docker compose down -v
  1.note:stop containers and remove volumes
  2.cmd:docker system prune -a --force
  2.note:remove all unused images, containers, networks
  3.cmd:docker system df
  3.note:verify disk reclaimed
|
@run healthCheck |
  1.cmd:docker compose ps --format "table {{.Name}}\t{{.Status}}"
  1.note:check all container statuses
  2.cmd:docker compose logs --tail=10 --since=5m
  2.note:recent activity across all services
  3.cmd:docker stats --no-stream
  3.note:resource usage snapshot
|
