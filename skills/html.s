# HTML Knowledge Base
@meta |topic:html|versions:HTML4-HTML5|lastUpdated:2026-08-18|confidence:high|
@structure |
  doctype:<!DOCTYPE html>
  html:<html lang="en">
  head:<head>, <meta>, <title>, <link>, <script>
  body:<body>, visible content
  closing:most elements need closing tags
  selfClosing:img, br, hr, input, meta, link
|
@semantic |
  header:page/section header
  nav:navigation
  main:main content (one per page)
  article:standalone content
  section:thematic grouping
  aside:sidebar/tangential content
  footer:page/section footer
  figure:<figure>, <figcaption>
  details:<details>, <summary>
  mark:<mark> highlighted text
  time:<time datetime="2026-08-18">
  abbr:<abbr title=" abbreviation">
  address:<address> contact info
  hgroup:<hgroup> heading + subtitle
|
@forms |
  inputTypes:text, password, email, number, tel, url, search, date, time, checkbox, radio, file, hidden, range, color
  inputAttrs:required, placeholder, pattern, min, max, step, disabled, readonly, autofocus, autocomplete
  validation:checkValidity(), reportValidity(), setCustomValidity()
  validationMsg:input.validationMessage
  noValidate:<form novalidate>
  label:<label for="id"> (click focuses input)
  fieldset:<fieldset>, <legend>
  output:<output>
  progress:<progress value="50" max="100">
  meter:<meter low="25" high="75" optimum="50">
