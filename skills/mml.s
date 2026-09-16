# Music Macro Language (MML) Chiptune Reference
@dependencies |
  requires:index.s
|
@meta |
  topic:mml
  about:music macro language - text song format for chiptune/retro drivers, derived from sheet music
  versions:universal core + dialect notes (PMD/mck/ppmck/ctrmml/AddMusicK/MUCOM88/JSiON)
  confidence:high
  lastUpdated:2026-09-05
  source:pedipanol mml-guide, Wikipedia Music Macro Language, JSiON README
|
@core |
  purpose:reference for reading, writing, editing and debugging MML songs across chiptune drivers
  usage:consult when asked to compose/transcribe/fix chiptune songs, MML data, or music macros
  mindset:MML is sheet music in plain text, NOT programming - the driver interprets it, you read it like a score
  universal:core syntax is shared by ~90% of formats (notes, lengths, rests, octaves, tempo)
  dialect:each driver diverges on commands, headers, channel letters, instruments - check @dialects first
  hint:to try examples immediately, run them in PMD on channel G (no special setup needed)
|
@basics |
  file:.mml is plain text (any text editor); extension varies by driver (.mck .mdx .txt)
  caseSensitive:MML is case-sensitive - notes are lowercase a-g, uppercase letters are commands
  noteLetters:a b c d e f g (standard musical letter names)
  rest:r - same length rules as a note (r8 is an eighth rest)
  repeatNote:x plays the same note as the previous one (PMD)
  lengthAfter:length number comes AFTER the note (a4 = quarter note)
  wholeDivision:lengths divide the whole note: 1=whole 2=half 4=quarter 8=eighth 16 32...
  tickCount:length resolution depends on the whole-note tick count (PMD default 96)
  l:l<val> sets the default length for following notes/rests without one (l4)
  sharp:+ after letter, always BEFORE length (f+8, not f8+)
  flat:- after letter, always BEFORE length
  relativeSharp:PMD treats + / - as RELATIVE and stackable (a++ = b); = forces a natural
  spaces:whitespace is free except between numbers, before + - . , or before a command value
|
@notes |
  scale:cdefgab>c
  middleC:o4 usually holds middle c (varies slightly per driver)
  octaveSet:o<value> fixes absolute octave; most drivers limit o1-o8
  octaveUp:> up one octave (default direction - some headers swap the signs)
  octaveDown:< down one octave
  keySig:_{+fcg} auto-sharps f,c,g on that channel until reset (PMD)
  keySigReset:_{=fcg} clears, or = on a note overrides auto accidental for that one (eg=f+4? no: g=f? use g=8)
  noteTest:G l8 ab>cd efga4 plays the A major scale with a key signature
|
@lengths |
  default:l<val> sets default length for all following notes AND rests
  dotted:. after a note adds half its length (a4. = a4 tie a8)
  multiDot:PMD stacks dots while divisible (g4... = g4&8&16&32)
  tie:& (PMD) or ^ (other drivers) ties/slurs to the next note (c8& d8)
  tieLen:PMD allows length-only after a tie to extend (c8 &8)
  tickLen:%<value> exact tick length instead of a division (PMD: g%45 = g4...) - precise but fragile to desync
  triplets:use lengths divisible by 3 (tick-based) rather than a dedicated command where unsupported
|
@tempo |
  set:t<value> or T<value> sets song tempo from that line onward
  value:number is usually BPM, but some drivers use a timer period instead - verify per driver
  relative:+ or - prefix makes a relative change (t+20)
  pmdHalf:PMD #Tempo/t defaults to HALF the desired BPM - double it for real speed
  pmdTimer:PMD TimerB -> 256 - [10800000 / (bpm * 13 * Zenlen)] for exact bpm
|
@volume |
  set:v<value> or V<value> sets current channel volume
  relative:+ or - prefix for a relative change in most drivers
  parens:( and ) are relative volume change in many drivers - not decoration inside a line
  range:depends on driver and channel type (PMD: V 0-127 FM, 0-15 SSG; v 0-16 coarse)
  oneNote:v^<val> changes volume for ONLY the next note (PMD), e.g. 1-channel echo
