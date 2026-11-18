# Webhooks Knowledge Base (provider-agnostic)
@meta |topic:webhooks http callbacks event delivery signing hmac retries idempotency|lastUpdated:2026-11-04|confidence:high|
@core |
  what:webhook = provider sends an HTTP POST to your URL when an event happens (reverse API / push callback)
  vsPoll:webhooks push in near real-time; polling pulls on a schedule (simpler, higher latency and cost)
  flow:subscribe(url+events) -> provider stores endpoint -> event fires -> signed POST -> your 2xx -> retries on failure
  actors:producer (provider), consumer (your receiver), endpoint (public HTTPS URL), signing secret (shared)
  guarantee:at-least-once, not exactly-once — assume duplicates and reordering
  contract:fast 2xx = accepted; non-2xx or timeout = retry; 410 = disable (provider-specific)
  design:verify -> dedupe -> enqueue -> 2xx -> process async
|
@envelope |
  id:unique event id (stable across retries) — use for idempotency
  type:event name (e.g. invoice.paid, push, order.created)
  createdAt:event timestamp; use for ordering and replay checks
  data:minimal payload or resource reference; fetch fresh state when it matters
  version:payload schema version for safe evolution
  signature:header carrying HMAC over raw bytes (name and canonical string vary)
  deliveryId:per-attempt id (may differ from event id) — never dedupe on this
  example:id:evt_123 type:order.created createdAt:2026-11-04T10:00:00Z data:{orderId} version:1
|
@security |
  rawFirst:verify the signature over the EXACT raw body bytes BEFORE JSON parsing
  hmac:HMAC-SHA256(secret, payload); some providers sign timestamp + "." + payload
  compare:constant-time compare (crypto.timingSafeEqual / hmac.compare_digest); never ==
  timestamp:reject if outside tolerance (e.g. 5 min) to stop replay
  replay:dedupe event id; timestamp alone is not enough
  tls:HTTPS only with a valid cert; never accept plain HTTP
  secretPerEndpoint:separate signing secret per endpoint; rotate with overlap (accept old+new)
  noTrust:do not authorize from payload alone — re-fetch the resource and check state server-side
  sizeLimit:cap body size (e.g. 1MB) before buffering to avoid memory DoS
  ssrf:on registration validate callback URL; block private, loopback, link-local ranges
  logs:never log secrets or full payloads (PII); log event id + outcome only
  ipAllowlist:provider IP ranges are defense-in-depth, not a substitute for signatures
|
@verifyPattern |
  stripe:header Stripe-Signature t=<ts>,v1=<hex>; HMAC_SHA256(secret, ts + "." + body); tolerance 300s
  github:header X-Hub-Signature-256 sha256=<hex>; HMAC_SHA256(secret, body); X-GitHub-Delivery = id
  shopify:header X-Shopify-Hmac-Sha256 <base64>; base64(HMAC_SHA256(secret, body)); X-Shopify-Webhook-Id
  slack:header X-Slack-Signature v0=<hex>; HMAC_SHA256(secret, "v0:" + ts + ":" + body); 5 min window
  twilio:header X-Twilio-Signature <base64>; HMAC_SHA1(authToken, fullUrl + sortedPostParams) (legacy SHA1)
  generic:sign timestamp + "." + body; send X-Event-Id + X-Signature + X-Timestamp headers
  algorithm:prefer SHA-256; document the exact canonical string (ordering, encoding, base64 vs hex)
|
@receiving |
  method:POST only; reject others with 405
  contentType:accept application/json (or provider-specific); still verify raw bytes
  fastAck:return 2xx within the provider timeout — target <2s; many timeout at 5-30s
  ackCodes:200/202/204 accepted; 400 bad payload; 401/403 bad signature; 5xx transient retry
  async:durably enqueue then return; do heavy work in a worker
  durable:ack only after the enqueue is persisted, else acked work can be lost
  idempotent:side effects keyed by event id; enforce with a DB unique constraint
  ordering:assume out of order; compare event timestamp/sequence and ignore stale
  stateMachine:record received -> processing -> done/failed; retry failed safely
  observability:log event id, type, duration, result; alert on failure rate
  endpointPerProvider:/webhooks/<provider> keeps secrets and parsing separate
