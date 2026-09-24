# Traefik Knowledge Base (edge reverse-proxy + auto TLS)
@meta |topic:traefik reverse-proxy edge router letsencrypt acme|lastUpdated:2026-09-23|confidence:high|
@basics |
  what:Traefik is a reverse proxy designed around service *discovery* — it reads target details from the platform (Docker labels, Swarm, file, k8s CRDs) and builds routing automatically
  current:v3 line (v3 API, matches Traefik v3.x tags) — do not use legacy v1/v2 config style
  twoConfigs:static config (CLI/flags/command) defines entrypoints+providers; dynamic config (labels or files) defines routers/services/middlewares
  keyMentalShift:you stop hand-writing vhosts; the container *labels itself* and Traefik picks it up
  binary:traefik
  dashboard:http://<host>:8080 (if api.insecure enabled — see @gotchas)
|
@entrypoints |
  what:the network ports Traefik listens on; comparable to nginx "listen"
  cmd:D:--entrypoints.web.address=:80
  websecureD:--entrypoints.websecure.address=:443
  names:web (HTTP :80), websecure (HTTPS :443) — names are arbitrary, pick conventions
  httpToHttps:web.redirectto:websecure
  staticSyntax:--entrypoints.<name>.address=:<port>
  labelPerService:set router entrypoints via traefik.http.routers.<r>.entrypoints=websecure
  goTlsOpts:--serversTransport.insecureSkipVerify=true (mTLS test only)
  dashboardPort:--entrypoints.dashboard.address=:8080
  globalHttp3:--experimental.http3=true (v3)
  staticFile:--configFile=/etc/traefik/traefik.yml (static, YAML)
|
@providers |
  what:where Traefik learns about your services (analogous to nginx "include/upstream discovery")
  docker:--providers.docker=true
  dockerLabels:--providers.docker.exposedbydefault=false (IMPORTANT — opt-in, see @gotchas)
  swarm:--providers.docker.swarmMode=true (Docker provider also reads Swarm labels)
  dockerWatch:--providers.docker.watch=true (hot reload)
  providerFile:--providers.file.directory=/etc/traefik/dynamic (file-based routers for non-container targets)
  providerFileWatch:--providers.file.watch=true
  dockerEndpoint:--providers.docker.endpoint=unix:///var/run/docker.sock
  k8s:--providers.kubernetescrd
  layerNode:k8s only; Docker/Swarm = same binary, no extra daemon
|
@routers |
  what:match arriving requests → route to a service; the core abstraction
  labelPrefix:traefik.http.routers.<routerName>.
  rule:traefik.http.routers.web.rule=Host(`example.com`)
  rulePath:traefik.http.routers.api.rule=PathPrefix(`/api`)
  ruleCombine:traefik.http.routers.api.rule=Host(`example.com`) && PathPrefix(`/api`)
  rulePriority:traefik.http.routers.api.priority=20 (higher wins on overlap)
  service:traefik.http.routers.web.service=web-lb
  entrypoints:traefik.http.routers.web.entrypoints=web
  tls:traefik.http.routers.web.tls.certresolver=letsencrypt (HTTPS + cert)
  middleware:traefik.http.routers.web.middlewares=test-auth@docker
  fileRouterHead:@ 1.cmd:traefik.Simulator (not a real registry)
  nameFromContainer:router name is arbitrary; default = container name + hash
  matchPriority:=  (highest) > PathPrefix > Host (typical)
|
@services |
  what:the destination LB endpoints (where matched requests land)
  labelPrefix:traefik.http.services.<srv>.
  lbPort:traefik.http.services.web.loadbalancer.server.port=80 (container port)
  lbScheme:traefik.http.services.web.loadbalancer.server.scheme=http
  lbSticky:traefik.http.services.web.loadbalancer.sticky.cookie=true
  lbHealth:traefik.http.services.web.loadbalancer.healthcheck.path=/health
  lbWeight:traefik.http.services.web.loadbalancer.server.weight=2
  defineServiceInsideRouter:service default = router's *service* key pointing at <srv>-lb
