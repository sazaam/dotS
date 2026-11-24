# How to Write .s Skill Files - Meta Reference
@meta |
  topic:writing-skill
  versions:1.3
  confidence:high
  lastUpdated:2026-11-22
|
@dependencies |
  requires:index.s
|
@core |
  purpose:Reference for creating and optimizing .s skill files
  usage:load only when writing or optimizing skills, not for general queries
  location:dotS store - 'dots where'
  cli:dots get skills/<skill>.s @blockName
  sFind:dots find "topic" - searches across all skills
  sOptimize:dots optimize <skill> - removes waste
  sValidate:dots validate <draft.s> - strict structural check before delivery
  refinement:promote validated learnings from live work into dotS
  newSkill:create new skill only when no existing skill can host the fact
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
  oneLinePerKey:each key:value must be on its own physical line
  continuationBad:indented text after a key line parses as a bogus key - rewrite as key:value
  wrongExample:purpose:long text then next line indented continuation -> bogus key 'continuation'
  rightExample:purpose:short complete value; split extra facts into their own keys
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
  antiTemplate:never copy authoring-guide blocks (@versioning @locking @debugging or bare @run) into domain skills
  domainOnly:every block must teach the skill topic - delete guide residue
  honestyOnly:include @honesty only when the skill makes measured claims
  dependenciesBlock:use @dependencies requires:key instead of custom deps keys in @meta
  refinementBlock:use @refinement to govern live-work evolution
  newSkillBlock:use @newSkill for creation triggers and guardrails
  promotePlaybook:use @run.promote for store promotion
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
  quickRefBlock:topic:dots get skills/skill.s @blockName
  byTaskBlock:task:skill.s block1 block2
  localOverlay:skills/index.local.s reads before skills/index.s; local keys win; gitignore skills/*.local.s
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
  silentLoss:one-off win left in transcript instead of refined at gate boundary
  promotionChurn:rewriting store skills mid-task without a gate or evidence
|
@honesty |
  ranges:state savings as measured ranges (30-90%), never flat best-case numbers
  bestCase:frame exceptional results explicitly ("best case", "single-block load")
  context:pair big numbers with what produced them (task scope, block size)
  noOverclaim:avoid absolute promises - docs that oversell lose trust
  measured:prefer real measurements over theoretical maxima
  costs:state refetch and loop costs honestly; promotion is gated, not automatic
|
@index |
  howTo:list each section and its blocks
  format:sectionName:@block1 @block2 @block3
  sections:group logically (core, data, runtime, proof, refinement, gotchas)
  includeAll:every block should appear in exactly one section
  quickRef:dots get skills/skill.s @blockName - show how to load
  newBlocks:@dependencies @refinement @newSkill @run.promote @mega @mutations @pollination
  proof:@proofGate - mandatory verification before delivering a draft
  refinement:@refinement - live-work evolution loop
  newSkill:@newSkill - creation freedom with guardrails
  promote:@run.promote - promote deltas into store
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
  validateDraft:dots validate <draft> reports unterminated blocks, bad keys, meta and index errors
|
@optimize |
  whatItDoes:removes .why explanations, detects redundancy
  runAfter:always run dots optimize after editing a skill
  redundancy:identical lines across blocks get flagged
  simplification:verbose values get shortened
  dryRun:use --dry-run to preview without modifying
  manualReview:optimization is suggestions - review before accepting
|
@proofGate |
  draft:dots validate /abs/path/<name>.s - must print structural checks passed
  parse:dots get /abs/path/<name>.s @meta - must render canonical @meta
  trim:dots optimize --dry-run /abs/path/<name>.s - must show zero actions
  route:dots find "<topic>" - must resolve after registration
  deliver:never present a draft before all four checks pass
  confidence:mark @meta confidence high only after checks pass; otherwise medium
  strict:dots validate <draft> is draft-only; legacy store files are not retroactively checked
  refine:at prompt end, run @run.promote before closing out
|
@refinement |
  purpose:turn live work into reusable skill assets
  micro:within one prompt, at each gate boundary, write deltas to scratch draft
  meso:at prompt end, promote proven deltas into the store
  macro:after a batch of tasks, audit duplicates and prune
  twoUse:promote only when a fact is proven or needed twice
  evidence:command output or failed check must back each promoted fact
  noLogs:distill; never paste raw transcripts or secrets
  costGate:skip promotion for trivial one-offs; refetch cost must beat rediscovery cost
  confidence:medium after first pass; high only after repeated passes
  newBridge:if no skill owns the topic, use @newSkill
|
@newSkill |
  freedom:any reusable domain may become a skill
  searchFirst:run dots find and dots search before creating
  preferBlock:extend an existing skill block when one owns the topic
  minimum:@meta @core @gotchas @index @run
  route:register in skills/index.s and index.s before delivery
  noDuplicate:overlapping skill means mutation or merge, not a second file
  proofGate:new skills still pass all @proofGate checks
  keepNarrow:one topic per skill; split only at real seams
|
@run.promote |
  capture:write deltas to scratch draft at gate boundary
  check:dots validate /abs/path/<draft>.s then dots optimize --dry-run <draft>
  decide:apply @refinement twoUse and costGate before any store write
  edit:dots unlock <skill>; append or revise; dots validate; dots optimize --dry-run
  register:update @index and byTask in both indexes when blocks or skills change
  lock:dots lock <skill> after checks pass
  newSkill:follow @newSkill then @proofGate for a new file
  skip:leave one-offs in transcript when no trigger fires
|
@locking |
  beforeEdit:always run `dots locked` before editing any .s file
  refuseLocked:if target is locked, refuse and inform user
  useOptimizer:always use `dots optimize` for optimization, never manual edits
  appendOnly:may append NEW content to locked files, but never modify existing
  promotionUnlock:unlock before store promotion edits; re-lock after gate
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
  versionField:canonical key is versions (plural) in @meta; version is rejected by dots validate <draft>
  prematurePromotion:single success is not a rule; require twoUse
  rawLogs:transcripts bloat skills and may leak secrets
  missingRoute:new skill without index entry is invisible to dots find
  duplicateSkill:overlapping new skill fragments routing; prefer block or mutation
|
@run |
  create:dots get skills/writing-skill.s @format
  optimize:dots optimize writing-skill
  validate:dots validate skills/writing-skill.s - structural self-check
  validateDraft:dots validate /abs/path/<name>.s - draft gate
  refine:dots get skills/writing-skill.s @refinement
  promote:dots get skills/writing-skill.s @run.promote
  find:dots find "writeSkill" - should find this skill
  indexCheck:dots get index.s - verify skill appears
  tokens:dots optimize shows token count
|
