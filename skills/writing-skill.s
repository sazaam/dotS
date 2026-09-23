# How to Write .s Skill Files - Meta Reference

@meta |
  topic:writing-skill
  versions:1.0
  confidence:high
  lastUpdated:2026-08-21
|
@dependencies |
  requires:index.s
|
@core |
  purpose:Reference for creating and optimizing .s skill files
  usage:load only when writing or optimizing skills, not for general queries
  location:dotS store - 'dots where'
  cli:dots get <skill>.s @blockName
  sFind:dots find "topic" - searches across all skills
  sOptimize:dots optimize <skill> - removes waste
|
@format |
  blockStart:@blockName followed by pipe on next line
  blockEnd:pipe | alone on a line terminates the block
  keyValuePair:key:value - colon separates key from value
  multiValue:pipe | separates values on same line
  inlineBlock:@meta | key:val | key:val | - all on one line
  blockName:starts with @, letters/numbers/underscores only
  noPipeAlone:never put | alone inside a block content - it will close the block
  shellPipe:cmd:cat file | grep pattern is safe - pipe is inside value
  whitespace:keys and values are trimmed of leading/trailing spaces
|
@blocks |
  naming:camelCase for keys (firstWord, not first_word)
  blockNames:use descriptive @names (@operators, @gotchas, @meshBasics)
  splitting:one topic per block - don't mix unrelated content
  merging:if items are short and related, put on one line (a:b:c:d)
  indexEverySkill:every skill needs @index block for routing
  gotchasBlock:always include @gotchas for pitfalls
  metaBlock:always include @meta with topic, versions, confidence, lastUpdated
  coreBlock:include @core with purpose and usage instructions
|
@tokens |
  mergeLine:foo:bar:baz:qux on one line = 1 line not 4
  skipObvious:don't write "create:creates an object" - just "create:object"
  shortKeys:use terse keys (name, not theNameOfTheThing)
  shortValues:value after colon should be minimal explanation
  noRedundancy:don't repeat same info in multiple blocks
  compactArrays:list items with colons not newlines when <5 items
  avoidWhy:remove explanatory text, keep only actionable info
  gotchasMove:move explanations to @gotchas, not inline
|
@patterns |
  simpleSkill:@meta + @core + @blocks + @gotchas + @index
  referenceSkill:@meta + @core + multiple content blocks + @gotchas + @index
  indexBlock:sectionName:@block1 @block2 @block3
  quickRefBlock:topic:dots get skill.s @blockName
  byTaskBlock:task:skill.s block1 block2
|
@antiPatterns |
  verboseValue:this function creates a new mesh object by calling" -> just "create new mesh
  redundantBlocks:don't have @meshBasics and @meshIntro with same content
  obviousKeys:type:type of thing -> type:thing
  duplicateAcross:don't copy same gotcha to 3 different blocks
  missingIndex:every skill MUST have @index
  noMeta:every skill MUST have @meta
  longLines:>200 chars per line wastes tokens
  lonePipe:putting | on its own inside block content breaks parsing
|
@honesty |
  ranges:state savings as measured ranges (30-90%), never flat best-case numbers
  bestCase:frame exceptional results explicitly ("best case", "single-block load")
  context:pair big numbers with what produced them (task scope, block size)
  noOverclaim:avoid absolute promises - docs that oversell lose trust
  measured:prefer real measurements over theoretical maxima
|
@index |
  howTo:list each section and its blocks
  format:sectionName:@block1 @block2 @block3
  sections:group logically (core, data, runtime, gotchas)
  includeAll:every block should appear in exactly one section
  quickRef:dots get skill.s @blockName - show how to load
  newBlocks:@dependencies @mega @mutations @pollination
  honesty:@honesty - claims discipline for docs and savings numbers
|
@versioning |
  versionDetect:bpy.app.version returns (major, minor, patch)
  versionBlock:create @versionGotchas block for version-specific issues
  versionKey:use format X_Y for version keys (4_0, 5_2)
  backwardsNote:document when behavior changed
  multiVersion:list all supported versions in @meta
|
@debugging |
  lonePipe:if block cuts off early, check for | alone on a line
  missingEnd:block not found? ensure closing | is alone on line
  keyNoValue:key with no colon? syntax error
  brokenIndex:@index references wrong block name
  sFindBlank:dots find returns nothing? check block names match
  sOptimizeDryRun:run dots optimize --dry-run to preview changes
  tokenCount:dots optimize shows token count - track changes
|
@optimize |
  whatItDoes:removes .why explanations, detects redundancy
  runAfter:always run dots optimize after editing a skill
  redundancy:identical lines across blocks get flagged
  simplification:verbose values get shortened
  dryRun:use --dry-run to preview without modifying
  manualReview:optimization is suggestions - review before accepting
|
@locking |
  beforeEdit:always run `dots locked` before editing any .s file
  refuseLocked:if target is locked, refuse and inform user
  useOptimizer:always use `dots optimize` for optimization, never manual edits
  appendOnly:may append NEW content to locked files, but never modify existing
  osProtect:dots lock makes files read-only (chmod -w), unlock restores (chmod +w)
|
@dependencies |
  requires:index.s
  addBlock:add @dependencies block with requires:key
  resolve:dots deps <skill> shows dependencies
  loadAll:dots load <skill> loads skill + all dependencies
  graph:dots graph shows all dependency relationships
|
@mega |
  purpose:combine multiple skills into composite bundles
  create:dots mega create <name> <skill1> <skill2> ...
  list:dots mega list shows all mega-skills
  load:dots mega load <name> loads all skills in bundle
  show:dots mega show <name> shows bundle contents
|
@mutations |
  purpose:create skill variants for specific contexts
  create:dots mutate create <base_skill> <context> [name]
  list:dots mutate list shows all mutations
  show:dots mutate show <name> shows mutation details
|
@pollination |
  purpose:cross-pollinate skills by sharing patterns
  list:dots pollinate list shows all skills with their blocks
  compare:dots pollinate <skill1> <skill2> shows common/different blocks
  all:dots pollinate --all shows all cross-pollination opportunities
|
@gotchas |
  pipeInValue:pipe inside a value is SAFE only if not alone on line
  noPipeAlone:putting | on its own line = block terminator, not content
  blockNotFound:typo in block name causes "not found" error
  emptyBlock:empty blocks (just @name | |) waste tokens
  indexMismatch:@index referencing non-existent block
  versionField:always include version in @meta for cache invalidation
|
@run |
  create:dots get writing-skill.s @format
  optimize:dots optimize writing-skill
  validate:dots find "writing" - should find this skill
  indexCheck:dots get index.s - verify skill appears
  tokens:dots optimize shows token count
|
