# SSH Knowledge Base
@meta |topic:ssh|lastUpdated:2026-08-17|confidence:high|
@basics |
  config:~/.ssh/config
  keyDir:~/.ssh/
  knownHosts:~/.ssh/known_hosts
  defaultPort:22
  protocol:SSH-2
  daemon:sshd (server), ssh (client)
|
@connection |
  basic:ssh user@host
  port:ssh -p 2222 user@host
  key:ssh -i ~/.ssh/my_key user@host
  verbose:ssh -vvv user@host
  batchMode:ssh -o BatchMode=yes user@host
  connectTimeout:ssh -o ConnectTimeout=10 user@host
|
@config |
  host:Host myserver
  hostname:HostName 192.168.1.100
  user:User deploy
  port:Port 2222
  identityFile:IdentityFile ~/.ssh/my_key
  forwardAgent:ForwardAgent yes
  forwardX11:ForwardX11 yes
  compression:Compression yes
  serverAlive:ServerAliveInterval 60
  serverCount:ServerAliveCountMax 3
  strictHostKey:StrictHostKeyChecking ask
  userKnownHosts:UserKnownHostsFile ~/.ssh/known_hosts
|
@keygen |
  ed25519:ssh-keygen -t ed25519 -C "email@example.com"
  rsa:ssh-keygen -t rsa -b 4096 -C "email@example.com"
  noPassphrase:ssh-keygen -t ed25519 -N ""
  changePass:ssh-keygen -p -f ~/.ssh/id_ed25519
  fingerprint:ssh-keygen -lf ~/.ssh/id_ed25519.pub
  convertPub:ssh-keygen -f key -e -m PEM
|
@keyManagement |
  copyId:ssh-copy-id -i ~/.ssh/id_ed25519.pub user@host
  copyIdPort:ssh-copy-id -i ~/.ssh/id_ed25519.pub -p 2222 user@host
  listKeys:ls -la ~/.ssh/
  changePerm:chmod 700 ~/.ssh && chmod 600 ~/.ssh/*
  agentStart:eval "$(ssh-agent -s)"
  agentAdd:ssh-add ~/.ssh/id_ed25519
  agentList:ssh-add -l
  agentDelete:ssh-add -D
  agentForward:ForwardAgent yes in config
|
@tunneling |
  local:ssh -L 8080:localhost:80 user@host
  localExplain:access host:80 via localhost:8080
  remote:ssh -R 9090:localhost:3000 user@host
  remoteExplain:expose local:3000 to host:9090
  dynamic:ssh -D 1080 user@host
  dynamicExplain:SOCKS5 proxy on localhost:1080
  jump:ssh -J jumphost user@target
  jumpExplain:route through bastion to target
  multiJump:ssh -J jump1,jump2 user@target
|
@proxyCommand |
  proxyCommand:ProxyCommand ssh -W %h:%p jumphost
  example:Host target
  example2:HostName 10.0.0.5
  example3:ProxyCommand ssh -W %h:%p bastion
  netcat:ProxyCommand nc -X connect -x proxy:port %h %p
|
@fileTransfer |
  upload:ssh user@host "cat > /path/file" < localfile
  download:ssh user@host "cat /path/file" > localfile
  scpFile:scp file.txt user@host:/path/
  scpDir:scp -r dir/ user@host:/path/
  scpPort:scp -P 2222 file.txt user@host:/path/
  rsync:rsync -avz -e ssh dir/ user@host:/path/
  rsyncDelete:rsync -avz --delete dir/ user@host:/path/
  rsyncExclude:rsync -avz --exclude='node_modules' dir/ user@host:/path/
|
@multiplexing |
  master:ssh -M -S /tmp/ssh-socket user@host
  control:ssh -S /tmp/ssh-socket user@host
  close:ssh -S /tmp/ssh-socket -O exit user@host
  config:ControlMaster auto
  config2:ControlPath ~/.ssh/sockets/%r@%h-%p
  config3:ControlPersist 10m
|
@agents |
  forward:ssh -A user@host
  forwardConfig:ForwardAgent yes
  agentSock:SSH_AUTH_SOCK
  listIdentities:ssh-add -L
  remove:ssh-add -D
  ephemeral:ssh -A user@host "ssh-add -l && command"
|
@security |
  disablePassword:PasswordAuthentication no
  disableRoot:PermitRootLogin no
  keyOnly:PubkeyAuthentication yes
  allowUsers:AllowUsers deploy admin
  maxAuthTries:MaxAuthTries 3
  clientAlive:ClientAliveInterval 300
  clientCount:ClientAliveCountMax 2
  banner:Banner /etc/ssh/banner
  logLevel:LogLevel VERBOSE
  protocol2:Protocol 2
|
@debugging |
  verbose1:ssh -v user@host
  verbose2:ssh -vv user@host
  verbose3:ssh -vvv user@host
  checkConfig:ssh -T user@host
  testConnection:ssh -o ConnectTimeout=5 user@host echo ok
  auditConfig:ssh-audit host
|
@gotchas |
  hostKey:manually add to known_hosts
  hostKeyFix:ssh-keyscan host >> ~/.ssh/known_hosts
  permError:Bad permissions on key files
  permFix:chmod 600 ~/.ssh/id_* && chmod 644 ~/.ssh/*.pub
  agentForward:ensure ForwardAgent yes in config
  jumpHost:need ProxyCommand for bastion
  portConflict:multiple services on 22
  timeoutFirewall:connection drops behind NAT
  readOnlyKey:use -C "comment" to identify keys
  keyNotFound:check ssh-add -l for loaded keys
|
@run keySetup |
  1.cmd:ssh-keygen -t ed25519 -C "$EMAIL" -f ~/.ssh/id_ed25519 -N ""
  1.onFail:key may already exist — use existing or specify different path
  2.cmd:eval "$(ssh-agent -s)"
  3.cmd:ssh-add ~/.ssh/id_ed25519
  4.cmd:ssh-copy-id -i ~/.ssh/id_ed25519.pub $USER@$HOST
  4.onFail:copy failed — check host accessibility and password auth
  5.cmd:ssh -o ConnectTimeout=5 $USER@$HOST echo ok
  5.expect:ok
  5.onFail:connection failed — check firewall, port, host key
|
@run tunnelLocal |
  1.cmd:ssh -L $LOCAL_PORT:$TARGET_HOST:$TARGET_PORT $USER@$JUMP_HOST -N -f
  1.note:background tunnel, access via localhost:$LOCAL_PORT
  2.cmd:curl -s http://localhost:$LOCAL_PORT
  2.onFail:tunnel not working — check jump host connectivity
|
@run deployKey |
  1.cmd:ssh-keygen -t ed25519 -C "deploy@$(hostname)" -f ~/.ssh/deploy_key -N ""
  2.cmd:cat ~/.ssh/deploy_key.pub
  2.note:add this public key to target server's authorized_keys
  3.cmd:ssh -i ~/.ssh/deploy_key -o ConnectTimeout=5 $USER@$HOST echo ok
  3.expect:ok
  3.onFail:deploy key auth failed — check server-side permissions
  4.cmd:chmod 600 ~/.ssh/deploy_key
|
