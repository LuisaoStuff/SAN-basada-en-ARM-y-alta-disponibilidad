# Instalación de las máquinas

## Revisión del hardware

Utilizaremos dos máquinas [Odroid-HC1](https://www.hardkernel.com/shop/odroid-hc1-home-cloud-one/), alimentadas por un [transformador](https://www.hardkernel.com/shop/5v-4a-power-supply-eu-plug-2/) de 5V/4A cada una, e instalaremos el sistema operativo en una _tarjeta microSD_ modelo [Sandisk Industrial 8Gb](https://www.mouser.com/datasheet/2/669/SanDisk_Industrial%20Grade%20SD%20%20MicroSD%20Product%20Brief-805940.pdf), además de dos latiguillos [ethernet Cat-5e](https://www.amazon.es/dp/B00BS9JXPA?ref=ppx_pop_mob_ap_share). Como disco duro para el almacenamiento en alta disponibilidad, usaremos dos discos _SSD_ [Kingston 128Gb](https://www.amazon.es/dp/B073VFG4C7/ref=cm_sw_r_wa_apap_LAsbMrtrxJSpL).

## Preparación de las tarjetas microSD

Al tratarse de una arquitectura distinta a **x86**, nos encontramos que el método de instalación del sistema operativo es también distinto. En **ARM** se realiza la instalación del SO en el disco duro principal previo a tu inserción en el equipo. Este proceso podemos realizarlo de dos formas; utilizando el paquete `dd` o usando uno de los múltiples binarios disponibles tanto para _windows_ como para _linux_, ya sean [Balenaetcher](https://www.balena.io/etcher/) o el recientemente lanzado [Raspberry Pi Imager](https://www.raspberrypi.org/downloads/).
En cuanto al sistema operativo, me he decantado por utilizar **Ubuntu 20.04.1 LTS** ya que es uno de los más actualizados y uno de los que tiene una comunidad más grande y es de los pocos que están escritos para 64bits, a diferencia de **Raspberry Pi OS** que está escrito en 32bits o **Debian ARM** que no tiene soporte oficial para la placa que voy a usar, y aún sigue en la versión **Stretch**.
Dicho esto, voy a utilizar la instalación vía `dd`, para hacerlo de una forma un poco más tradicional. Descargamos el fichero con la imagen desde el siguiente [enlace](https://wiki.odroid.com/odroid-xu4/os_images/linux/ubuntu_5.4/ubuntu_5.4). Obtendremos un fichero comprimido tipo **xz**, por lo que tendremos que instalar el paquete `xz-utils` para posteriormente poder usarlo con `tar`.
```
# Actualizamos la paquetería del sistema
apt update && apt upgrade -y
# Instalamos el paquete xz-utils
apt install xz-utils -y
# Descomprimimos el fichero
tar -xf ubuntu-20.04.1-5.4-minimal-odroid-xu4-20200812.img.xz
```
A continuación instalaremos la el fichero imagen en nuestra tarjeta sd:
```
dd bs=4M if=ubuntu-20.04.1-5.4-minimal-odroid-xu4-20200812.img of=/dev/sdb conv=fsync
```
Donde **ubuntu-20.04.1-5.4-minimal-odroid-xu4-20200812.img** sería el fichero imagen, y **/deb/sdb** sería el dispositivo de bloque, que en nuestro caso es la _tarjeta microSD_.
Repetiríamos el proceso para la segunda tarjeta.

## Montaje del equipo

La placa tiene un disipador pasivo de serie, que funcionará también como soporte del disco duro y "carcasa". Este sistema de fabricación está basado en el concepto de montaje de servidores en [Rack](https://es.wikipedia.org/wiki/Unidad_rack) ya que el propio disipador está diseñado para poder apilar múltiples unidades con la posibilidad de instalar ventiladores.

![](/recursos/img/montaje-odroid-hc1.jpg)

## Instalación y configuración de la paquetería

Una vez tenemos ya todo montado, empezamos a instalar los paquetes necesarios con `apt`.

`apt install pacemaker pcs drbd-utils tgt`

También vamos a declarar en el fichero `/etc/hosts` la resolución de ambas máquinas.

```
192.168.1.20	spongebob
192.168.1.21	patrick
```

Para la gestión de los distintos recursos y la creación del propio **cluster**, utilizaremos la herramienta `pcs`. Para crear dicho **cluster** ejecutaremos la siguiente linea:

```
# Autentificamos ambos nodos que pertenecerán al cluster
pcs host auth spongebob patrick -u hacluster -p *****

# Creamos el cluster con ambos nodos
pcs cluster setup storage spongebob patrick --start --enable --force
```

Ahora podemos comprobar que ambos _nodos_ están en linea ejecutando `pcs status`, orden que utilizaremos a lo largo del proceso para consultar la disponibilidad del **cluster** y de los distintos **recursos**.  

```
pcs status
Cluster name: storage
Cluster Summary:
  * Stack: corosync
  * Current DC: spongebob (version 2.0.3-4b1f869f0f) - partition with quorum
  * Last updated: Fri Oct 16 12:20:25 2020
  * Last change:  Thu Oct 15 14:54:13 2020 by root via cibadmin on spongebob
  * 2 nodes configured

Node List:
  * Online: [ patrick spongebob ]

Full List of Resources:

Daemon Status:
  corosync: active/enabled
  pacemaker: active/enabled
  pcsd: active/enabled
```

Antes de continuar vamos a crear y configurar el recurso de almacenamiento con el paquete `drbd-utils`. Para ello primero tendremos que crear el fichero de configuración que alojaremos en el directorio **/etc/drbd.d/** y guardaremos a ser posible con extensión **.res**. En mi caso lo llamaré **hadisk.res** y su contenido será el siguiente:

```
resource hadisk {
 protocol C;
 meta-disk internal;
 device /dev/drbd0;
 syncer {
  verify-alg sha1;
 }
 net {
  allow-two-primaries;
 }
 on spongebob {
  disk /dev/sda;
  address 192.168.1.20:7788;
  meta-disk internal;
 }
 on patrick {
  disk /dev/sda;
  address 192.168.1.21:7788;
  meta-disk internal;
 }
}
```

Una vez definido el recurso, lo creamos y levantamos con el comando `drbdadm`.

```
drbdadm create-md hadisk
drbdadm up hadisk
```

Como antes hemos indicado en el fichero que se permite que ambos sean el disco principal, tenemos que forzar que uno de ellos lo sea. Por lo que ejecutaremos esta instrucción en el nodo primario.

```
drbdadm primary --force hadisk
```

Después podremos consultar el estado de sincronización con `drbdadm status`. Observaremos que en la parte _inferior derecha_ del **prompt** hay un parámetro llamado **done** que nos indicará el porcentaje de sincronización, desde **0.0** hasta **100.0**.

```
~# drbdadm status hadisk
hadisk role:Primary
  disk:UpToDate
  peer role:Secondary
    replication:SyncSource peer-disk:Inconsistent done:1.86
```

Este proceso puede llevar un tiempo, así que debemos tener **paciencia**. Una vez terminado el proceso de sincronización, deberíamos obtener una salida como esta:

```
~# drbdadm status
hadisk role:Primary
  disk:UpToDate
```

Además podemos observar cómo tenemos un nuevo dispositivo de bloques en el sistema:

```
NAME        FSTYPE LABEL  UUID                                 FSAVAIL FSUSE% MOUNTPOINT
sda         drbd          a75999d68cb6aa5d
└─drbd0
mmcblk1
├─mmcblk1p1 vfat   boot   52AA-6867                             111.4M    13% /media/boot
└─mmcblk1p2 ext4   rootfs e139ce78-9841-40fe-8823-96a304a09859      5G    29% /
```

Una vez tenemos todo esto preparado, comenzamos a crear y configurar los **recursos** de **pacemaker**. Estos son **agentes** gestionados por **corosync** para que los paquetes en cuestión esten sincronizados entre los distintos nodos y puedan beneficiarse del cluster en si mismo. Entre otras cosas, necesitaremos una **IP virtual** para identificar al cluster, el recurso de **drbd** para que **pacemaker** pueda gestionarlo, 

--# Creo IP virtual para iscsi

pcs resource create iscsi-ip ocf:heartbeat:IPaddr1 ip=192.168.1.200 cidr_netmask=24 --group iscsi


--# Creo recurso drbd

pcs -f /root/cluster resource create HADISK ocf:linbit:drbd drbd_resource=hadisk
pcs -f /root/cluster resource promotable HADISK meta master-max=1 master-node-max=1 clone-max=2 clone-node-max=1 notify=true
pcs cluster cib-push /root/cluster


--# Creo recurso iscsi

rm -f /root/cluster
pcs cluster cib /root/cluster
pcs constraint order promote HADISK-clone then start iscsi id=iscsi-always-after-master-hadisk
pcs constraint colocation add iscsi with master HADISK-clone INFINITY id=iscsi-group-where-master-hadisk


--# Creo el target y los initiators permitidos, después añado la unidad lógica

rm -f /root/cluster
pcs cluster cib /root/cluster
pcs resource create iscsi-target ocf:heartbeat:iSCSITarget implementation="tgt" portals="192.168.1.200" iqn="iqn.2020-10.es.luisvazquezalejo:prueba" allowed_initiators="iqn.2020-10.es.luisvazquezalejo:prueba" tid="1"  --group iscsi
pcs resource create iscsi-lun1 ocf:heartbeat:iSCSILogicalUnit implementation="tgt" target_iqn=iqn.2020-10.es.luisvazquezalejo:prueba lun=1 path=/dev/drbd0 scsi_id="prueba.lun1" scsi_sn="1" --group iscsi
pcs cluster cib-push /root/cluster




--# Instalamos iscsi en el cliente

apt install open-iscsi

--# Comprobamos targets desde el cliente al cluster

iscsiadm -m discovery -t st -p 192.168.1.201

iscsiadm --mode node --targetname iqn.2020-10.es.luisvazquezalejo:prueba --portal 192.168.1.200:3260






pcs resource create iscsi-target ocf:heartbeat:iSCSITarget implementation="tgt" portals="192.168.1.200" iqn="iqn.2020-10.es.luisvazquezalejo:prueba" allowed_initiators="192.168.1.39 192.168.1.43" tid="1"  --group iscsi









pcs resource create iscsi-target ocf:heartbeat:iSCSITarget implementation="tgt" portals="192.168.1.200" iqn="iqn.2020-10.es.luisvazquezalejo:prueba" tid="1" --group iscsi






cp -r /etc/skel/Maildir /mail/
chown -R mail:mail /mail/Maildir
chmod -R 700 /mail/Maildir
adduser mail mail