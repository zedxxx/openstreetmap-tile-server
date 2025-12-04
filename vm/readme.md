## Install VMware virtual machine

1. Download and install [VMWare Workstation Pro](https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion)
2. Create new virtual machine: Linux - Other Linux 6.x kernel 64-bit
3. Hardware:
   1. CPU: 8 cores (4 processors with 2 cores per processor), Enable all 3 options under Virtualization Engine
   2. RAM: 16 GB
   3. HDD: 1 GB (system)
   4. Network: Bridged
4. Edit VM settings:
   1. Add second HDD: 1000 GB (data)
   2. (Optional) Add third HDD: 16 GB (swap)
   3. VMWare Tools: Enable option "Synchronize guest time with host"

## Install Alpine Linux

1. Download [iso image](https://alpinelinux.org/downloads/) Virtual edition (x86_64 version)
2. Login: root (when you boot from iso a password isn't required)
3. Install: `SWAP_SIZE=0 setup-alpine` (without swap)
4. All by default, except:
    1. Keymap: us us
    2. Root Password: alpine
    3. Apk Mirror: c (enable community repository)
    4. User - Allow root ssh login: yes (enable ssh, sftp login by password for root)
    5. Disk & Install: sda sys
5. (Optional) If you don't have enough RAM you can use third HDD for [swap](https://wiki.alpinelinux.org/wiki/Swap)

## Setup Alpine Linux

1. Connect to the VM via SSH using [PuTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html). You can find the VM's IP address in the boot log on the VM screen.
2. Create `fetch` script:

```bash
cat > fetch.sh << EOL
#!/bin/sh
set -euox pipefail
wget -O master.zip https://github.com/zedxxx/osm-tile-server/archive/refs/heads/master.zip
unzip -o master.zip && rm -fv master.zip
rm -rfv /osm/
mv -fv ./osm-tile-server-master/ /osm/
chmod a+x /osm/vm/alpine-setup.sh
EOL
```

3. Run `fetch` script: `chmod +x ./fetch.sh && ./fetch.sh`
4. Run `alpine-setup` script: `cd /osm/vm && ./alpine-setup.sh`