|
@transpose |
  normal:_+2 or _-5 shifts the written sequence that many semitones (PMD)
  channel:_M+2 channel transposition - stacks ADDITIVELY with normal transpose (PMD)
  usage:write in a convenient key with few accidentals, then transpose the whole line at the end
|
@detune |
  set:D<value> detunes the channel in chip-specific units (NOT cents; unequal across pitch)
  highPitch:the same D value detunes MORE at higher octaves (chip tuning table)
  constantI:I<value> keeps detune even across the range - PMD only, needs #Bendrange/B header
  sparse:constant detune is prone to inaccuracy and wrong tones, especially on SSG - use sparingly
|
@quantize |
  coarse:Q<value> plays each note value/8 of its full length (staccato control; Q4 = half-length)
  fine:q<value> subtracts that many ticks from the note (releases the last tick)
  fmEnvelope:fine quantization is key on FM - a gap lets the envelope reset so attacks are audible
  tied:quantization sizes the WHOLE tied duration, not per note - untie to force separate attacks
|
@loops |
  brackets:[ ... ] marks a loop body
  count:]<n> after the close repeats that many times total (PMD: c]2)
  break:an in-loop break symbol marks a segment played every pass except the LAST (final pass = ending)
  breakPmd:break symbol is : in PMD (f+1 : f+1]2 plays the first bar then a different outro)
  nesting:loops nest freely ([[...]3 ...]2)
  stateKeep:PMD keeps effect commands (transpose/detune) ACTIVE into loop repeats - do not assume a reset
  channelLoop:L loops everything from L to end of channel forever (per channel)
  addmusicNope:AddMusicK does NOT support brackets - use its native loop/flag syntax instead
|
@macros |
  seqMacro:![char] defines a sequence macro; the macro name is then a command playing that stored sequence
  inline:macros are inlined at compile - every command in them applies to the first following note
  instrument:instrument macros collect @ instrument/tone definitions - exact format is driver-specific
  rhythm:PMD R<value> defines rhythm macros played on the K rhythm channel
  drumKit:pack each drum as a sequence macro (instrument + effects + octave + transpose + quant)
  absolute:absolute macros (rerunnable anywhere) are rare - mostly drivers inline, so relative state leaks
|
@structure |
  header:lines starting with # hold metadata + song-wide options (#Title #Memo #Tempo #Option)
  optionPmd:#Option /v/c - /v stops MML parts being ignored, /c prints each channel length in ticks
  instruments:@ lines define FM/PSG instruments and tone tables (PMD FM: 42 params, see @dialects)
  seqMacros:! lines define sequence macros (see @macros)
  channels:a letter (or letters) at line start routes that line to a channel; space/tab after the letter
  multi:compose several letters (GH ...) to address 2+ channels at once - handy for delayed echoes
  headerOptional:all headers are optional in PMD; only #Option /v/c is really recommended
|
@channels |
  pmdFM:A B C D E F (FM channels 1-6)
  pmdSSG:G H I (SSG/PSG channels 1-3)
  pmdPCM:J (ADPCM or 86PCM channel)
  pmdRhythm:K (rhythm channel; overrides channel I; R macro definitions needed)
  x68000:MXDRV/MDX-style uses named MPU W M A D T channels instead of letters
  verify:channel letter maps differ per driver - always check the target driver's manual, never assume A-K
