# Audio Drama Recording Pipeline Knowledge Base
@meta |
  topic:audio-drama-pipeline
  origin:"언니들 Sisters production, ~/sisters_audio"
  confidence:high
  lastUpdated:2026-08-24
  reusable:"template for future per-line theatrical recording projects"
|
@concept |
  unit:"one take per cue line; id = global sort key = filename anchor"
  naming:C{ch:02d}_L{id:03d}_{role}.wav
  batchDrop:N-M.mp3 covers cues N..M in one organic performance
  batchRule:never split batches - internal timing is the actors' art
  sources:cues.csv from HWP/PDF script via pyhwp or text parse
|
@flow |
  1:drop raw takes into recordings/ (single N.mp3, batch N-M.mp3)
  2:process_audio.py - trims head/tail only, renames to convention, backs up originals
  3:check_progress.py - coverage from processed/, never raw names
  4:build_show.py - rough cut concat + timeline csv + audacity labels + blender script gen
  5:blender -b -P show/blender_build.py - rebuilds VSE editing file with markers
|
@trim |
  pads:head 0.05s / tail 0.12s (tight attack, unclipped endings)
  threshold:-40dB calibrated against room noise (AC hum defeated -45dB default)
  calibration:sweep silencedetect -40/-35/-30 d=0.15 on RAW takes; onset must stay stable as threshold rises; if onset jumps LATER the floor is above that threshold - go higher until every sampled head reads clean ~0.2-0.5s
  chain:silenceremove head, areverse, silenceremove tail, areverse
  internal:NEVER stop_periods=-1 - deletes mid-line pauses
|
@pacing |
  columns:post_delay seconds + pacing_note reason on every cue row
  directorCut:dialogue tiers all 0.0 (tight/normal/beat/hold); solemn 1.8 only for scripted silences and music cues
  chapterGap:1.5s at builder level, not in post_delay
  semantics:gap AFTER line N uses post_delay of N (watch off-by-one)
  zeroGaps:builder must skip gap insertion when gap<=0 (no 0-second wavs)
|
@loudness |
  chain:highpass=f=75,loudnorm=I=-16:TP=-1.5:LRA=11 at ASSEMBLY time not trim time
  whyAssembly:processed/ stays pristine; normalization reversible by builder edit alone
  effect:evens actor levels (~8 LU spread observed) while LRA keeps intra-line dynamics
  orderMatters:-ar must come AFTER loudnorm filter (it resamples to 192k internally)
|
@dsp |
  formant:rubberband=pitch=1.0:formant=1.20 brightens timbre no pitch shift (voice character)
  formantRange:1.10-1.25 subtle; >1.3 cartoonish
  verifyBuild:ffmpeg -filters | grep rubberband before relying on it
|
@gotchas |
  staleCache:delete build_cache/*.wav after re-trim or normalize step or old audio leaks into new build
  ghostProbes:verify filenames exist before ffprobe loops - silent failures masquerade as 'hot noise floors'
  dupCopies:raw copies of batches reappear byte-identical - md5 compare before calling retake
  blendRegen:rebuild overwrites manual .blend edits - Save As for tweaks
  trackerLies:progress must read processed/ ids incl batch ranges, not recordings/ raw names
  timestampFiles:recorders emit default names like 2026_08_22_20_03_01.mp3 - flag for user identification
  mp3Tail:libavformat benign final-frame errors on mp3 decode, ignore stderr noise
  vseEnd:strip.frame_final_end is EXCLUSIVE, scene.frame_end INCLUSIVE - set frame_end to max(frame_final_end)-1 or last clip duration is cut off
|
@futureProject |
  copy:scripts + README.md skeleton, drop old recordings/processed/cache/show/backups
  reparse:parse_script.py regenerates cues.csv from new source; pacing columns preserved across re-parses by design
  annotate:read all cues once, assign tiers via rules + judgment overrides pattern (annotate_pacing.py)
  roles:expect role-specific passes (formant etc) decided with director mid-production
|
