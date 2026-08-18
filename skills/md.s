# Markdown + Obsidian Knowledge Base

@meta |topic:markdown obsidian md|versions:CommonMark-GFM-Obsidian|lastUpdated:2026-08-18|confidence:high|

@basic |
  heading:# H1, ## H2, ### H3, #### H4
  bold:**bold** or __bold__
  italic:*italic* or _italic_
  strikethrough:~~strikethrough~~
  code:`inline code`
  codeBlock:```lang ... ```
  link:[text](url)
  image:![alt](path)
  unorderedList:- item or * item or + item
  orderedList:1. item
  taskList:- [ ] unchecked, - [x] checked
  blockquote:> quote
  horizontalRule:--- or *** or ___
  escape:\*not italic\*
  html:inline HTML works in most parsers
|

@obsidian |
  wikilink:[[note]] or [[note|alias]]
  embed:![[image.png]] or ![[note#heading]]
  tag:#tag or #parent/child
  callout:> [!note] Title\n> Content
  backlinks:automatically linked via [[wikilinks]]
  graph:Graph view shows connections
  canvas:canvas files (.canvas) for visual boards
  dailyNotes:YYYY-MM-DD format, auto-created
  templates:use {{date}} and {{title}} placeholders
  properties:YAML frontmatter with key: value
  inlineFields::key:: value or key: value
  dataview:`dataview` plugin for queries
  hotkeys:Ctrl+O quick switcher, Ctrl+E edit/preview
  outline:Outline plugin shows heading structure
  commands:Ctrl+P command palette
|

@obsidianCallouts |
  note:> [!note] Note
  tip:> [!tip] Tip
  important:> [!important] Important
  warning:> [!warning] Warning
  caution:> [!caution] Caution
  quote:> [!quote] Quote
  example:> [!example] Example
  question:> [!question] Question
  bug:> [!bug] Bug
  success:> [!success] Success
  custom:> [!info]- Collapsed\n> Content
  numbered:> [!note]+ Numbered (1. 2. 3.)
|

@obsidianDataview |
  list:```dataview\nLIST FROM "folder"\n```
  table:```dataview\nTABLE author, date\nFROM "notes"\nSORT date DESC\n```
  task:```dataview\nTASK FROM "projects"\nWHERE !completed\n```
  calendar:```dataview\nCALENDAR file.ctime\nFROM "daily"\n```
  inline:`= this.file.name`
  inlineField:`[author:: Name]`
  where:WHERE contains(tags, "todo")
  sort:SORT file.mtime DESC
  group:GROUP BY category
  limit:LIMIT 10
|

@obsidianProperties |
  yaml:---\ntitle: My Note\ntags: [project, dev]\ncreated: 2026-08-18\n---
  inlineField:status:: active
  inlineFieldDate:due:: 2026-08-20
  inlineFieldList:tags:: [dev, js]
  inlineFieldBool:done:: false
  inlineFieldEmbed:related:: [[other-note]]
|

@gfm |
  table:"| Col1 | Col2 |\n|------|------|\n| a    | b    |"
  alertBlock:"> [!NOTE]\n> Content"
  autoLink:https://example.com (auto-linked)
  footnotes:text[^1] and [^1]: footnote
  taskList:- [x] done, - [ ] todo
  strikethrough:~~deleted~~
  syntaxHighlight:```lang with highlighting
|

@obsidianFormatting |
  calloutCollapse:> [!tip]- Click to expand\n> Content
  calloutExpand:> [!note]+ Always open\n> Content
  columns:%% div columns %%%% column %%% content %%%% column %%% content %%%%%%
  mark:==highlighted text==
  superscript:super^script^
  subscript:sub~script~
  comment:%% this is a comment %%
  math:$inline math$ or $$block math$$
  mermaid:```mermaid\ngraph TD\nA-->B\n```
  latex:```latex\n\\frac{1}{2}\n```
|

@obsidianFrontmatter |
  title:title: My Note
  aliases:aliases: [alias1, alias2]
  tags:tags: [tag1, tag2]
  created:created: 2026-08-18
  modified:modified: 2026-08-18
  publish:publish: true
  cssclass:cssclass: wide, no-title
  region:region: header
  lang:lang: en
  social-image:image: assets/og.png
|

@obsidianPlugins |
  dataview:query notes with dataview API
  templater:advanced templates with JS
  calendar:visual calendar for daily notes
  periodic-notes:daily/weekly/monthly notes
  dataviewjs:```dataviewjs\ndv.list(...)\n```
  kanban:kanban boards from markdown
  excalidraw:embed excalidraw diagrams
  obsidian-extract-highlights:extract highlights
  quick-switcher:Ctrl+O for fast navigation
  obsidian-git:git sync for vault
  style-settings:customize theme CSS
|

@obsidianThemes |
  minimal:minimal, clean, popular
  primary:colorful, modern
  things:apple-things inspired
  prism:lightweight, fast
  anomalous:dark, unique
  california-coast:gradient, warm
  ITS:feature-rich, customizable
  styleSettings:use Style Settings plugin to customize
|

@obsidianBestPractices |
  structure:use consistent heading hierarchy (H1 > H2 > H3)
  links:use [[wikilinks]] over [markdown](links) for backlinks
  tags:use #nested/tags for hierarchy
  folders:keep flat structure, use tags over folders
  naming:use descriptive filenames (no dates prefix needed)
  templates:use Templater for dynamic content
  dailyNotes:use Periodic Notes for daily/weekly/monthly
  images:store in assets/ folder, use ![[image.png]]
  metadata:use YAML frontmatter for structured data
  MOC:Map of Content notes for navigation
  zettelkasten:atomic notes, one idea per note
  linkDensity:aim for 3-5 internal links per note
|

@obsidianMOC |
  purpose:Map of Content for navigation hub
  structure:list of [[links]] grouped by topic
  example:"## Topics\n- [[Topic A]]\n- [[Topic B]]\n\n## Projects\n- [[Project 1]]"
  update:regularly review and update links
  naming:use MOC prefix or suffix (MOC-Projects, Projects-MOC)
|

@markdownGotchas |
  spacing:blank line before/after lists and headings
  indents:use 4 spaces or 1 tab for nested content
  links:relative paths for local files
  images:relative paths from vault root
  codeBlocks:specify language for syntax highlighting
  tables:align pipes, use separator row
  html:HTML works but breaks portability
  lineBreaks:two spaces + newline for line break
  unicode:some parsers handle unicode differently
|

@obsidianGotchas |
  links:Obsidian requires [[wikilinks]] for backlinks
  images:use ![[image.png]] not ![](image.png) for Obsidian
  tags:no spaces in tags, use camelCase or kebab-case
  folders:avoid special characters in folder names
  publish:use publish: false in frontmatter for private notes
  cssclass:use cssclass in frontmatter for note-specific styling
  aliases:use aliases for alternate names
  embeds:![[note]] embeds, [[note]] links
  dailyNotes:check date format in settings (YYYY-MM-DD)
  templates:ensure Templater plugin is installed and enabled
|
