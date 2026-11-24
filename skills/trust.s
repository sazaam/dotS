@meta |topic:dotS run trust skill allowlist and hashes|versions:1|confidence:verified|lastUpdated:2026-11-24|
@runTrust |
  rule:execute only exact paths with matching sha256 in ~/.config/dots/skills/.safe
  local:user-owned private skills/*.local.s under the real-home trust root are implicitly trusted
  localCheck:owner must match uid; trust root skills dir and file must not be group/world-writable
  denied:remote URLs external repos symlink escapes run aliases unknown commands
  readOnly:untrusted .s may be read or --dry-run previewed never executed
  hashes:skills/.safe entries are <path> sha256:<hex>; any edit invalidates the hash
  risk:run uses shell=True - a malicious @run.cmd is arbitrary code
  force:--force bypasses trust/hash risk review only; it never bypasses the run allowlist
|
@api |
  trust:dots trust <skill> [skill ...] hashes current content into skills/.safe
  untrust:dots untrust <skill> [skill ...] removes an entry
  trusted:dots trusted lists hashed and implicitly trusted local skills
  hash:dots hash shows matching mismatched untrusted local and missing entries
  refresh:dots hash --refresh updates stale hashes of already-trusted skills
  newSkills:new skills require explicit dots trust; --refresh never auto-trusts
  forms:comma separated names work too - dots trust git,nginx
  force:dots trust <skill> --force and dots hash --refresh --force accept reviewed risky steps
|
@safety |
  scope:trust and hash --refresh scan @run and @run.* steps before writing skills/.safe
  highSignal:curl/wget piped to sh, rm -rf / or ~, mkfs, dd to /dev, sudo/su
  writes:/etc/sudoers, ~/.ssh/authorized_keys, shell rc files, /etc/systemd/system, crontab
  git:push --force, reset --hard, clean -fdx
  behavior:print each offending @run block step and reason then refuse without --force
  limit:heuristic speed bump not a sandbox; hashes and exact paths are the real control
  refresh:a trusted skill edited into risky steps is blocked until explicitly forced
|
@commit |
  atomic:commit the skill and skills/.safe together so hashes match at that revision
  review:skills/.safe is a reviewable trust decision not a generated artifact
  local:skills/*.local.s is gitignored so local-only trust needs no commit
  revoke:dots untrust <skill> or delete the local file
|
@index |
  sections:runTrust api safety commit
  format:compact key:value .s block format
|
