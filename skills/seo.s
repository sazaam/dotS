@meta |topic:seo search-engine-optimization crawling ranking audit review|versions:1|confidence:verified|lastUpdated:2026-11-24|
@dependencies |
  requires:html.s
|
@core |
  purpose:SEO audit and review for crawlability indexing relevance authority and AI citation surfaces
  usage:load for web launches content reviews and ranking audits; run @run.audit from project root
  honesty:no guaranteed top ranking; optimize controllable signals and measure outcomes
  scope:on-page technical content off-page measurement; defer tag syntax to html.s @seo @metadata @structuredData
|
@crawling |
  discover:homepage sitemap and internal links are the three entry points
  robots:allow important paths; disallow private duplicate and parameter traps
  sitemap:absolute canonical URLs with real lastmod; exclude noindex and redirected URLs
  status:200 indexable 301 moved 404/410 gone; never soft-404
  depth:important pages within 3 clicks of home
  orphans:zero internal inbound links means likely not indexed
  render:primary text links and metadata visible in server HTML or prerendered output
  logs:watch crawler hits 404 spikes and crawl waste
  params:faceted filtered and tracking params need canonical or noindex rules
|
@indexing |
  canonical:self-referencing absolute URL one per page
  duplicates:canonical or consolidate near-identical pages
  thin:merge expand or noindex low-value tag and archive pages
  robotsMeta:noindex and nofollow only when intentional
  hreflang:reciprocal locale pairs x-default and locale-specific canonicals
  pagination:self-canonical every page; do not point all pages at page 1
  redirects:single hop no chains no loops
  gaGate:noindex staging preview cart and thin search results
|
@relevance |
  intent:match informational navigational commercial or transactional intent
  title:primary keyword early unique 50-60 chars
  description:unique 150-160 char summary; CTR signal not direct ranking factor
  headings:one h1 then logical h2-h6 outline
  semantic:cover entity attributes use cases comparisons and follow-up questions
  freshness:update dates only when content materially changes
  language:correct html lang and locale-specific wording
  natural:answer plainly; avoid keyword stuffing and exact-match fixation
|
@content |
  helpful:original first-hand value beyond what competitors already say
  eeat:experience expertise authoritativeness trust
  author:byline credentials sources and about page
  depth:answer fully then add examples proof and edge cases
  media:descriptive alt captions dimensions and accessible transcripts
  links:descriptive internal anchors to related pages
  evidence:cite primary sources and show methodology for claims
  intentFit:format matches query: guide comparison product or reference
|
@technical |
  https:everywhere with no mixed content
  mobile:responsive viewport tap targets and no horizontal scroll
  cwv:LCP INP CLS; fix largest paint input delays and layout shifts
  images:modern formats responsive sizes lazy below-fold eager hero
  js:server-render or prerender primary content and links
  speed:cache compress minify and use a CDN where useful
  errors:no 5xx no blocked CSS/JS no render-blocking waste
  urls:short readable lowercase hyphenated and stable
|
@structuredData |
  format:JSON-LD application/ld+json
  types:Organization WebSite Article Product BreadcrumbList FAQPage HowTo Person
  required:context type name url and stable @id where possible
  match:markup must describe visible page content
  validate:Rich Results Test and Schema Markup Validator
  breadcrumbs:mirror visible hierarchy
  noAbuse:no fake reviews ratings prices or hidden content
  richResults:eligibility is not a ranking boost by itself
|
@aiReferencing |
  answerFirst:lead with a concise self-contained answer
  entities:name people products and concepts with explicit types and attributes
  provenance:author date sources and update history
  quotable:short sections that survive extraction without page context
  consistency:same canonical facts across site profiles and structured data
  accessible:crawlable HTML text beats images-only or JS-only content
  compare:tables and explicit comparisons are easy to cite
  noGuarantee:AI citations follow discoverability and clarity not a magic tag
|
@authority |
  links:earn relevant editorial links from trusted sites
  pr:original research tools data and expert commentary
  mentions:turn unlinked brand mentions into attribution requests
  local:consistent name address phone and citations
  disavow:only for manual action or clear spam evidence
  noSchemes:avoid bought exchanged or private blog network links
  brand:direct and unbranded demand supports trust signals