|
@accessibility |
  role:role="button", role="dialog", role="alert"
  ariaLabel:aria-label="Close menu"
  ariaHidden:aria-hidden="true" (screen reader ignore)
  ariaExpanded:aria-expanded="true/false"
  ariaLive:aria-live="polite|assertive" (dynamic content)
  tabindex:tabindex="0" (focusable), "-1" (programmatic only)
  skipLink:<a href="#main" class="skip">Skip to content</a>
  alt:alt="" for decorative, descriptive for meaningful
  headingOrder:h1 > h2 > h3 (don't skip levels)
  landmark:use semantic elements over role attributes
|
@media |
  picture:<picture>, <source srcset="..." media="...">
  srcset:img srcset="small.jpg 480w, large.jpg 1024w"
  sizes:sizes="(max-width: 600px) 480px, 1024px"
  loading:loading="lazy" (native lazy loading)
  fetchPriority:fetchpriority="high|low"
  decoding:decoding="async"
|
@tables |
  structure:<table>, <thead>, <tbody>, <tfoot>, <tr>, <th>, <td>
  caption:<caption>
  scope:scope="col|row"
  headers:headers="id" (complex tables)
  layout:don't use for layout, use CSS grid/flex
|
@scripting |
  defer:defer (execute after parse, before DOMContentLoaded)
  async:async (execute when downloaded, blocks parser)
  module:type="module" (ES modules, deferred by default)
  nomodule:nomodule (fallback for old browsers)
  preload:<link rel="preload">
  prefetch:<link rel="prefetch">
  dnsPrefetch:<link rel="dns-prefetch">
|
@gotchas |
  divSpan:don't use div/span for everything, use semantic elements
  alt:always add alt to img (empty for decorative)
  label:always associate label with input (for="id" or wrapping)
  headingOrder:don't skip heading levels (h1 > h3)
  autoplay:avoid autoplay video/audio (user hostile)
  targetBlank:rel="noopener noreferrer" with target="_blank"
  encoding:<meta charset="utf-8"> must be first in head
  viewport:<meta name="viewport" content="width=device-width, initial-scale=1">
  inlineStyles:avoid style="" attribute, use CSS files
  inlineScripts:avoid script tags in body, use external files
  deprecated:center, font, big, strike, frame, frameset
  booleanAttrs:checked, disabled, readonly (no value needed)
  voidElements:don't close void elements: <br>, not <br></br>
|
@metadata |
  openGraph:og:title, og:description, og:image, og:url
  twitter:twitter:card, twitter:title, twitter:description
  canonical:<link rel="canonical" href="...">
  favicon:<link rel="icon" href="favicon.ico">
  manifest:<link rel="manifest" href="manifest.json">
  themeColor:<meta name="theme-color" content="#ffffff">
|
@html5Features |
  canvas:<canvas width="800" height="600">
  audio:<audio controls src="sound.mp3">
  video:<video controls width="640" src="video.mp4">
  source:<source src="video.webm" type="video/webm">
  track:<track src="subs.vtt" kind="subtitles">
  svg:<svg viewBox="0 0 100 100">
  math:<math> (MathML)
  draggable:draggable="true"
  contentEditable:contenteditable="true"
  hidden:hidden (boolean attribute)
  dialog:<dialog open>, dialog.showModal(), dialog.close()
|
@seo |
  title:title tag (50-60 chars, unique per page)
  description:meta description (150-160 chars, unique per page)
  canonical:<link rel="canonical"> (prevent duplicate content)
  hreflang:<link rel="alternate" hreflang="en" href="..."> (multi-language)
  robots:meta robots: index, follow, noindex, nofollow
  robotsTxt:User-agent: *, Allow: /, Disallow: /admin/
  sitemap:sitemap.xml (list all pages, lastmod, changefreq)
  lazyImages:loading="lazy" (below-fold images only)
  eagerImages:loading="eager" fetchpriority="high" (above-fold)
  imageAlt:descriptive alt text (not keyword-stuffed)
  imageDimensions:always set width/height (prevent CLS)
  headingHierarchy:one h1 per page, logical h2-h6 structure
  internalLinks:descriptive anchor text, contextual linking
  canonicalSelf:canonical must match current URL exactly
  noIndexThin:noindex pages with thin/duplicate content
|
@structuredData |
  jsonLd:<script type="application/ld+json">
  schemaOrg:schema.org vocabulary
  types:Article, Product, Organization, Person, BreadcrumbList, FAQ, HowTo
  required:name, @type, @context
  nested:nest properties, don't flatten
  testing:validate at search.google.com/test/rich-results
  BreadcrumbList:@type BreadcrumbList, itemListElement array
  Article:@type Article, headline, author, datePublished, image
  Product:@type Product, name, description, image, offers
  Organization:@type Organization, name, logo, url
|
@openGraph |
  required:og:title, og:description, og:image, og:url
  type:og:type (website, article, product)
  imageSize:1200x630 (recommended)
  imageAlt:og:image:alt (accessibility + SEO)
  siteName:og:site_name
  locale:og:locale (en_US)
  twitterCard:twitter:card (summary, summary_large_image)
  twitterSite:twitter:site (@username)
  twitterCreator:twitter:creator (@author)
|
@performance |
  preconnect:<link rel="preconnect" href="https://fonts.googleapis.com">
  preload:<link rel="preload" href="font.woff2" as="font">
  prefetch:<link rel="prefetch"> (low priority)
  defer:defer scripts (don't block parsing)
  async:async scripts (execute when ready)
  fontDisplay:font-display: swap (avoid invisible text)
  criticalCss:inline above-fold CSS
  lazyLoad:loading="lazy" for images/iframes
|
@seoGotchas |
  duplicateContent:use canonical or noindex
  thinContent:expand or noindex low-value pages
  cloaking:don't show different content to crawlers
  linkSchemes:don't buy/exchange links
  keywordStuffing:write naturally, not for bots
  missingAlt:add alt to all images
  brokenLinks:check for 404s regularly
  mobileFirst:responsive design required
  coreWebVitals:LCP, FID, CLS affect ranking
  structuredDataErrors:validate before deploying
|
@run validate |
  1.cmd:npx htmlhint **/*.html
  1.note:run HTML linter
  2.cmd:npx html-validate **/*.html
  2.note:run W3C HTML validator
  3.note:check for: missing alt, unclosed tags, deprecated elements
|
@run lint |
  1.cmd:npx htmlhint **/*.html --config .htmlhintrc
  1.note:lint with project config
  2.note:common rules: tag-pair, attr-value-double-quotes, id-unique
|
@run accessibility |
  1.cmd:npx pa11y **/*.html
  1.note:check WCAG compliance
  2.cmd:npx axe **/*.html
  2.note:accessibility audit with axe-core
  3.note:check: heading order, label association, color contrast, ARIA
|
@run seoCheck |
  1.cmd:grep -r "<title>" **/*.html
  1.note:verify all pages have title tags
  2.cmd:grep -r 'meta name="description"' **/*.html
  2.note:verify all pages have meta descriptions
  3.cmd:grep -r 'rel="canonical"' **/*.html
  3.note:verify canonical tags present
  4.cmd:grep -r 'application/ld+json' **/*.html
  4.note:check for structured data
|