|
@dialects |
  pmd:PC-98 YM2203/2608 driver by Masahiro Kajihara (KAJA) - the main reference dialect; A-K channels, # headers
  pmdChip:YM2608 = 6 FM + 3 SSG + 1 ADPCM + 6 rhythm; YM2203/OPN = 3 FM + 3 SSG
  mck:family of Famicom/NES drivers incl. mc*, ppmck (bankswitching + extra chips), and Fan Famicom translated manual
  addmusick:SNES/SMW fork of mck - no [ ] loops, its own loop/flags
  ctrmml:Sega Genesis/Mega Drive - GUI editor with instant playback
  mucom88:PC-88 by Yuzo Koshiro - GUI editor
  mxdrv:Sharp X68000 driver, file format MDX
  mml2vgm:MML IDE that plays pmd/mucom88/moondrv and exports VGM/M - multi-chip
  jsion:JSiON bridges JS to the Flash SiON MML Player (jsion.swf) - Flash-only, needs Ruffle/WASM to run in a modern browser
  sourceDoc:PMD manual mirror https://pigu-a.github.io/pmddocs/pmdmml.htm
|
@tools |
  jsionPlay:compile+play: new JSiON(onSWFReady) then jsion.play(mml) - requires the jsion.swf + Flash runtime
  jsionCtl:stop / pause / resume / position(ms) / volume(0-1) / isReady / isPlaying / trackCount
  jsionRuffle:embed the swf in Ruffle (WASM Flash emulator, pure JS) to play it in a modern browser; the JS<->SWF ExternalInterface bridge is still shaky
  sionicjs:mohayonao pico.js MML demo extracted to a library (MIT, pure WebAudio) - supports /:N :/ loops, FM2OP, wave-memory WAVB; no [ ] or $ loops yet
  jsionVoice:SiONPresetVoice(name) or embed voices in MML like #OPN@0{ m f:15 f:15 p:v:a etc }
  pmdCompile:mc <mmlfile> compiles to .M; /p plays after compiling, /c lists each channel's tick length
  pmdEmu:PMD output plays in PMDWin / FMPMD2000 / 98fmplayer / inFMPMD plugin / foo_input_fmpmd
  instrumentImport:YM2608 Tone Editor converts BTI/TFI/DMP/OPM instruments into PMD MML format
|
@examples |
  intro:a4d4 r8 d4b8 a4d4 r8 a4g8 f+8 f+8 g8a8 d4e4 f+1 - Flintstones theme (works in most drivers)
  withDefaults:o4 l4 adr8>d<b8 adr8ag8 f+8f+8g8a8de f+1
  withLoop:l4 [adr8>d<b8 adr8ag8 f+8f+8g8a8de : f+1]2 d1 - loop with a separate final bar
  leadEcho:GH o4 l8 cdefgab>c with H preset a line before (D-2 v8 r8.) - H echoes G late
  drum:!b @1 MP-80 v10 o1 _+9 Q4 then call !b like a note - a percussion macro
  transpose:!a rgb>d [f+gf+d]3< then !a !a _-5 !a !a - hard transposition between macro calls
|
@gotchas |
  caseNotes:capital letters are COMMANDS, lowercase are notes - an uppercase note silently plays a command
  lengthPlace:accidental first, length after (f+8); putting length on the wrong side gives wrong/ignored input
  lAppliesRest:l<val> default length applies to rests too - l32 then r is a very short rest
  loopLeak:PMD does not reset effect commands across loop repeat or channel-loop L - reset or expect bleed
  addmusicLoop:AddMusicK has no bracket loops - do not port PMD-style [ : ]2 loops to SMW songs
  spacing:spaces between digits break numbers (l8  = l then 8?) and before value commands (t 120 can misparse)
  pmdTempo:PMD tempo value is half the BPM by default - the single most common timing mistake
  missingInstrument:an undefined @ or wrong channel letter mutes the channel or fails compilation - check @defs
  parensVolume:( / ) move volume in many drivers - a stray paren inside a line changes loudness
  dotsCache:dotted lengths only stack while the result stays divisible; ties + TENS of dots mislead manual editing
  tieWidth:quantize and loops operate on the whole tied span, not each note - split ties for separate kicks
|
@index |
  meta:@meta
  core:@core
  quickstart:@basics @examples
  pitch:@notes @lengths @transpose @detune
  timing:@tempo @quantize @loops
  composition:@macros @structure @channels
  format:@dialects @tools
  pitfalls:@gotchas
|