|
@measurement |
  gsc:index coverage queries pages Core Web Vitals and crawl stats
  logs:status codes bot frequency and crawl waste
  analytics:landing pages engagement and conversions
  rank:track query clusters not isolated keywords
  ctr:title and description tests change clicks not rankings directly
  baseline:record before changes and review after 2-6 weeks
  attribution:correlate do not assume; algorithms and SERP features change
|
@audit |
  order:crawl index content technical authority measurement
  p0:blocked crawl noindex canonical mistakes status codes sitemap renderability
  p1:intent titles descriptions headings thin content internal links CWV
  p2:structured data metadata freshness duplicate titles image polish
  output:URL issue severity evidence fix owner priority
  gate:no P0 before launch
  manual:verify with Search Console server logs and Rich Results Test
  cadence:quick check per release full audit quarterly
|
@review |
  intent:which query and stage does this page serve
  discover:is it linked sitemapped robots-allowed and renderable
  index:does canonical match and is noindex absent unless intentional
  answer:is the main answer visible in the first screen of HTML
  unique:are title description and body distinct from sibling pages
  proof:are author sources dates and methodology present
  internal:are 3+ contextual related links included
  schema:is markup valid and mirrored by visible content
  next:one measurable change owner and review date
|
@gotchas |
  fakeFreshness:changing dates without real updates erodes trust
  faqAbuse:FAQ markup must reflect visible questions and answers
  canonicalConflict:sitemap canonical hreflang and redirects must agree
  jsOnly:crawlers may not execute heavy client-side rendering
  noGuarantee:top ranking depends on competition and intent not checklists
  overAudit:fix P0 first; perfect P2 work rarely moves revenue
  mixedIntent:one page cannot target every stage equally well
  staleSitemap:lastmod that never changes is ignored
|
@run audit |
  1.note:read-only local checks; run from project root; no network calls
  2.cmd:find . -type f -name '*.html' -not -path './node_modules/*' | wc -l
  2.note:HTML page count
  3.cmd:grep -rL '<title' --include='*.html' --exclude-dir=node_modules . || true
  3.note:pages missing title
  4.cmd:grep -rL 'name="description"' --include='*.html' --exclude-dir=node_modules . || true
  4.note:pages missing meta description
  5.cmd:grep -rL 'rel="canonical"' --include='*.html' --exclude-dir=node_modules . || true
  5.note:pages missing canonical; review intentional noindex
  6.cmd:grep -rL '<h1' --include='*.html' --exclude-dir=node_modules . || true
  6.note:pages missing h1
  7.cmd:grep -rL 'alt=' --include='*.html' --exclude-dir=node_modules . || true
  7.note:pages with no alt text at all
  8.cmd:test -f robots.txt && echo 'robots.txt: ok' || echo 'robots.txt: MISSING'
  8.note:robots.txt presence
  9.cmd:test -f sitemap.xml && echo 'sitemap.xml: ok' || echo 'sitemap.xml: MISSING'
  9.note:sitemap presence
  10.cmd:grep -rE 'noindex|nofollow' --include='*.html' --exclude-dir=node_modules . || true
  10.note:review intentional noindex and nofollow
  11.cmd:grep -rE 'href="http://' --include='*.html' --exclude-dir=node_modules . || true
  11.note:review insecure internal links
  12.cmd:grep -rL 'application/ld+json' --include='*.html' --exclude-dir=node_modules . || true
  12.note:pages without structured data; not always required
  13.note:finish with @audit @review and live Search Console log checks
|
@run review |
  1.note:intent: query stage and target page
  2.note:crawl: linked sitemapped robots-allowed renderable
  3.note:index: canonical self-referencing noindex absent
  4.note:answer: primary answer in visible HTML
  5.note:content: unique proof sources author dates
  6.note:links: 3+ contextual internal links
  7.note:technical: HTTPS mobile CWV images JS
  8.note:schema: valid markup matching visible content
  9.note:next: one change owner review date
|
@index |
  sections:@core @crawling @indexing @relevance @content @technical @structuredData @aiReferencing @authority @measurement @audit @review @gotchas
  playbook:@run.audit @run.review
  format:compact key:value .s block format
|
