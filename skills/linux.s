# Linux Knowledge Base

@meta |topic:linux|lastUpdated:2026-08-17|confidence:high|

@basics |
  shell:zsh (default on macOS), bash
  packageManager:apt (Debian/Ubuntu), dnf (Fedora), pacman (Arch)
  initSystem:systemd (modern), sysvinit (legacy)
  filesystem:/ (root), /home, /etc, /var, /tmp
  user:whoami, id, groups
|

@fileOperations |
  list:ls -la
  listTree:tree -L 2
  find:find . -name "*.js" -type f
  findLarge:find . -size +100M
  findRecent:find . -mtime -1
  grep:grep -rn "pattern" .
  ripgrep:rg "pattern" .
  sed:sed -i 's/old/new/g' file
  awk:awk '{print $1}' file
  sort:sort -n file
  uniq:sort file | uniq -c | sort -rn
  wc:wc -l file
  head:head -n 20 file
  tail:tail -n 20 file
  tailFollow:tail -f /var/log/syslog
  cut:cut -d',' -f1 file
  paste:paste -d',' file1 file2
  tr:tr 'a-z' 'A-Z' < file
  xargs:find . -name "*.log" | xargs rm
  parallel:xargs -P 4 -I {} command {}
|

@filePermissions |
  chmod755:chmod 755 dir/
  chmod644:chmod 644 file
  chmod600:chmod 600 ~/.ssh/id_*
  chown:chown user:group file
  chownRecursive:chown -R user:group dir/
  setgid:chmod g+s dir/ (inherit group)
  stickyBit:chmod +t /tmp (prevent deletion)
  umask:umask 022 (default permissions)
|

@processes |
  list:ps aux
  listTree:ps auxf
  byName:ps aux | grep name
  kill:kill PID
  forceKill:kill -9 PID
  killByName:killall name
  killByPattern:pkill pattern
  nice:nice -n 10 command
  renice:renice -n 10 -p PID
  nohup:nohup command &
  background:command &
  foreground:fg
  jobs:jobs -l
  top:top -bn1 | head -20
  htop:htop
  pidof:pidof process
  lsof:lsof -i :8080
|

@systemd |
  status:systemctl status service
  start:systemctl start service
  stop:systemctl stop service
  restart:systemctl restart service
  enable:systemctl enable service
  disable:systemctl disable service
  listFailed:systemctl --failed
  logs:journalctl -u service
  logsFollow:journalctl -u service -f
  logsSince:journalctl -u service --since "1 hour ago"
  daemonReload:systemctl daemon-reload
  edit:systemctl edit service
|

@networking |
  ipAddr:ip addr show
  ipRoute:ip route show
  ipLink:ip link show
  ports:ss -tlnp
  portsUDP:ss -ulnp
  connections:ss -tnp
  dns:dig example.com
  dnsShort:nslookup example.com
  ping:ping -c 4 host
  traceroute:traceroute host
  curl:curl -I https://example.com
  wget:wget -qO- https://example.com
  ifaceUp:ip link set eth0 up
  ifaceDown:ip link set eth0 down
  staticIP:ip addr add 192.168.1.100/24 dev eth0
  gateway:ip route add default via 192.168.1.1
|

