# CSS Knowledge Base
@meta |topic:css|versions:CSS2-CSS3-Modern|lastUpdated:2026-08-18|confidence:high|
@selectors |
  universal:*
  element:div
  class:.classname
  id:#id
  attribute:[href]
  attributeExact:[type="text"]
  attributeContains:[class*="btn"]
  attributeStarts:[href^="https"]
  attributeEnds:[href$=".pdf"]
  attributeSpace:[class~="active"]
  child:>
  descendant:(space)
  sibling:~
  adjacent:+
  pseudo:hover, :focus, :active
  pseudoFirst:first-child
  pseudoLast:last-child
  pseudoNth:nth-child(2n)
  pseudoNthOfType:nth-of-type(1)
  pseudoNot:not(.class)
  pseudoBefore::before
  pseudoAfter::after
  pseudoPlaceholder::placeholder
  pseudoSelection::selection
  pseudoFocus-visible:focus-visible
|
@boxModel |
  contentBox:default, width/height = content only
  borderBox:*, width/height = content + padding + border
  marginCollapse:vertical margins collapse (top+bottom)
  marginCollapseFix:use padding or BFC
  padding:padding: top right bottom left
  margin:auto:center horizontally
  marginNeg:negative margin pulls element
|
@flexbox |
  display:flex
  direction:row | row-reverse | column | column-reverse
  wrap:nowrap | wrap | wrap-reverse
  justify:flex-start | flex-end | center | space-between | space-around | space-evenly
  align:flex-start | flex-end | center | stretch | baseline
  alignItems:cross-axis alignment
  gap:gap: 10px 20px (row column)
  flexGrow:1 (take remaining space)
  flexShrink:0 (don't shrink)
  flexBasis:auto | 0 | specific size
  flex:1 1 0 (grow shrink basis)
  order:-1 (before), 0 (default), 1 (after)
|
@grid |
  display:grid
  template:grid-template-columns: 1fr 2fr 1fr
  templateRepeat:grid-template-columns: repeat(3, 1fr)
  templateAuto:grid-template-columns: repeat(auto-fill, minmax(200px, 1fr))
  gap:gap: 10px 20px
  span:grid-column: span 2
  start:grid-column-start: 1
  end:grid-column-end: 3
  area:grid-template-areas: "header header" "nav main"
  areaName:grid-area: header
|
@position |
  static:default, no positioning
  relative:position relative to normal flow
  absolute:position relative to nearest positioned ancestor
  fixed:position relative to viewport
  sticky:position relative until threshold, then fixed
  top/top/right/bottom/left:offset from containing element
  zIndex:z-index works only on positioned elements (not static)
  stacking:stacking context: z-index, opacity<1, transform, filter
|
@units |
  px:1px = 1 device pixel (usually)
  em:relative to parent font-size
  rem:relative to root font-size
  vw:1% of viewport width
  vh:1% of viewport height
  vmin:1% of smaller viewport dimension
  vmax:1% of larger viewport dimension
  percent:relative to parent
  auto:browser calculates
  fr:grid fractional unit
  ch:width of "0" character
  ex:x-height of font
|
@media |
  width:max-width: 768px (mobile first: min-width)
  height:max-height: 500px
  orientation:orientation: landscape
  hover:hover: hover (pointer capable)
  prefersColorScheme:prefers-color-scheme: dark
  prefersReducedMotion:prefers-reduced-motion: reduce
  print:@media print
  feature:@media (feature: value)
|
@specificity |
  calculation:(0, 0, 0) for inline, IDs, classes/attrs/pseudo-classes, elements/pseudo-elements
  inheritance:inherited properties pass to children
  inherit:force inherit: property: inherit
  initial:reset to default: property: initial
  unset:remove: property: unset
  revert:revert to stylesheet: property: revert
|
@gotchas |
  marginCollapse:vertical margins collapse, horizontal don't
  marginCollapseFix:use padding, BFC, or gap
  zIndexFix:position: relative on parent
  flexGap:flex-gap creates BFC, breaks margin collapse
  gridAutoFlow:dense packing can reorder items
  positionFixed:fixed breaks in transform/filter/parent overflow
  positionSticky:sticky needs overflow to work
  overflow:overflow: hidden clips, not hides
  boxSizing:border-box recommended: *, *::before, *::after
  specificity:fight specificity, don't add !important
  specificityFix:use classes over IDs, combine selectors
  units:em compounds, rem doesn't
  unitsFix:use rem for font-size, em for padding/margin
  vh:100vh includes scrollbar, use dvh
  darkMode:prefers-color-scheme, not class toggle
|
@modern |
  containerQueries:@container (inline-size > 300px) { ... }
  has:has(.child) (parent selector)
  nesting:.parent { .child { } } (native nesting)
  colorMix:color-mix(in srgb, red 50%, blue 50%)
  oklch:oklch(70% 0.15 180) (perceptual color)
  relativeColor:oklch(from var(--base) l c h / 0.5)
  subgrid:grid-template-columns: subgrid
  scrollSnap:scroll-snap-type: x mandatory
  aspectRatio:aspect-ratio: 16/9
  clamp:width: clamp(300px, 50%, 800px)
  minMax:width: min(100%, 500px)
  gap:gap in flexbox (no more margin hacks)
|
@run lint |
  1.cmd:npx stylelint **/*.css
  1.note:run CSS linter
  2.cmd:npx stylelint **/*.css --config .stylelintrc
  2.note:lint with project config
  3.note:common rules: no-duplicate-selectors, no-empty-blocks, color-hex-length
|
@run validate |
  1.cmd:npx stylelint **/*.css --config .stylelintrc
  1.note:validate CSS syntax
  2.note:check for: unknown properties, invalid values, deprecated features
|
@run specificity |
  1.cmd:npx specificity **/*.css
  1.note:analyze selector specificity
  2.note:flag: IDs, inline styles, !important, deep nesting
  3.note:target: all selectors under (0, 1, 0) specificity
|
@run audit |
  1.cmd:npx stylelint **/*.css --config .stylelintrc --formatter verbose
  1.note:full CSS audit
  2.note:check: unused variables, color consistency, unit consistency
  3.note:check: responsive breakpoints, z-index stacking
|
