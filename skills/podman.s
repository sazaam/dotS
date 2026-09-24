# Podman Knowledge Base
@meta |topic:podman daemonless rootless quadlet compose|lastUpdated:2026-09-23|confidence:high|
@basics |
  what:containers without a centralized root daemon — no dockerd, no containerd, no daemon socket as control plane
  model:each podman command forks/execs directly; conmon supervises; crun/runc runs OCI runtime (default crun)
  rootless:default — rootless-by-default on Linux; rootless containers map root inside to your unprivileged UID
  cli:podman (Docker-compatible CLI; alias docker=podman covers common verbs)
  images:same OCI images as Docker — images are interchangeable
  build:podman build (Buildah under the hood); skopeo for registry ops
  compose:podman compose (delegates to docker-compose or podman-compose) / podman-compose
  systemd:Quadlet/Quadlet integrates containers as native systemd units
  license:Apache 2.0, free at any company size; no Docker Desktop-style paid tier
  stack:podman 6.x current; daemonless + rootless are the architectural pillars
|
@vsDocker |
  table:podman daemonless+rootless vs docker client-server root daemon (dockerd)
  security:podman removes the privileged root daemon attack surface; breakout lands in unprivileged account
  rootful:docker default runs root daemon; rootless docker is opt-in and less-tested
  licensing:docker desktop requires paid subscription for orgs >250 employees or >$10M revenue; podman free
  systemd:quadlet=first-class native systemd units vs docker needs init scripts/generate wrappers
  tooling:docker has the mature ecosystem (compose most features, third-party GUI, tutorials)
  socket:Docker tools assume /var/run/docker.sock; podman exposes compat socket via podman socket activate
  CI:Docker is the safer default for CI runners whose secrets/tooling assume the docker socket
  immutables:podman shines on immutable hosts (Fedora CoreOS / RHEL CoreOS) via Quadlet
  migration:swap docker for podman usually works; compose tweaks + fully-qualified image names needed
  mixedOps:many run both — docker on tinker box, podman where rootless/systemd matters
|
@rootless |
  what:rootless containers by default — no root daemon, no root-created containers by CLI
  mapping:host UID maps to root inside container via user namespaces (see /etc/subuid range)
  storage:rootless storage under ~/.local/share/containers (not /var/lib/docker)
  networking:rootless nets via pasta (replacing slirp4netns); netavark default for bridges
  ports:rootless cannot bind privileged ports (<1024) without sysctl net.ipv4.ip_unprivileged_port_start
  security:container root = your unprivileged UID on host; escape lands in your account not root
  volumes:bind-mount file ownership defaults to your user (not root) — perm issues differ from docker
  rootful:podman ran as root still possible for when you need it (podman run --privileged)
  cgroups:user-delegated tree under user.slice; systemd user manager owns lifecycle
|
@images |
  fullyQualify:always use docker.io/library/nginx:alpine not bare nginx (podman respects registry config)
  pull:podman pull docker.io/library/nginx:alpine
  push:podman push quay.io/user/app:1.0
  tag:podman tag image new:tag
  list:podman images
  build:podman build -t name:tag .
  multiArch:buildah for multi-arch; qemu user emulation needed for foreign archs (not automatic)
  inspect:podman inspect image
  storage:podman image storage under containers/storage (overlay); prune with podman image prune
  login:podman login registry (uses auth file: $XDG_RUNTIME_DIR/containers/auth.json)
|
@run |
  run:podman run -d --name myapp image
  runInteractive:podman run -it image sh
  runPort:podman run -d -p 8080:80 image
  runPortRootless:low ports need sysctl; use 8080:80 and proxy on 80
  runEnv:podman run -d -e KEY=value image
  runVolume:podman run -d -v /host:/container image
  runNetwork:podman run -d --network mynet image
  runPod:podman run -d --pod mypod image (shared net namespace)
  exec:podman exec -it container sh
  logs:podman logs container
  ps:podman ps
  stats:podman stats --no-stream
  stop:podman stop container
  rm:podman rm container
  composeDeploy:podman compose up -d (needs podman-compose or docker-compose backend)
|
@pods |
  what:pod = group of containers sharing network namespace + lifecycle (K8s-like)
  create:podman pod create --name mypod -p 8080:80
  runInPod:podman run -d --pod mypod image
  list:podman pod ps
  inspect:podman pod inspect mypod
  restart:podman pod restart mypod
  why:sidecars / tightly-coupled containers; use separately for independent scaling
  kube:podman play kube / generate kube export pods as k8s YAML