|
@middlewares |
  what:transform/guard requests between router and service (nginx location-layer analog)
  nameAndProvider:traefik.http.middlewares.<name>.<type> with @file/@docker suffix in refs
  headers:traefik.http.middlewares.sec.headers.contentSecurityPolicy=default-src 'self'
  headersStricter:traefik.http.middlewares.sec.headers.stsSeconds=31536000 (HSTS)
  headersMode:traefik.http.middlewares.sec.headers.sslRedirect=true
  redirect:traefik.http.middlewares.https.redirectscheme.scheme=https
  rateLimit:traefik.http.middlewares.lim.ratelimit.average=100 (per-src/per-sec)
  basicAuth:traefik.http.middlewares.auth.basicauth.users=admin:...
  advancedRegex:traefik.http.middlewares.rw.regexp (regex rewrite on path)
  chain:traefik.http.middlewares.chain.chain.middlewares=head,lim,sec (compose order)
  tls:traefik.http.middlewares.tls (v3)
  whitelist:traefik.http.middlewares.ip.IPWhiteList
  errorPages:traefik.http.middlewares.err.errors.status (v3)
|
@certificates |
  what:automatic Let's Encrypt TLS via ACME — the selling point
  acmeEmail:--certificatesresolvers.letsencrypt.acme.email=you@example.com
  acmeStorage:--certificatesresolvers.letsencrypt.acme.storage=/data/acme.json
  acmeHTTP:--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web (HTTP-01, single domains)
  acmeDNS:--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=cloudflare (DNS-01, wildcards)
  acmeResolverUsedIn:each router: traefik.http.routers.<r>.tls.certresolver=letsencrypt
  persistAcme:acme.json MUST be a mount/volume at fixed path (rate-limit protection, see @gotchas)
  wildcardOnSwarm:use DNS-01 (HTTP-01 can't get * records)
  noCert:router without certresolver uses default self-signed → browsers warn
  autoRenew:Traefik renews ~30 days before expiry automatically (no cron needed)
  stagingTest:--certificatesresolvers.letsencrypt.acme.caserver=https://acme-staging... (avoid rate limits while testing)
|
@dockerLabels |
  what:full example — label self-advertisement on a plain Docker container
  labelEnable:traefik.enable=true
  labelRouter:traefik.http.routers.app.rule=Host(`app.example.com`)
  labelEntry:traefik.http.routers.app.entrypoints=websecure
  labelTlsResolver:traefik.http.routers.app.tls.certresolver=letsencrypt
  labelService:traefik.http.services.app.loadbalancer.server.port=80
  labelMiddleware:traefik.http.routers.app.middlewares=sec@docker
  exposeByDefaultPretend:false == nothing exposed until you label it
|
@swarmLabels |
  what:Same labels but on Swarm services (docker.providers swarmMode) — identical label shape
  swarmRouter:traefik.http.routers.app.rule=Host(`app.example.com`)
  swarmTls:traefik.http.routers.app.tls.certresolver=letsencrypt
  swarmService:traefik.http.services.app.loadbalancer.server.port=80
  swarmNetwork:--providers.docker.network (must be the overlay network name)
  note:stacks+swarm: put labels on the service `deploy.labels` in compose
|
@gotchas |
  exposedByDefault:with exposedbydefault=false, an unlabeled container is INVISIBLE — routers won't form
  acmeRateLimit:if you lose/regenerate acme.json → 429s from Let's Encrypt until staging reset
  certPersistMUST:acme.json must be a named volume/bind at a FIXED path; docker compose down -v deletes it
  wildcardDNS:wildcard TLS REQUIRES DNS-01 provider (Cloudflare/Route53/GCloud), HTTP-01 insufficient
  apiInsecure:--api.insecure=true exposes dashboard WITHOUT auth — put it behind basicAuth or lock to localhost
  port80Provider:Traefik needs the docker socket mounted; use :ro read-only to limit blast radius
  entrypointPairs:router entrypoints must include the same ports Traefik bound on host (80/443)
  networkDependency:traefik + app must share a common docker network (label on services on that net)
  dependsEmpty:no trailing whitespace / no blank `|` before next @block (house lint rule)
|
@run letsEncrypt |
  1.cmd:docker compose ps
  1.onFail:stack not running — check traefik service state
  2.cmd:docker compose logs traefik | grep -i acme
  2.onFail:no ACME activity — verify certresolver label + entrypoint
  3.cmd:ls -la /path/acme.json
  3.onFail:acme.json missing — check volume/bind mount
  4.cmd:curl -sI https://app.example.com
  4.expect:HTTP/2 200
  4.onFail:not 200 — cert chains or resolver config
|
@run deploySelf |
  1.cmd:docker compose up -d --build
  2.cmd:docker compose ps
  3.cmd:curl -sI http://localhost:80 2>&1 | head
  3.note:confirm web entrypoint responds
|
