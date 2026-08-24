# FFmpeg Knowledge Base
@meta |
  topic:ffmpeg
  version:n7.x+ (verified n9.0.1-static)
  confidence:high
  lastUpdated:2026-08-22
  verified:trimSilence, pitchFormant, concat, sources used in production pipeline
|
@basics |
  syntax:ffmpeg -v error -y -i in.wav -af "filters" out.wav
  verbose:-v error hides banner/warnings; -hide_banner for other tools
  overwrite:-y skips confirm prompt
  outputOpts:-ar 48000 -ac 1 -c:a pcm_s16le (rate/channels/codec)
  seekFast:-ss before -i (keyframe seek); -ss after -i (accurate)
  duration:-t seconds as OUTPUT option trims end
  filters:-af audio filterchain, comma-separated; -filter_complex for multi-stream
  noVideo:-vn strips video streams
  map:-map 0:a selects all audio; needed when input has covers/subs
|
@probe |
  duration:ffprobe -v error -show_entries format=duration -of csv=p=0 file.mp3
  json:ffprobe -v error -print_format json -show_format -show_streams file
  streamInfo:ffprobe -v error -select_streams a:0 -show_entries stream=codec_name,sample_rate,channels file
  frameCount:ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_read_frames file
  silenceScan:ffprobe -f lavfi -i amovie=file.mp3,silencedetect=noise=-45dB:d=0.5 -f null -
|
@normalize |
  standardize:ffmpeg -v error -y -i in.mp3 -ar 48000 -ac 1 -c:a pcm_s16le out.wav
  why:uniform sample rate/channels/codec required before concat demuxer
  keepBitDepth:pcm_s24le or pcm_f32le for headroom during processing
  batch:for f in *.mp3; do ffmpeg -v error -y -i "$f" -ar 48000 -ac 1 "${f%.mp3}.wav"; done
|
@trimSilence |
  headTail:ffmpeg -i in.wav -af "silenceremove=start_periods=1:start_threshold=-45dB:start_silence=0.25,areverse,silenceremove=start_periods=1:start_threshold=-45dB:start_silence=0.25,areverse" out.wav
  howItWorks:no tail-trim filter — areverse flips audio, trim head again, flip back
  startSilence:start_silence=N keeps N sec of lead-in (natural breathing room)
  internalPauses:NEVER set stop_periods=-1 globally — it deletes mid-line pauses too
  thresholdTune:-45dB default; raise (-40) if room noise not trimmed, lower (-50) if soft speech clipped
  verify:silencedetect on result should report ~0 silence at ends
  padAfter:add adelay or apad if fixed padding needed post-trim
|
@silenceDetect |
  detect:ffmpeg -i in.wav -af silencedetect=noise=-45dB:d=0.5 -f null - 2>&1 | grep silence_
  noise:threshold (e.g. -45dB, -30dB)
  d:min duration to report
  output:silence_start / silence_end lines on stderr
  useCase:verify trimming worked; find long gaps in recordings
|
@pitchFormant |
  rubberband:ffmpeg -i in.wav -af "rubberband=pitch=1.0:formant=1.20" out.wav
  formantShift:formant=N changes timbre/brightness WITHOUT pitch (voice character)
  pitchShift:pitch=N changes musical pitch without changing speed
  both:setting pitch AND formant shifts pitch and brightens independently
  naivePitch:-af "asetrate=48000*1.2,aresample=48000,atempo=1/1.2" (chipmunk artifacts vs rubberband quality)
  availability:rubberband needs ffmpeg built WITH librubberband (check ffmpeg -filters | grep rubberband)
  range:formant 1.10-1.25 subtle brightening; >1.3 sounds cartoonish
|
@loudness |
  onePass:ffmpeg -i in.wav -af loudnorm=I=-16:TP=-1.5:LRA=11 out.wav
  standards:I integrated LUFS, TP true peak dBTP, LRA loudness range (EBU R128)
  speechTarget:I=-16 to -23 depending on platform (podcast -16, broadcast -23)
  twoPass:run loudnorm print_format=json first, feed measured values back as params
  measureOnly:ffmpeg -i in.wav -af loudnorm=print_format=json -f null -
  matchClips:normalizing every take to same I gives consistent level across sessions
|
@concat |
  listFile:printf "file '%s'\n" /abs/path/a.wav /abs/path/b.wav > list.txt
  concatDemuxer:ffmpeg -f concat -safe 0 -i list.txt -c:a pcm_s16le out.wav
  safeZero:-safe 0 REQUIRED for absolute paths in list.txt
  sameParams:all inputs must share sample rate/channels/codec — normalize first
  gapInsertion:generate silence spacers with anullsrc and interleave in list
  filterAlt:ffmpeg -i a.wav -i b.wav -filter_complex "[0:a][1:a]concat=n=2:v=0:a=1" out.wav (loads all in RAM)
  timelineCsv:log each clip start/end while building for external editors
|
@sources |
  silence:anullsrc=r=48000:cl=mono -t 1.5 (gap filler)
  sine:sine=frequency=440:sample_rate=48000 -t 1 (test tone)
  lavfiInput:-f lavfi -i "sine=..." — synthetic input source
  mixUnder:amix=inputs=2:duration=first or amerge for side-by-side
  volume:volume=1.5db gain adjust inside any filterchain
|
@gotchas |
  mp3Tail:libavformat emits benign "Header missing / Error parsing final frame" on many mp3s (~50ms tail loss) — decode once to wav, ignore stderr
  concatMismatch:"Input stream parameters do not match" = normalize all inputs first
  reverseTrick:tail trim requires double areverse — single pass only trims head
  stopPeriods:stop_periods>0 removes ALL silence matching threshold, not just ends
  optionOrder:-ss/-t placement matters: before -i seeks input, after filters output
  pipeSafe:use -f wav pipe:1 for stdout piping; add -loglevel error to keep stream clean
  rubberbandDep:not in every static build — verify with ffmpeg -filters
  loudnormResample:loudnorm internally upsamples to 192kHz — put -ar AFTER the filter to restore rate
  windowsQuoting:on zsh/bash quote whole -af chain; commas inside filter args need escaping in complex graphs
|
@run normalizeDir |
  1.cmd:mkdir -p normalized && for f in *.{mp3,wav,m4a}; do [ -e "$f" ] && ffmpeg -v error -y -i "$f" -ar 48000 -ac 1 -c:a pcm_s16le "normalized/${f%.*}.wav"; done
  1.onFail:check codec support — run ffprobe on failing file
  2.cmd:ls normalized | wc -l && ls | grep -Ec "\.(mp3|wav|m4a)$"
  2.note:counts must match — investigate any missing conversions
|
@run trimAllWavs |
  1.cmd:mkdir -p trimmed && for f in *.wav; do ffmpeg -v error -y -i "$f" -af "silenceremove=start_periods=1:start_threshold=-45dB:start_silence=0.25,areverse,silenceremove=start_periods=1:start_threshold=-45dB:start_silence=0.25,areverse" "trimmed/$f"; done
  1.onFail:lower threshold to -50dB if files come out empty (too quiet source)
  2.cmd:for f in trimmed/*.wav; do ffprobe -v error -show_entries format=duration -of csv=p=0 "$f"; done
  2.note:review durations — zero/near-zero means threshold ate the take
|