|
@compose |
  what:run Compose files with podman; supports docker-compose.yml service model
  backend:podman compose → docker-compose; podman-compose → podman-native python backend
  composeUp:podman compose up -d
  composeDown:podman compose down -v
  composeLogs:podman compose logs -f app
  composeExec:podman compose exec app sh
  compat:standard compose services mostly work; advanced v3 features may not (depends_on semantics, some healthchecks, macvlan)
  build:compose build may need podman backend; test with podman compose config
  trick:Podman socket (podman.socket) for tools expecting the Docker API/DOCKER_HOST
  gotcha:no docker swarm/stack — pods are the closest; use k8s if you need cluster orchestration
|
@quadlet |
  what:Quadlet — declare containers as systemd unit files; pods/volumes/networks too
  file:purpose-driven unit files (nginx.container) in ~/.config/containers/systemd/
  unit:systemd generator turns each file into a real service unit (.service)
  reload:systemctl --user daemon-reload
  start:systemctl --user start nginx (or nginx.service)
  boot:systemctl --user enable nginx (auto-start with [Install] in the Quadlet file)
  paths:/etc/containers/systemd/ (root), ~/.config/containers/systemd/ (rootless user)
  rootlessQuadlet:/etc/containers/systemd/users/ or .../users/$UID for per-user units
  deps:After=/Requires= equivalents via systemd options in the file
  logs:journalctl --user -u nginx
  why:replaces podman generate systemd; containers behave like native services
|
@systemd |
  note:podman generate systemd is deprecated; use Quadlet for new work
  legacy:podman generate systemd container still works but no new features
  quadlet:Quadlet known in linux.s @systemd workflow; units integrate boot order/restarts
  linger:systemctl --user enable with loginctl enable-linger $USER for boot-start rootless
|
@gotchas |
  noDaemon:tools that watch the Docker daemon/events won't work — no dockerd events
  aliasGap:alias docker=podman breaks for tools relying on dockerd socket/lifecycle/plugins
  privilegedPorts:rootless can't bind <1024 by default; use high port + reverse proxy, or lower sysctl
  composeNuance:advanced Compose v3 fields (depends_on beyond start-order, some healthchecks) don't fully map
  crossArch:any foreign-arch container needs qemu-user setup; not automatic, may reset after reboot
  dockerBuildkit:podman compose build differs from Docker BuildKit; DOCKER_BUILDKIT=0 avoids surprises
  dbDoc:Docker-desc writing differs — OK
  permDiffs:bind-mount files owned by your user not root; chmod/chown pattern differs from Docker
  socketTools:give tools the podman socket (systemctl --user start podman.socket) not docker.sock
  swarm:no real Swarm/Stack; pods are close, Kubernetes is the cluster answer
|
@run buildPush |
  1.cmd:podman build -t $REGISTRY/$IMAGE:$TAG .
  1.note:build image (Buildah path)
  2.cmd:podman push $REGISTRY/$IMAGE:$TAG
  2.note:push to registry (needs podman login first)
  3.cmd:podman images | grep $IMAGE
  3.note:verify built image present
|
@run composeUp |
  1.cmd:podman compose config
  1.note:validate/expand compose file (catches mapping errors early)
  2.cmd:podman compose up -d
  2.note:start stack (needs podman-compose or docker-compose backend)
  3.cmd:podman compose ps
  3.note:check all services running
  4.cmd:podman compose logs --tail=10
  4.note:recent activity across services
|
@run quadletInstall |
  1.cmd:mkdir -p ~/.config/containers/systemd
  1.note:rootless Quadlet unit search path
  2.cmd:cp server.container ~/.config/containers/systemd/
  2.note:place Quadlet file (creates server.service)
  3.cmd:systemctl --user daemon-reload
  3.note:regenerate units from Quadlet files
  4.cmd:systemctl --user start server
  4.note:start the generated service
  5.cmd:systemctl --user status server
  5.note:confirm running
|
@run quadletEnable |
  1.cmd:systemctl --user enable server
  1.note:boot-time auto-start ([Install] block required in file)
  2.cmd:systemctl --user restart server
  2.note:apply config/style-update
  3.cmd:journalctl --user -u server -f
  3.note:tail service logs
|