@disk |
  usage:df -h
  usageDir:du -sh dir/
  usageSub:du -sh dir/*/
  inode:df -i
  mount:mount | column -t
  unmount:umount /mnt/point
  lsblk:lsblk -f
  fdisk:fdisk -l
  smartctl:smartctl -a /dev/sda
  temp:ncdu /
|

@memory |
  free:free -h
  vmstat:vmstat 1 5
  sar:sar -r 1 5
  oom:grep -i "out of memory" /var/log/syslog
  swap:swapon --show
  addSwap:dd if=/dev/zero of=/swapfile bs=1M count=1024 && mkswap /swapfile && chmod 600 /swapfile && swapon /swapfile
|

@cron |
  edit:crontab -e
  list:crontab -l
  format:min hour day month weekday command
  everyMin:* * * * * command
  everyHour:0 * * * * command
  daily:0 2 * * * command
  weekly:0 2 * * 0 command
  monthly:0 2 1 * * command
  reboot:@reboot command
|

@logAnalysis |
  syslog:tail -f /var/log/syslog
  auth:tail -f /var/log/auth.log
  kern:dmesg | tail -50
  journal:journalctl -f
  journalUnit:journalctl -u nginx
  journalSince:journalctl --since "2026-08-17"
  errors:journalctl -p err -b
  audit:ausearch -m LOGIN --start today
  lastLog:last -n 20
  failedLog:faillog -r
|

@compression |
  tarGzip:tar -czf archive.tar.gz dir/
  tarExtract:tar -xzf archive.tar.gz
  tarBzip:tar -cjf archive.tar.bz2 dir/
  zip:zip -r archive.zip dir/
  unzip:unzip archive.zip
  gzip:gzip file
  gunzip:gunzip file.gz
  zcat:zcat file.gz | less
|

@users |
  addUser:adduser username
  deleteUser:userdel username
  addGroup:groupadd groupname
  userGroup:usermod -aG groupname username
  sudoers:visudo
  sudoConfig:username ALL=(ALL:ALL) ALL
  passwd:passwd username
  last:last -n 20
  who:who
  w:w
|

@firewall |
  ufwStatus:ufw status verbose
  ufwAllow:ufw allow 80/tcp
  ufwDeny:ufw deny 22/tcp
  ufwEnable:ufw enable
  iptables:iptables -L -n
  iptablesBlock:iptables -A INPUT -s IP -j DROP
  firewalld:firewall-cmd --list-all
  firewalldAdd:firewall-cmd --add-port=8080/tcp --permanent
|

@sshServer |
  config:/etc/ssh/sshd_config
  restart:systemctl restart sshd
  keyGen:ssh-keygen -t ed25519
  harden:PasswordAuthentication no
  harden2:PermitRootLogin no
  harden3:MaxAuthTries 3
|

@gotchas |
  symlink:ln -s target link_name
  readlink:readlink -f link_name
  unlink:unlink link_name
  inode:ls -i file (find same inode)
  diskFull:df -h → du -sh /* | sort -rh | head
  permDenied:check ls -la, chmod, chown
  noSpace:df -h, then find large files
  zombie:ps aux | grep Z
  zombieFix:kill parent process
  oom:check /var/log/syslog for OOM killer
  noRoute:ip route show, ping gateway
  dnsFail:cat /etc/resolv.conf
|

@run diskCleanup |
  1.cmd:df -h /
  1.note:check current disk usage
  2.cmd:du -sh /* 2>/dev/null | sort -rh | head -10
  2.note:find largest top-level directories
  3.cmd:journalctl --vacuum-time=7d
  3.note:trim systemd journal to last 7 days
  4.cmd:docker system prune -a --force 2>/dev/null
  4.note:remove unused Docker resources if docker installed
  5.cmd:apt-get autoremove -y 2>/dev/null
  5.note:remove unused packages if debian-based
  6.cmd:df -h /
  6.note:verify space reclaimed
|

@run logRotate |
  1.cmd:du -sh /var/log/*
  1.note:identify largest log files
  2.cmd:truncate -s 0 /var/log/*.log
  2.note:truncate log files without restarting services
  3.cmd:journalctl --vacuum-size=500M
  3.note:limit journal to 500MB
  4.cmd:logrotate -f /etc/logrotate.conf
  4.note:force logrotate to run now
|

@run processAudit |
  1.cmd:ps aux --sort=-%mem | head -15
  1.note:top memory consumers
  2.cmd:ps aux --sort=-%cpu | head -15
  2.note:top CPU consumers
  3.cmd:ss -tlnp
  3.note:all listening ports
  4.cmd:systemctl list-units --type=service --state=failed
  4.note:failed systemd services
  5.cmd:dmesg | tail -20
  5.note:recent kernel messages
|

@run securityCheck |
  1.cmd:last -n 20
  1.note:recent logins
  2.cmd:faillog -r
  2.note:failed login attempts
  3.cmd:ss -tlnp
  3.note:exposed ports
  4.cmd:ufw status verbose 2>/dev/null || iptables -L -n
  4.note:firewall rules
  5.cmd:find / -perm -4000 -type f 2>/dev/null
  5.note:SUID binaries (potential escalation vectors)
|

@run serverSetup |
  1.cmd:hostnamectl set-hostname $HOSTNAME
  2.cmd:timedatectl set-timezone $TIMEZONE
  3.cmd:apt update && apt upgrade -y
  3.note:update packages if debian-based
  4.cmd:ufw allow 22/tcp && ufw allow 80/tcp && ufw allow 443/tcp
  4.note:open essential ports
  5.cmd:ufw enable
  6.cmd:systemctl enable ssh
  7.cmd:reboot
  7.note:apply kernel updates
|
