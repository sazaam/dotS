# Server Setup & Hardening
@meta |
  topic:server-setup vps hardening fail2ban firewall deploy keys
  versions:1.0
  confidence:high
  lastUpdated:2026-09-22
|
@dependencies |
  requires:index.s
  related:skills/ssh.s skills/linux.s
|
@core |
  purpose:harden a fresh Linux VPS before real workloads land
  usage:load when provisioning a new server or auditing security posture
  stance:stop the scan noise, then enforce keys - ordering matters, see @run.harden
  cli:dots get skills/server-setup.s @sshHarden
  loadAll:dots get skills/server-setup.s
|
@sshHarden |
  port:pick a non-default port (1024-49151) and set Port in /etc/ssh/sshd_config.d/*.conf
  portReason:cuts automated port-22 scan noise; keys remain the real gate
  keyOnly:PubkeyAuthentication yes
  noPassword:PasswordAuthentication no
  noKbd:KbdInteractiveAuthentication no
  rootLogin:PermitRootLogin prohibit-password (no if root-over-ssh is never needed)
  maxTries:MaxAuthTries 3
  clientAlive:ClientAliveInterval 300 ClientAliveCountMax 2
  logLevel:LogLevel VERBOSE
  allowUsers:AllowUsers <login-user> whitelists who may even attempt a login
  onlyAfter:flip auth options only once a key login is verified (see @users, @verify)
|
@users |
  create:sudo adduser <name> then sudo usermod -aG sudo <name>
  purpose:non-root daily user with sudo; root reserved for emergencies
  escalate:sudo -i for the rare admin task, not everyday work
  pubkey:mkdir -p ~/.ssh && chmod 700 ~/.ssh
  authKeys:authorized_keys chmod 600
  copyId:ssh-copy-id -p <port> -i ~/.ssh/<key>.pub <user>@<host> from another machine
|
@firewall |
  beforeSshd:open the new ssh port on the firewall BEFORE changing sshd Port
  ufw:ufw default deny incoming; ufw allow <port>/tcp; ufw enable
  nft:nftables also fine - drop policy on input
  verify:ufw status verbose (or nft list ruleset) shows the port open
|
@fail2ban |
  install:apt install fail2ban
  jail:enable an sshd jail in /etc/fail2ban/jail.local
  banAction:banaction = iptables-multiport and banaction_allports = DROP
  banWhy:REJECT answers a scanner; DROP stays silent - prefer DROP on ssh
  maxretry:raise maxretry for interactive users (10 is a sane default)
  findtime:10m window pairs with the retry budget
  bantime:24h+ is comfortable once bans are silent DROPs
  ignoreip:whitelist only your own known egress IPs, never broad ranges
  check:fail2ban-client status sshd
  log:/var/log/fail2ban.log after restart
|
@gitKeys |
  purpose:dedicated passphrase-protected ed25519 pair for git hosting (github.com, gitlab)
  whySeparate:never reuse server auth keys for git - scope and revoke each independently
  gen:ssh-keygen -t ed25519 -C "<comment>" -f ~/.ssh/<key-name>
  agent:eval "$(ssh-agent -s)" && ssh-add ~/.ssh/<key-name>
  config:Host github.com / HostName github.com / IdentityFile ~/.ssh/<key-name> / AddKeysToAgent yes
  upload:add the .pub to the host's deploy-key settings (read-only scope for clone/CI pulls)
  test:ssh -T git@github.com -> "Hi <user>!" with exit code 1 is success
  nonInteractive:no tty (cron/systemd) -> SSH_ASKPASS + setsid; never embed a passphrase in a script
  perms:chmod 600 private key; 644 .pub
|
@verify |
  sshdSyntax:sshd -t before any reload
  fromElsewhere:ssh -p <port> -o BatchMode=yes user@host echo ok, from a second machine
  gitReach:ssh -T git@github.com (see @gitKeys)
  banCheck:fail2ban-client status sshd
  logCheck:journalctl -u ssh --no-pager -n 10
|
@gotchas |
  lockout:never close the only live session right after editing sshd - keep a spare
  firewallOrder:port change without opening the firewall = instant lockout
  rootLockout:disabling root/PW auth before the new user's key works = locked out
  cloudInit:provider metadata can re-apply a hostname on reboot; preserve_hostname:true in /etc/cloud/cloud.cfg if you rename
  manageHosts:cloud images regenerate /etc/hosts (manage_etc_hosts) - patch the cloud template for edits that persist
  fingerprinting:scanners find ssh on any port; DROP ban-action is still the right posture
  sshAgent:keys vanish with the agent - AddKeysToAgent yes, ForwardAgent off unless needed
|
@run harden |
  1.cmd:verify key login from a spare session first: ssh -p <port> -o BatchMode=yes user@host echo ok
  1.onFail:finish key deployment (@users @gitKeys) before touching sshd
  2.cmd:open the firewall port first: ufw allow <port>/tcp
  3.cmd:edit sshd config -> Port, PubkeyAuthentication yes, PasswordAuthentication no, PermitRootLogin, AllowUsers
  4.cmd:sshd -t && systemctl reload ssh
  5.cmd:verify from a NEW session on the new port: echo ok
  5.onFail:revert sshd config from the spare session
  6.cmd:install fail2ban; sshd jail; banaction DROP; maxretry 10; findtime 10m
  7.cmd:fail2ban-client status sshd
  7.expect:Banned IP list populated after deliberate bad logins
  done:old port closed, new port answers from the outside
|
@index |
  start:dots get skills/server-setup.s @core
  harden:dots get skills/server-setup.s @sshHarden @firewall @fail2ban
  keys:dots get skills/server-setup.s @gitKeys @users
  verify:dots get skills/server-setup.s @verify
  gotchas:dots get skills/server-setup.s @gotchas
  playbook:dots run skills/server-setup.s @run.harden
|
