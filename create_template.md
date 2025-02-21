## Instalar libguest para aidionar qemu-agent na imagem
```
apt install libguestfs-tools -y
```

## Adicionando o qemu-guest-agent na imagem
```
virt-customize --add jammy-server-cloudimg-amd64.img \
 --install qemu-guest-agent
```

## Criando vm com id 9001
```
qm create 9001 \
 --name ubuntu-2204-cloud-init \
 --numa 0 \
 --ostype l26 \
  --cpu cputype=host \
  --cores 4 \
  --sockets 2 \
  --memory 6144 \
  --net0 virtio,bridge=vmbr0
```

## Network
### Bridge
bridge --> vmbr0,vmbr1,...
### VLAN
tag --> 10,11,12,...

## Jogando imagem alterada para a VM
```
qm importdisk 9001 /tmp/jammy-server-cloudimg-amd64.img local-lvm
```

## Criando disco scsi na storage local-lvm
```
qm set 9001 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9001-disk-0
```

## Criando disco do cloudinit
```
qm set 9001 --ide2 local-lvm:cloudinit
```

## Setando boot para o disco 0
```
qm set 9001 --boot c --bootdisk scsi0
```

## Setando monitor para visualizar pelo qemu console
```
qm set 9001 --serial0 socket --vga serial0
```

## Habilitando o agente qemu
```
qm set 9001 --agent enabled=1
```

## Redimensionando o disco para 35G
```
qm disk resize 9001 scsi0 +35G
```

## Apontando o caminho do arquivo de configuração do cloudinit
O arquivo deve está na storage local para esse comando. Entrar na maquina e adicionar o arquivo no /var/lib/vz/snippets
```
qm set 9001 --cicustom "vendor=local:snippets/vendor.yaml"
```
## Transformando a VM em template
```
qm template 9001
```