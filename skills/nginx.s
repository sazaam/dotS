# Nginx Knowledge Base
@run sslSetup |
  1.cmd:certbot certonly --nginx -d $DOMAIN
  1.onFail:DNS not pointing to this server — verify A record
  2.cmd:nginx -t
  2.expect:
  2.onFail:config test failed — fix syntax before reload
  3.cmd:systemctl reload nginx
  3.onFail:reload failed — check error log
  4.cmd:curl -s -o /dev/null -w "%{http_code}" https://$DOMAIN
  4.expect:200
  4.onFail:SSL not working — check cert paths and HSTS
|
@run sslRenew |
  1.cmd:certbot renew --quiet
  1.onFail:renewal failed — check certbot logs
  2.cmd:systemctl reload nginx
  2.onFail:reload failed — certs may be expired
  3.cmd:echo | openssl s_client -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -dates
  3.note:verify new expiry dates
|
@run configTest |
  1.cmd:nginx -t 2>&1
  1.expect:
  1.onFail:syntax error — check config file and line number
  2.cmd:nginx -T 2>&1 | head -50
  2.note:dump effective config for inspection
|
@run troubleshoot |
  1.cmd:systemctl status nginx
  1.note:check if running and recent logs
  2.cmd:tail -20 /var/log/nginx/error.log
  2.note:recent errors
  3.cmd:ss -tlnp | grep :80
  3.note:verify port 80 is bound
  4.cmd:curl -sI http://localhost
  4.expect:HTTP/1.1
  4.onFail:nginx not responding — restart required
|
@run staticCacheSetup |
  1.cmd:nginx -t
  1.onFail:fix config before proceeding
  2.cmd:systemctl reload nginx
  3.cmd:curl -sI https://$DOMAIN/css/allbis.css | grep -i "cache-control"
  3.expect:Cache-Control
  3.onFail:cache headers not applied — check location block
|
@meta |
  topic:nginx
  lastUpdated:2026-08-17
  confidence:high
|
@core |
  version:1.27.x
  eventModel:epoll
  workerProcesses:auto
  configFile:/etc/nginx/nginx.conf
  modulesPath:/usr/lib/nginx/modules
  logFormat:combined
|
@config |
  main.workerCPU:worker_processes auto
  main.workerCPU.why:distributes across all cores
  main.workerRLimit:worker_rlimit_nofile 65535
  main.errorLog:error_log /var/log/nginx/error.log warn
  events.use:use epoll
  events.workerConnections:worker_connections 4096
  events.multiAccept:multi_accept on
  http.include:MIME types
  http.defaultType:application/octet-stream
  http.sendfile:sendfile on
  http.tcpNopush:tcp_nopush on
  http.tcpNodelay:tcp_nodelay on
  http.keepalive:keepalive_timeout 65
  http.gzip:gzip on
  http.gzipTypes:text/plain text/css application/json application/javascript text/xml
  http.gzipMinLength:gzip_min_length 1000
|
@reverseProxy |
  directive:proxy_pass
  syntax:proxy_pass http://backend
  headerForward:proxy_set_header Host $host
  headerForward.why:preserves original host header
  headerRealIP:proxy_set_header X-Real-IP $remote_addr
  headerForwardedFor:proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for
  headerProto:proxy_set_header X-Forwarded-Proto $scheme
  buffer:proxy_buffering on
  bufferSize:proxy_buffer_size 4k
  buffers:proxy_buffers 8 4k
  timeout:proxy_connect_timeout 60s
  readTimeout:proxy_read_timeout 60s
  sendTimeout:proxy_send_timeout 60s
  websocket:proxy_http_version 1.1
  websocketUpgrade:proxy_set_header Upgrade $http_upgrade
  websocketConnection:proxy_set_header Connection 'upgrade
  healthCheck:proxy_next_upstream error timeout http_502 http_503
  healthCheck.why:retry on backend failure
