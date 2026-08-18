@p |
  name:dotS
  ver:0.1.0
|

@quickRef |
  ponytail:s get skills/ponytail.s @rules
  ponytailReview:s get skills/ponytail.s @run.review
  css:s get skills/css.s
  html:s get skills/html.s
  threejs:s get skills/threejs.s
  glsl:s get skills/glsl.s
  md:s get skills/md.s
  jade:s get skills/jade.s
  obsidian:s get skills/md.s @obsidian
  shaderToy:s get skills/glsl.s @shadertoylite
  htmlValidate:s get skills/html.s @run.validate
  htmlLint:s get skills/html.s @run.lint
  a11y:s get skills/html.s @run.accessibility
  seoCheck:s get skills/html.s @run.seoCheck
  cssLint:s get skills/css.s @run.lint
  cssValidate:s get skills/css.s @run.validate
  cssSpecificity:s get skills/css.s @run.specificity
  cssAudit:s get skills/css.s @run.audit
|

@runQuickRef |
  htmlValidate:npx htmlhint **/*.html
  htmlLint:npx stylelint **/*.css
  cssLint:npx stylelint **/*.css
  a11y:npx pa11y **/*.html
  seoCheck:s get skills/html.s @run.seoCheck
|

@byTask |
  minimalCode:skills/ponytail.s
  codeReview:skills/ponytail.s
  styling:skills/css.s
  layout:skills/css.s
  markup:skills/html.s
  accessibility:skills/html.s
  seo:skills/html.s @seo @structuredData @openGraph
  metaTags:skills/html.s @seo @metadata
  threeD:skills/threejs.s
  webgl:skills/threejs.s
  3d:skills/threejs.s
  animation3d:skills/threejs.s @animation
  shaders:skills/glsl.s
  glsl:skills/glsl.s
  shaderToy:skills/glsl.s @shadertoylite
  raymarching:skills/glsl.s @raymarching
  sdf:skills/glsl.s @sdf
  markdown:skills/md.s
  obsidian:skills/md.s @obsidian @obsidianPlugins @obsidianBestPractices
  vault:skills/md.s @obsidian
  notes:skills/md.s @obsidian @obsidianDataview
  templates:skills/jade.s
  jade:skills/jade.s
  pug:skills/jade.s @vsPug
|

@index |
  ponytail.s:blocks:8|topic:yagni minimal code|keyBlocks:@rules @commands
  css.s:blocks:13|topic:css styling layout verification|keyBlocks:@flexbox @grid @gotchas @modern @run
  html.s:blocks:18|topic:html markup accessibility seo verification|keyBlocks:@semantic @forms @accessibility @seo @structuredData @run
  threejs.s:blocks:18|topic:threejs 3d webgl rendering|keyBlocks:@core @geometry @material @mesh @animation @controls @loader @postprocessing @gotchas
  glsl.s:blocks:16|topic:glsl shader shadertoylite|keyBlocks:@shadertoylite @stlAPI @stlUniforms @sdf @raymarching @noise
  md.s:blocks:14|topic:markdown obsidian|keyBlocks:@obsidian @obsidianCallouts @obsidianDataview @obsidianPlugins @obsidianBestPractices
  jade.s:blocks:15|topic:jade pug template|keyBlocks:@syntax @browserLib @browserAPI @vsPug @asyncLibDetails
|