|
@nodeExample |
  rawBody:app.post('/webhooks/stripe', express.raw({type:'application/json', limit:'1mb'}), handler)
  whyRaw:express.json() consumes the stream and changes bytes — signature will fail
  sig:const sig = req.get('stripe-signature')
  verify:const expected = crypto.createHmac('sha256', secret).update(t + '.' + req.body.toString()).digest('hex')
  compare:crypto.timingSafeEqual(Buffer.from(a,'hex'), Buffer.from(b,'hex')) after length check
  ack:await queue.add('webhook', event); res.sendStatus(200)
  note:parse JSON only after verification
|
@pythonExample |
  raw:raw = await request.body()  # FastAPI/Starlette; do not call .json() first
  verify:hmac.new(secret.encode(), raw, hashlib.sha256).hexdigest()
  compare:hmac.compare_digest(expected, received)
  ack:await queue.enqueue(payload); return Response(status_code=202)
  flask:request.get_data() (raw bytes) before request.get_json()
|
@idempotency |
  key:provider event id (stable across retries)
  store:unique index on event_id; insert conflict => already seen => return 2xx
  states:received -> processing -> done; failed retried with the same key
  window:keep dedupe records longer than the provider retry window (days)
  downstream:pass an idempotency key to payments/email APIs too
  sideEffects:make create/charge/send idempotent, not just the HTTP handler
  concurrency:use a DB unique constraint or atomic SETNX to beat parallel duplicates
  avoid:per-delivery id or payload hash as the only key (misses and collisions)
|
@retries |
  trigger:consumer returns non-2xx, times out, or connection fails
  policy:exponential backoff with jitter (e.g. 1m,5m,30m,2h,...) over 24-72h
  noRetry:most 4xx are permanent — disable endpoint on repeated 4xx or 410
  rateLimit:honor 429 + Retry-After; pause then resume
  ordering:retries can arrive after newer events — process idempotently
  deadLetter:after max attempts move to a DLQ; alert and provide replay tooling
  storm:queue + backoff prevents a thundering herd after an outage
  producerSide:if you send webhooks, apply the same rules — durable queue, signed, observable
|
@testing |
  tunnel:ngrok http 3000 or cloudflared tunnel --url http://localhost:3000
  providerCli:stripe listen --forward-to localhost:3000/webhooks/stripe; gh webhook forward; svix
  replay:save real payloads as fixtures; replay to test handlers deterministically
  cases:valid sig, bad sig, replayed id, duplicate delivery, out-of-order, slow handler, 5xx
  clock:test timestamp tolerance with deliberately skewed timestamps
  secrets:use test-mode secrets; never prod secrets locally
  contract:assert response code and async side effect, not just a 200
  load:burst test to confirm the queue absorbs spikes
|
@gotchas |
  parsedBeforeVerify:JSON middleware runs before signature check -> always fails
  reserialize:re-serializing JSON changes whitespace/order -> different HMAC
  exactlyOnce:not guaranteed; duplicates WILL happen on retries
  slowHandler:work before 2xx causes timeout -> provider retries -> duplicate processing
  missingDedupe:no unique event id => double charges/emails
  timestampSkew:server clock drift breaks replay-window checks
  bodyLimit:unbounded body buffering => memory DoS
  trustPayload:acting on payload for money/state => stale or forged data; re-fetch
  secretLeak:secret in client bundle, URL, or logs
  rotationDowntime:single-secret swap drops in-flight retries; accept old+new during overlap
  tunnelChurn:local tunnel URL changes; re-register or use a stable dev domain
  proxyIp:allowlisting behind a proxy needs X-Forwarded-For + trusted proxy config
  compression:gzip/transfer-encoding can alter raw bytes; verify post-decompress consistently
  noMonitoring:silent delivery failures go unnoticed without DLQ + alerts
  retryOrdering:a retried old event can overwrite newer state (last-write-wins bug)
