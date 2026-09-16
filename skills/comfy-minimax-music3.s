# ComfyUI MiniMax Music 3 T2M on 16GB GPU - Working Recipe
@meta |
  topic:comfy-minimax-music3
  about:generate text-to-music (Trot/kpop BGM instrumental) with MiniMax Music 3 on an RTX 3080 Ti Laptop (16GB)
  confidence:high (60s Trot BGM mp3 rendered successfully at output/audio/audio_minimax_music3_00001.mp3)
  lastUpdated:2026-09-01
  origin:built live this session - full local workflow, no paid API, from Comfy-Org/MiniMax-Music-3
  reusable:any 16GB VRAM ComfyUI MiniMax Music 3 / text-to-music workflow
|
@core |
  goal:produce a completed MiniMax Music 3 BGM mp3 on 16GB VRAM
  requires:ComfyUI 0.34 + .venv, comfy-core MiniMaxMusic3* nodes (no extra custom packs), SaveAudioAdvanced
  key:three decisions - (1) text encoder int8 vs bf16, (2) diffusion DIT int8, (3) torch/CUDA/cuDNN stack
  local:workflow audio_minimax_music_3 is FULLY LOCAL (not paid partner-API) - uses MiniMaxMusic3* comfy-core nodes
  template:audio_minimax_music_3.json ships in comfyui_workflow_templates_json/templates/ (UI format, loaders inside a subgraph)
|
@models |
  dit:minimax_music3_dit_int8_convrot.safetensors (2.4GB) - int8 is the low-VRAM diffuser, WORKS
  textEncoder:int8 = minimax_music3_text_encoder_pruned_int8_convrot.safetensors (8.5GB) - BROKEN - see @gotchas
  textEncoderBf16:minimax_music3_text_encoder_pruned_bf16.safetensors (15.5GB) - the pick that WORKS *with* the ops.py GQA fix (@fix) - 32 q-heads vs 8 kv-heads (GQA)
  vae:minimax_music3_dav.safetensors (small)
  repo:Comfy-Org/MiniMax-Music-3 on HF; exact paths diffusion_models/ text_encoders/ vae/
  fileNames:bf16 name has NO _convrot suffix (pruned_bf16.safetensors) - a _convrot bf16 name 404s
  offload:text encoder uses dynamic VRAM loading + cpu offload so 15.5GB fits on 16GB (layers stream)
|
@workflow |
  graph:12 nodes - UNETLoader(dit int8) + CLIPLoader(type=minimax, text enc) + VAELoader(dav) -> SeedNode -> MiniMaxMusic3TextEncode(caption/lyrics/seed/max_duration/cfg/top_k) -> ConditioningZeroOut(neg) + EmptyMiniMaxMusic3LatentAudio(seconds) -> KSampler(euler/simple, cfg 1.7, steps 30) -> VAEDecodeAudio -> ComfySwitchNode -> SaveAudioAdvanced(mp3)
  caption:single caption string; lyrics:"" optional (alt caption); max_duration 60s; cfg_scale 1.7; top_k 50
  output:SaveAudioAdvanced filename_prefix audio/audio_minimax_music3 -> output/audio/audio_minimax_music3.mp3
  nodeIds:the 12-node API graph after strip has hardcoded ids 35/44/45/46/47/48/49/50/51/52/53/54
  subgraph:UI template keeps loaders in definitions.subgraphs; use get_workflow action=strip to flatten to the 12-node runnable API graph
