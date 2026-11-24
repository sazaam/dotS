# Archify - interactive diagram authoring (dotS layer)
@meta |
  topic:archify interactive architecture workflow sequence dataflow lifecycle diagrams
  versions:2.17 frontmatter, 2.17.0-dev.1 release
  confidence:high
  lastUpdated:2026-11-24
  source:opencode skill archify SKILL.md
  package:$HOME/.config/opencode/skills/archify
  binary:node bin/archify.mjs from package dir
  scope:fast path only; deep contracts live in package references
|
@core |
  purpose:produce one self-contained explorable HTML diagram with inline SVG from typed JSON
  default:static output; motion and trace only when user asks for demo or presentation
  path:bounded authoring path for ordinary generation; do not read viewer-runtime docs unless asked
  deepRead:references/authoring-contract.md only for field enums spacing math geometry repair repo evidence or mode placement
  deliveryRead:references/delivery-contract.md for receipts preview repo evidence export receipts manual review
  avoid:renderers/shared/geometry.mjs renderer source validator source tests benchmarks before first candidate
|
@types |
  architecture:components services cloud security boundaries infrastructure
  workflow:processes approval gates tool calls runbooks ci cd
  sequence:api call chains request lifecycles async traces returns
  dataflow:pipelines etl elt lineage governance consumers
  lifecycle:state status transitions retries waiting terminal states
  ambiguous:node bin/archify.mjs guide "scenario" --json
|
@author |
  step1:choose type then read matching schemas/<type>.schema.json plus schemas/common.schema.json plus one matching examples/<type>.json - only those files
  fresh:new stable IDs domain wording layout; example gives field shape not facts
  workflowVersion:schema_version 2 for new workflows; v1 only to preserve fixed legacy geometry
  step2:artifact first - next tool action writes candidate before inspecting renderer internals
  shape:one main path short side branches sparse labels at most 12 primary nodes
  quality:meta.quality_profile "showcase" unless user explicitly asks for dense standard
  routes:start automatic routes and labels; no via channelX channelY labelAt before a diagnostic calls for one
  geometryRepair:at most one diagnosed geometry control per repair
  brands:node bin/archify.mjs brands "<name>" --json when real product identity matters; capture URL only with official user-provided HTTP(S) URL
|
@validate |
  cmd:node bin/archify.mjs validate <type> candidate.json --quality showcase --json
  timing:after every candidate edit and immediately before handoff
  basic:A receipt with only 4 artifact checks is basic validation never showcase acceptance
  showcase:all 9 artifact checks with 0 composition errors and 0 warnings
  field:fix missing or misspelled meta.quality_profile before geometry
  workflowLayout:node bin/archify.mjs validate workflow candidate.json --layout-json - use stable compiler receipt not solver internals
  freeze:a passing final validation freezes the candidate; never edit it afterward
  repair:change only diagnosed subject verify evidence choose from supportedFixes rerun; stop if two consecutive rounds do not improve best error count
|
@deliver |
  cmd:node bin/archify.mjs deliver <type> candidate.json out.html --quality showcase --json
  rule:deliver is final acceptance for delivered HTML; non-zero exit is never success
  safety:failed delivery preserves previous output - do not visual-check a failed path; it inspects stale last-good artifact
  proof:snapshot exact specification bytes check then atomically commit HTML; reports SHA-256 plus byte counts for spec and artifact
  visual:node bin/archify.mjs visual-check out.html --json - bounded browser evidence from exact delivered HTML without rerendering
  claims:deliver proves deterministic artifact checks; visual-check proves bounded browser behavior; perceptual polish needs human or image-capable reviewer
  open:add --open only when user wants immediate local preview
  previewCmd:node bin/archify.mjs preview <type> in.json out.html --quality showcase - never start by default
  output:return checked HTML path type validation summary spec artifact receipt browser evidence status truthful visual review status
|
@mermaid |
  flowchart:flowchart or graph maps to workflow, or architecture for component map
  sequence:sequenceDiagram maps to sequence; participants become semantic participants arrows become messages
  state:stateDiagram maps to lifecycle; retain state and transition meaning not Mermaid style
  rule:read topology and meaning then author fresh Archify JSON; never mechanically render Mermaid styling
