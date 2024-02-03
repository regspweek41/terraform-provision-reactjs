#!/bin/bash
        /usr/sbin/useradd ansibletest
        echo "ansibletest        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/ansibletest
        /usr/bin/mkdir /home/ansibletest/.ssh
        /usr/bin/chown ansibletest:ansibletest /home/ansibletest/.ssh
        /usr/bin/chmod 700 /home/ansibletest/.ssh
        echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDFqiwFoR8QqLGrPywu/LOrbtVvnJORdsXo/woO0uXxzujehFJvdw9cF0rSg0MxJvPt/eFVabxy2B+rkw+Z9XXiWbeRH5rVEuh2HDgmvFOcjggBF9L3pgj4LgrEZ1bMULZZvTLoXeFSNzaOh9A6DmfdvpqjuaZI5ok9Z7d2Q+8Z/j4OEqWoyFOz+xZcoWos2T52VzyRxfgCQcC+scLFWXEocf1V6W+3kyBSgq0Lv36T/GD/a6pi2T24WXtVQMSvfLkKT41bw9nFSgp4TTZykQdS6Jza0j/kxcAnbTlJ54rdEYcRE6cGfcm6YOA6138K3nzzHZWwalKNJZxfkrIaV8ES889wm1BbeMT4ys6hxwQQH8aJZ/dlRMoNmJ5vDNhTVr6kyyaYkObNU3LOa+GhYOao9Bu4kJOyMsLuLjSSz6+z59lYdtTajoWqU47ggsTVNnYt7/ckraiwKZVENuTx+lg/tBG7lj+ldMtThdawpHWdhK+qzv/ArMivRfBRVrLVNVs= azureuser@multitenant-uat-zp-vm" >> /home/ansibletest/.ssh/authorized_keys
        /usr/bin/chmod 600 /home/ansibletest/.ssh/authorized_keys
        /usr/bin/chown ansibletest:ansibletest /home/ansibletest/.ssh/authorized_keys