|
@ssl |
  directive:ssl_certificate
  protocol:ssl_protocols TLSv1.2 TLSv1.3
  ciphers:ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256
  preferServerCiphers:ssl_prefer_server_ciphers on
  sessionCache:ssl_session_cache shared:SSL:10m
  sessionTimeout:ssl_session_timeout 10m
  stapling:ssl_stapling on
  staplingVerify:ssl_stapling_verify on
  certbot:certbot certonly --nginx -d example.com
  certbotAuto:certbot renew --quiet
  certPath:/etc/letsencrypt/live/example.com
  certFullChain:fullchain.pem
  certPrivKey:privkey.pem
  hsts:add_header Strict-Transport-Security 'max-age=31536000; includeSubDomains' always
  hsts.why:force HTTPS for 1 year, protects subdomains
  ocsp:ssl_stapling_cache shared:stapling_cache:128k
|
@rateLimit |
  directive:limit_req_zone
  syntax:limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s
  syntax.why:10 requests/second per IP, 10MB shared memory
  burst:limit_req zone=api burst=20 nodelay
  burst.why:allow burst of 20 without delay
  downloadLimit:limit_conn dl_limit 5
  downloadBurst:limit_conn_zone $binary_remote_addr zone=dl_limit:10m
  status429:return 429
  retryAfter:add_header Retry-After 60
|
@security |
  serverTokens:server_tokens off
  serverTokens.why:hides nginx version from headers
  clickjacking:add_header X-Frame-Options SAMEORIGIN
  clickjacking.why:prevent clickjacking attacks
  contentType:add_header X-Content-Type-Options nosniff
  xss:add_header X-XSS-Protection '1; mode=block
  referrerPolicy:add_header Referrer-Policy strict-origin-when-cross-origin
  csp:add_header Content-Security-Policy \"default-src 'self'\
  disallowMethods:if ($request_method !~ ^(GET|HEAD|POST)$) { return 405; }
  disallowUploadSize:client_max_body_size 10m
  disallowUploadSize.why:prevent large file upload attacks
  geoBlocking:geo $blocked { default 0; 1.2.3.0/24 1; }
  geoBlockAction:if ($blocked) { return 403; }
|
@cache |
  directive:proxy_cache_path
  syntax:proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=static:10m max_size=1g
  use:proxy_cache static
  valid:proxy_cache_valid 200 1h
  valid404:proxy_cache_valid 404 1m
  bypass:proxy_cache_bypass $http_cache_control
  staleWhileRevalidate:proxy_cache_use_stale error timeout updating http_502 http_503
  staleWhy:serve stale content while backend updates
  lock:proxy_cache_lock on
  lockTimeout:proxy_cache_lock_timeout 5s
  purge:proxy_cache_purge POST /purge
  staticAssets:location ~* \.(css|js|png|jpg|gif|ico|svg)$ { expires 30d; add_header Cache-Control 'public, immutable'; }
  staticAssets.why:immutable tells browser not to revalidate
|
@loadBalance |
  upstream:backend
  method:round-robin
  method.alt:ip-hash
  method.alt.why:session persistence
  syntax:upstream backend { server 10.0.0.1:8080; server 10.0.0.2:8080; }
  healthCheck:server 10.0.0.1:8080 max_fails=3 fail_timeout=30s
  backup:server 10.0.0.3:8080 backup
  backup.why:only used when primary servers down
  weights:server 10.0.0.1:8080 weight=3
  weights.why:3x more traffic to this server
  sticky:ip_hash
|
@logging |
  accessLog:access_log /var/log/nginx/access.log combined
  errorLog:error_log /var/log/nginx/error.log warn
  logFormatCustom:log_format custom '$remote_addr - $remote_user [$time_local] \"$request\" $status $body_bytes_sent \"$http_referer\" \"$http_user_agent\" $request_time
  logFormatWhy:adds request_time for performance tracking
  perSite:access_log /var/log/nginx/mysite.access.log combined if=$loggable
  perSiteCondition:map $request_uri $loggable { default 1; /health 0; /metrics 0; }
  perSiteWhy:skip logging health checks to reduce noise
  bufferLogs:access_log /var/log/nginx/access.log combined buffer=512k flush=1m
  bufferLogsWhy:reduces disk I/O under high traffic