|
@invariants |
  mainPath:one obvious main path; side branches leave nearest main-path node; remove low-value edges before routing controls
  preset:omit meta.visual_preset by default so viewer opens in classic; color mode and preset are independent
  subtitle:omit meta.subtitle by default; add short supporting line only when explicitly asked
  desktop:first-screen artifact; responsive one HTML for laptops and external displays; never device-specific HTML or alternate topology
  containment:before handoff open at 1440x900 1600x1000 1920x1080 and 2048x1320 for large displays; require scrollWidth <= innerWidth and scrollHeight <= innerHeight
  overflowFix:remove genuinely redundant content or compact spacing first; never overflow hidden clipping internal scroller stretched SVG or smaller type
  legend:omit meta.legend for truthful auto default; use only mode auto all hidden and renderer-supported entries
  locale:en or zh-CN for supported viewer UI; other languages omit meta.locale and disclose English fallback; renderer never translates authored content
  names:preserve exact product names code identifiers commands protocols API paths environment names
  brands:brand identity optional explicit; built-in ID when node names real product; no preset plus official URL means brands capture then digest-pinned brand object
  sequenceLayout:omit meta.column_fit for fixed; use spread for wide viewBox or meaningful labels that do not fit; do not shorten semantic labels first
  types:frontend backend database cloud security messagebus external; variants default emphasis security dashed
  labels:relationship labels are semantic data; move label adjust route spacing then shorten while preserving meaning; omit only fully implied wording with no protocol action direction sync async or cross-boundary mechanism
  spacing:clear gap not center distance; relationship label clear gap must exceed measured mask width
  ports:automatic routes own endpoint sides; first and final segment perpendicular to that side
  portSpread:default for architecture workflow dataflow lifecycle; skips single edges and explicit via channelX channelY labelAt or non-auto routes
  crossings:never accept edge crossing unrelated opaque node ambiguous shared corridor or label masking another route
  engineering:omit meta.engineering_profile by default; deployment-ownership only on explicit production topology ownership handoff or fail-closed review with known facts
  lifecycle:phase columns 0..4 on main rail; event terminal column N in 0..2 aligns under main column N+2; recoverable state uses type failure plus real transition back
|
@update |
  cmd:node scripts/check-update.mjs once after first candidate exists
  silent:continue without mentioning
  available:show one compact notice with installed latest fixed local summary and official release-notes link; mark security updates clearly
  autonomy:installed Skill unchanged; user decides whether and when to update; never quote summarize or translate remote manifest summary
  ack:after notice visible rerun checker with --ack "<eventKey>" then continue original task
|
@setup |
  doctor:node bin/archify.mjs doctor
  demo:node bin/archify.mjs demo <output-directory>
  fallback:no shell access - hand-place architecture SVG into assets/template.html use CSS semantic classes and follow visual review contract
|
@gotchas |
  noInstall:no install required inside skill package
  fourChecks:4 artifact checks means basic not showcase
  qualityField:misspelled meta.quality_profile causes geometry work before the real fix
  staleVisual:visual-check after failed deliver inspects previous output
  freeze:editing after passing validation invalidates the pass
  coordinatePlanning:do not plan exact coordinates in prose before candidate exists
  labelsNotFiller:deleting a meaningful relationship label to fix geometry is wrong
  presetIndependence:switching Light Dark must preserve current preset
  brandInference:never infer brand from vague role such as database
  pinnedCapture:render and validate never perform unpinned brand capture
  scenarioProof:scenario proof examples are structural references not facts to copy
|
@run.diagram |
  0.cmd:cd "$HOME/.config/opencode/skills/archify" && node bin/archify.mjs guide "<scenario>" --json
  0.note:skip when type is already obvious
  1.cmd:cd "$HOME/.config/opencode/skills/archify" && node bin/archify.mjs validate <type> candidate.json --quality showcase --json
  1.onFail:fix meta.quality_profile or diagnosed subject then rerun; one geometry control per repair
  2.cmd:cd "$HOME/.config/opencode/skills/archify" && node scripts/check-update.mjs
  2.note:run once after first candidate; handle notice and --ack before continuing
  3.cmd:cd "$HOME/.config/opencode/skills/archify" && node bin/archify.mjs deliver <type> candidate.json out.html --quality showcase --json
  3.onFail:non-zero is failure; do not visual-check and do not describe as success
  4.cmd:cd "$HOME/.config/opencode/skills/archify" && node bin/archify.mjs visual-check out.html --json
  4.note:report browser evidence separately from perceptual review
|
@run.doctor |
  1.cmd:cd "$HOME/.config/opencode/skills/archify" && node bin/archify.mjs doctor
  2.cmd:cd "$HOME/.config/opencode/skills/archify" && node bin/archify.mjs demo /tmp/archify-demo
  2.note:confirms render pipeline works without reading renderer internals
|
@index |
  core:@core @types
  authoring:@author @invariants
  validation:@validate @gotchas
  delivery:@deliver @update
  input:@mermaid @setup
  playbook:@run.diagram @run.doctor
|
