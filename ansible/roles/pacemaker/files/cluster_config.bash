#!/bin/bash

pcs property set stonith-enabled=false
# Creamos IP Virtual
pcs resource create iscsi-ip ocf:heartbeat:IPaddr ip=192.168.1.200 cidr_netmask=24 --group iscsi
# Creamos recurso DRBD
pcs resource create HADISK ocf:linbit:drbd drbd_resource=hadisk
pcs resource promotable HADISK meta master-max=1 master-node-max=1 clone-max=2 clone-node-max=1 notify=true
# Configuramos recurso DRBD con target ISCSI
pcs constraint order promote HADISK-clone then start iscsi id=iscsi-always-after-master-hadisk
pcs constraint colocation add iscsi with master HADISK-clone INFINITY id=iscsi-group-where-master-hadisk
# Creamos target ISCSI
pcs resource create iscsi-target ocf:heartbeat:iSCSITarget implementation="tgt" portals="192.168.1.200" iqn="iqn.2020-10.es.luisvazquezalejo:prueba" allowed_initiators="192.168.1.39 192.168.1.43 192.168.1.15" tid="1"  --group iscsi
# Creamos LUN1
pcs resource create iscsi-lun1 ocf:heartbeat:iSCSILogicalUnit implementation="tgt" target_iqn=iqn.2020-10.es.luisvazquezalejo:prueba lun=1 path=/dev/drbd0 scsi_id="prueba.lun1" scsi_sn="1" --group iscsi