|
@checklist |
  https:public HTTPS endpoint with valid cert
  verify:HMAC over raw body + constant-time compare
  replay:timestamp tolerance + event-id dedupe
  idempotent:unique event id + idempotent side effects
  fast:2xx after durable enqueue; heavy work async
  retries:backoff+jitter, 429 handling, DLQ + alerts
  limits:body size cap, rate limiting, timeouts
  secrets:per-endpoint secret + rotation plan
  logging:event id + outcome; no secrets/PII
  tests:valid/invalid/replay/duplicate/timeout/burst
  monitor:delivery failures, latency, queue depth
|
@run receiveEndpoint |
  1.cmd:register POST /webhooks/<provider>; disable the global body parser for this route
  1.note:raw bytes are required for signature verification
  2.cmd:read raw body with a size cap (1MB) and a request timeout
  2.onFail:reject oversized/slow bodies with 413/408
  3.cmd:verify HMAC signature (constant-time) + timestamp tolerance
  3.onFail:return 401 and do not process
  4.cmd:dedupe by event id (unique insert); if it exists return 200
  4.onFail:on a race, rely on the DB unique constraint and return 200
  5.cmd:enqueue the verified event durably
  5.onFail:return 5xx so the provider retries
  6.cmd:return 202/200 immediately
  6.note:ack only after the enqueue is persisted
  7.cmd:worker processes idempotently; mark done/failed
  7.onFail:retry safely with the same event id; after max move to DLQ + alert
  8.cmd:monitor failures/latency/queue depth; provide replay from the DLQ
|
@run verifySignature |
  1.cmd:extract raw body bytes exactly as received
  2.cmd:read the signature header (provider-specific name) + timestamp header
  2.onFail:missing header -> 400/401
  3.cmd:check timestamp within tolerance (e.g. 5 min) to block replay
  3.onFail:stale -> 401
  4.cmd:recompute HMAC-SHA256 over the provider's canonical string with the endpoint secret
  5.cmd:constant-time compare expected vs received (length check first)
  5.onFail:mismatch -> 401, log event id only
  6.cmd:only then parse JSON and process
|
@run producerSetup |
  1.cmd:define envelope: id, type, created_at, data, version
  2.cmd:sign payload (timestamp + body) with a per-endpoint secret; expose a signature header
  3.cmd:deliver with a short timeout (5-10s) and record a delivery id
  4.cmd:treat 2xx as success; 4xx as permanent (except 429)
  4.onFail:log the failure reason; disable endpoint after repeated 4xx/410
  5.cmd:retry 5xx/timeouts with exponential backoff + jitter
  5.note:cap the total retry window (24-72h) then dead-letter
  6.cmd:expose delivery logs, manual replay, and endpoint health
  7.cmd:alert on delivery failure rate and DLQ growth
|
@run testWebhook |
  1.cmd:start the local receiver and a tunnel (ngrok/cloudflared)
  2.cmd:register the tunnel URL with a test secret
  3.cmd:trigger a real event (or a provider CLI such as stripe listen)
  4.cmd:assert the signature verifies and the side effect happens once
  5.cmd:replay the same event id -> assert dedupe (no second side effect)
  6.cmd:send a bad signature -> assert 401 and no processing
  7.cmd:simulate 500/timeout -> observe provider retry/backoff
  8.cmd:burst several events -> assert the queue absorbs them and order-independence holds
|
@index |
  core:@core @envelope
  security:@security @verifyPattern
  consumer:@receiving @idempotency @retries @nodeExample @pythonExample
  quality:@testing @checklist @gotchas
  producer:@producerSetup @run
  lookup:dots get skills/webhooks.s @blockName
|