|
@launch |
  exe:cd /home/saz/Projects/AI/ComfyUI && nohup ./.venv/bin/python ./main.py > /tmp/comfy_minimax_bf16.log 2>&1 &
  attach:running server was started plain (no --use-ck-attention, no --lowvram) - keep it plain for music
  appliedPath:/home/saz/Projects/AI/ComfyUI (NOT comfy-cli's default workspace /home/saz/comfy/ComfyUI - that is a DIFFERENT install)
  verify:curl -s http://127.0.0.1:8188/system_stats (returns 200 = up)
  logs:tail -f /tmp/comfy_minimax_bf16.log
  stack:torch 2.11.0+cu130, CUDA 13.0, cuDNN 9.19 (cuDNN frontend present)
|
@runCmd |
  downloadBf16:comfyui-community download_model action=download url=https://huggingface.co/Comfy-Org/MiniMax-Music-3/resolve/main/text_encoders/minimax_music3_text_encoder_pruned_bf16.safetensors target_subfolder=text_encoders
  pollDownload:comfyui-community download_model action=status id=<id> (15.5GB, HF throttles ~1.5MB/s -> can take ~30min)
  enqueue:comfyui-community enqueue_workflow action=enqueue workflow=<12-node API graph> (returns prompt_id)
  poll:comfyui-community queue action=status prompt_id=...
  crash:server died => comfyui-community restart_comfyui action=restart, else manual nohup relaunch (see @launch)
  verifyMP3:comfyui-community get_image action=list_outputs pattern=minimax_music3
|
@gotchas |
  rootCause:GQA - MiniMax Music3 text encoder is Llama GQA (num_heads 32 != num_kv_heads 8); llama.py:623 passes enable_gqa=True with skip_reshape
  gqaBug:comfy/ops.py scaled_dot_product_attention small-tensor path (q.nelement()<131072) called torch SDPA with MISMATCHED heads (32 q vs 8 kv) + enable_gqa kwarg, never expanding kv - tripped broken native-GQA kernels
  gqaSymptoms:cuDNN 'No valid execution plans built' RuntimeError (catchable) AND FLASH/EFFICIENT/MATH native segfault (not catchable) - both from the same head mismatch, looks like a stack bug but is the GQA dispatch
  bothEncoders:int8 AND bf16 text encoders both hit this - it is NOT encoder-specific; earlier 'int8 is broken, bf16 clean' was a misdiagnosis, the fix below makes bf16 work
  fixIsOps:the working fix is a local comfy/ops.py patch (@fix), not a custom node - a custom SDP-backend-fallback node could NOT fix the segfault
  vramStillOk:bf16 encoder fits though 15.5GB - ComfyUI streams it with cpu offload (layers prefetched)
  downloadThrottle:HF anonymous resolve/main throttles big files to ~1.5MB/s - 15.5GB legitimately takes ~30min, do not assume stuck
  verifySuccess:job status_str=success + output/audio/audio_minimax_music3_00001.mp3 (15.6s stereo 44.1kHz mp3, max_volume -0.2dB = real music not silence)
  durationNote:generated clip ~15.6s regardless of max_duration=60 - Music3 autoregressive gen stops at a musical boundary, shorter than max is normal
|
@fix |
  file:comfy/ops.py (COM.../ComfyUI/comfy/ops.py) - local patch, DIVERGES from upstream ComfyUI, document when updating/rebasing
  gqaExpand:in scaled_dot_product_attention always expand kv for GQA - DROP the `not is_nvidia()` gate and the native-GQA can_use_* heuristic, replace body with:
  patch:|
        if kwargs.get("enable_gqa", False) and attn_mask is not None and q.shape[-3] != k.shape[-3]:
            k, v = repeat_kv_for_gqa(k, v, q.shape[-3], -3)
            kwargs["enable_gqa"] = False
        with sdpa_kernel(SDPA_BACKEND_PRIORITY, set_priority=True):
            return torch.nn.functional.scaled_dot_product_attention(q, k, v, *args, **kwargs)
  backendOrder:set SDPA_BACKEND_PRIORITY to [FLASH, EFFICIENT, MATH, CUDNN] (cuDNN LAST - its plan-build silently fails for matching GQA-expanded shapes on cuDNN 9.19)
  why:guaranteeing matched q/k/v heads lets SDPA take a normal (non-native-GQA) path that neither segfaults nor hits the cuDNN plan error; single-path under sdpa_kernel so the small-tensor branch no longer bypasses the priority list (which fell back to broken cuDNN)
  revert:restore upstream ops.py if torch is later upgraded to a stack with working native-GQA kernels
|
@index |
  meta:@meta
  core:@core
  models:@models
  workflow:@workflow
  launch:@launch
  run:@runCmd
  pitfalls:@gotchas
  fix:@fix
|