|
@performance |
  openFileCache:open_file_cache max=10000 inactive=20s
  openFileCacheValid:open_file_cache_valid 30s
  openFileCacheMinUse:open_file_cache_min_uses 2
  openFileCacheErrors:open_file_cache_errors on
  resetTimedOutConn:reset_timedout_connection on
  clientBodyTimeout:client_body_timeout 10
  clientHeaderTimeout:client_header_timeout 10
  sendTimeout:send_timeout 2
  keepalive:keepalive 64
  keepalive.why:connections kept alive for reuse
  keepaliveTimeout:keepalive_timeout 65
  keepaliveRequests:keepalive_requests 1000
|
@monitoring |
  stubStatus:location /nginx_status { stub_status; allow 127.0.0.1; deny all; }
  stubStatusWhy:exposes connections, requests per second
  prometheus:location /metrics { stub_status; }
  prometheusExporter:nginx-prometheus-exporter -nginx.scrape-uri=http://127.0.0.1/nginx_status
  healthCheckEndpoint:location /health { access_log off; return 200 'OK'; }
  healthCheckWhy:simple health check for load balancers
  liveReload:location /nginx_status { stub_status; }
  upstreamStatus:upstream_status shows backend health
|
@troubleshoot |
  testConfig:nginx -t
  testConfig.why:validates config before reload
  reload:nginx -s reload
  reload.why:graceful reload, no downtime
  forceReload:nginx -s stop && nginx
  forceReload.why:hard restart, drops connections
  debugLog:error_log /var/log/nginx/debug.log debug
  debugLog.why:verbose logging for debugging
  checkProcesses:ps aux | grep nginx
  checkPorts:netstat -tlnp | grep nginx
  checkErrors:tail -f /var/log/nginx/error.log
  checkAccess:tail -f /var/log/nginx/access.log
  configTest:nginx -T
  configTest.why:dump full effective config
  workerConnections:cat /proc/$(cat /var/run/nginx.pid)/limits | grep open-files
|
@commonPatterns |
  spa:location / { try_files $uri $uri/ /index.html; }
  spa.why:serve index.html for all routes, client-side routing
  apiProxy:location /api/ { proxy_pass http://backend; }
  staticFiles:location /static/ { alias /var/www/static/; expires 30d; }
  websocket:location /ws/ { proxy_pass http://backend; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; }
  redirectWWW:server { listen 80; server_name www.example.com; return 301 $scheme://example.com$request_uri; }
  redirectWWW.why:normalize to non-www
  blockBadBots:if ($http_user_agent ~* (semrush|ahrefs|mj12bot)) { return 403; }
  blockBadBots.why:block known scrapers
  maintenance:location / { if (-f /var/www/maintenance.html) { return 503; } }
  maintenanceResponse:error_page 503 @maintenance; location @maintenance { root /var/www; rewrite ^(.*)$ /maintenance.html break; }
|
@directives |
  location.match:~ (regex)
  location.match.why:case-sensitive regex match
  location.matchI:~* (case-insensitive regex)
  location.prefix:^~ (prefix match, no regex)
  location.exact:= (exact match)
  location.general:none (prefix match)
  location优先级:= > ^~ > ~* > ~ > no modifier
  location优先级.why:exact first, then prefix, then regex
  if:if (condition) { ... }
  if.why:avoid if in location blocks when possible
  if.whyNot:if is evil' - can cause unexpected behavior
  rewrite:rewrite ^/old/(.*)$ /new/$1 permanent
  rewrite.permanent:301
  rewrite.temporary:302
  return:return 301 https://example.com$request_uri
  return.why:simpler than rewrite for redirects
|
@gotchas |
  proxySlash:proxy_pass http://backend/ vs proxy_pass http://backend
  proxySlash.why:trailing slash strips location prefix
  ifInLocation:avoid if() inside location {}
  ifInLocation.why:causes unexpected behavior, use map instead
  bufferOverflow:increase proxy_buffer_size for large headers
  bufferOverflow.why:default 4k may be too small for JWT cookies
  upstreamKeepalive:upstream must use keepalive directive
  upstreamKeepalive.why:otherwise connections are not reused
  workerCPU:worker_processes auto not worker_processes 4
  workerCPU.why:auto scales with CPU cores
  includeGlob:include /etc/nginx/conf.d/*.conf
  includeGlob.why:loads all .conf files in directory
|
