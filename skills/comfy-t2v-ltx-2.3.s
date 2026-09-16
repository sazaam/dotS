# ComfyUI LTX-2.3 T2V on 16GB GPU - Working Recipe
@meta |
  topic:comfy-t2v-ltx-2.3
  about:render LTX-2.3 22B text-to-video on an RTX 3080 Ti Laptop (16GB) without OOM
  confidence:high
  lastUpdated:2026-08-31
  origin:achieved live this session - verified 2.6s 512x320 65-frame h264 mp4 output
  reusable:any 16GB VRAM ComfyUI GGUF video workflow
|
@core |
  goal:produce a completed LTX-2.3 T2V mp4 on 16GB VRAM (RTX 3080 Ti Laptop)
  requires:ComfyUI 0.34 + .venv, ComfyUI-GGUF node, ComfyUI-LTXVideo, VHS
  key:three levers - (1) quant size, (2) sampling resolution/frames, (3) launch flags
  warnings:Q4 unet resident ~10.75GB always OOM'd; small 256-576MiB allocs failed despite apparent free VRAM
|
@models |
  unet:unsloth/LTX-2.3-GGUF ltx-2.3-22b-dev-Q3_K_M.gguf (10GB) in models/unet/
  devVsDistilled:dev needs >=20 steps; distilled is a drafting/refining model (4-8 steps, CFG=1)
  canonicalWorkflow:base DEV gguf + distilled LORA on top (not a distilled gguf) - see @workflow
  wrongPick:distilled-1.1 gguf + distilled lora would double-apply distillation - DON'T
  fallback19B:unsloth/LTX-2-GGUF = LTX-2 19B quants (different text-encoder stack) - avoid
  sizesDev:Q2_K 7.71GB, Q3_K_S 9.26GB, Q3_K_M 10.03GB, Q4_K_S 10.75GB-resident (OOM wall)
  loras:distilled-lora-384-1.1 (7.6GB) @0.5 + ltx-2-19b-ic-lora-detailer (2.6GB) @0.4
|
@launch |
  exe:cd /home/saz/Projects/AI/ComfyUI && nohup ./.venv/bin/python ./main.py --use-ck-attention > /tmp/comfy_clean.log 2>&1 &
  on:ONLY --use-ck-attention (INT8 attention helps) - DROP --lowvram
  lowvramWorthless:--lowvram did not help; removes needed headroom
  textEncoderCPU:LTXAVTextEncoderLoader device=cpu (gemma 12B fp4 + projection) - keeps unet VRAM
  verify:curl -s http://127.0.0.1:8188/system_stats - argv should show ONLY --use-ck-attention
  logs:tail -f /tmp/comfy_clean.log
|
@workflow |
  graph:16 nodes - UnetLoaderGGUF -> 2x LoraLoaderModelOnly -> VAELoader + LTXAVTextEncoderLoader -> 2x CLIPTextEncode -> LTXVConditioning(25fps) -> EmptyLTXVLatentVideo -> LTXVScheduler(steps 8) -> KSamplerSelect(euler) + RandomNoise -> CFGGuider(cfg 1) -> SamplerCustomAdvanced -> VAEDecode -> VHS_VideoCombine(h264-mp4)
  node1Unet:UnetLoaderGGUF unet_name=ltx-2.3-22b-dev-Q3_K_M.gguf (the only model file to change to swap quant)
  framesRule:length must be 8n+1 (65=8x8+1, 121=8x15+1, 97, 33)
  vae:LTX23_video_vae_bf16.safetensors
|
@vramMap |
  768x512 x121:OOM at sampler step 2/8 (activations too big)
  768x512 x65:OOM at 6/8 (close - final ~576MiB alloc failed)
  512x320 x65:COMPLETE 8/8, 44s, 2.6s 65-frame h264 mp4 (458KB)
  cause:GGUF keeps quant unet resident then per-layer dequant BF16 buffer; LoRA-patch allocs (adaln_single) fail ~576MiB on fragmentation
  freeHint:allocated 10.7-11GiB but 'free 6.81MiB' = fragmented; lower res frees contiguous block
|
@runCmd |
  clearQueue:comfyui-community queue action=clear (drop stale failed jobs before retry)
  enqueue:comfyui-community enqueue_workflow action=enqueue (returns prompt_id)
  poll:comfyui-community queue action=status prompt_id=...
  logOOM:grep -E "Currently allocated|Requested|Got an OOM" /tmp/comfy_clean.log
  verifyMP4:comfyui-community get_image action=list_outputs pattern=ltx23
  probe:ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height,nb_frames,duration -of default=noprint_wrappers=1 file.mp4
|
@gotchas |
  loraStacking:never put distilled LORA on a distilled GGUF - double distillation
  quantWall:Q4_K_S (10.75GB resident) + 576MiB dequant buffer always OOM'd regardless of flags
  lowvramHurts:--lowvram freed nothing and removed headroom - normal mode better
  resIsTheLever:framed/resolution, not flags, is what finally fit 16GB (512x320x65 worked)
  textEncOnCPU:must keep gemma/projection on cpu or unet steals all VRAM
  seedFraming:seeds 42/1337/999 used across retries - each run reproducible by resubmitting same graph
  restartArgv:community restart_comfyui replays prior argv - manual nohup relaunch to change flags
|
@index |
  meta:@meta
  models:@models
  launch:@launch
  workflow:@workflow
  vram:@vramMap
  run:@runCmd
  pitfalls:@gotchas
|
