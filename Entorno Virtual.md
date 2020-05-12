# Desarrollo en entorno virtual

Debido a la situación de confinamiento por **COVID-19**, tendré que empezar a realizar pruebas con máquinas virtuales. Entre todas las posibles soluciones me decanto por el uso de [QEMU](https://www.qemu.org/) para la emulación de una máquina con un procesador  [arm1176](https://en.wikipedia.org/wiki/ARM11) y posterior instalación del sistema operativo **Raspbian**.

## Preparación del escenario

Comenzamos instalando una serie de paquetes y dependencias que nos serán necesarias para dicha emulación.

```
apt update
apt install libpixman-1-dev zlib1g-dev libglib2.0-dev shtool build-essential qemu-system-arm
```

También procederemos a la creación de una interfaz de tipo _tap_ conectada a una interfaz puente (**br0**) para permitir el acceso a la **SAN** desde los distintos dispositivos de la red.
Tal y como nos explican en la entrada [KVM “a pelo”](https://albertomolina.wordpress.com/2016/03/17/kvm-a-pelo/) tendremos que definir en el fichero **/etc/network/interfaces** una interfaz de tipo **bridge**, donde especificaremos a qué interfaz física estará conectada. En mi caso estará definido de este modo:

```
# The loopback network interface
auto lo
iface lo inet loopback

auto eno1
allow-hotplug eno1
    iface eno1 inet dhcp

auto wlo1
allow-hotplug wlo1
       iface wlo1 inet dhcp

auto br0
iface br0 inet dhcp
        bridge_ports eno1
```

Donde **eno1** es mi dispositivo _ethernet_ y **br0** es la interfaz puente. Una vez hemos modificado el fichero correctamente, levantamos la interfaz con la orden `ifup`:

```
~# ifup br0

Waiting for br0 to get ready (MAXWAIT is 32 seconds).
Internet Systems Consortium DHCP Client 4.4.1
Copyright 2004-2018 Internet Systems Consortium.
All rights reserved.
For info, please visit https://www.isc.org/software/dhcp/

Listening on LPF/br0/98:e7:f4:5f:dd:5d
Sending on   LPF/br0/98:e7:f4:5f:dd:5d
Sending on   Socket/fallback
DHCPDISCOVER on br0 to 255.255.255.255 port 67 interval 5
DHCPOFFER of 192.168.1.44 from 192.168.1.1
DHCPREQUEST for 192.168.1.44 on br0 to 255.255.255.255 port 67
DHCPACK of 192.168.1.44 from 192.168.1.1
bound to 192.168.1.44 -- renewal in 17202 seconds.
```

Después procedemos a crear las dos interfaces tap que tendrán nuestras máquinas.

```
# Creamos las interfaces tap
~# ip tuntap add mode tap user luis
~# ip tuntap add mode tap user luis

# Comprobamos que se han creado
~# ip tuntap list
tap0: tap persist user 1000
tap1: tap persist user 1000

# Las conectamos al puente br0
~# brctl addif br0 tap0
~# brctl addif br0 tap1

# Y habilitamos las interfaces
ip l set dev tap0 up
ip l set dev tap1 up
```

Con esto ya tendríamos preparadas las dos interfaces de red y solo nos quedaría generar una dirección **MAC** aleatoria para cada una, aunque esto lo haremos en el momento de iniciar ambas máquinas con _qemu_.

## Creación de las máquinas

Para poder emular una maquina arm, necesitaremos un **kernel** modificado y la correspondiente imagen de [Raspbian Buster](https://www.raspberrypi.org/blog/buster-the-new-version-of-raspbian/). La imagen del kernel modificada la obtendremos de este [repositorio](https://github.com/dhruvvyas90/qemu-rpi-kernel). En mi caso descargaré los ficheros [kernel-qemu-4.19.50-buster](https://github.com/dhruvvyas90/qemu-rpi-kernel/raw/master/kernel-qemu-4.19.50-buster) y [versatile-pb-buster.dtb](https://github.com/dhruvvyas90/qemu-rpi-kernel/raw/master/versatile-pb-buster.dtb). La imagen del sistema operativo la descargaré de la propia página de [raspberry.org](https://www.raspberrypi.org/downloads/raspbian/).
Primero descomprimimos el fichero **zip** contenedor de la imagen de _raspbian buster_ y una vez hecho esto, la convertiremos a **qcow2** y extenderemos un poco su tamaño:

```
# Descomprimimos el fichero
unzip 2020-02-13-raspbian-buster-lite.zip

# Cambiamos el formato
qemu-img convert -f raw -O qcow2 2020-02-13-raspbian-buster-lite.img raspbian-buster.qcow2

# Extendemos el tamaño del volumen
qemu-img resize raspbian-buster.qcow2 +10G
```

Con la imagen **qcow2** lista, vamos a aprovechar una característica de este tipo de ficheros, que es el [aprovisionamiento ligero](https://wiki.qemu.org/images/4/45/Devconf14-bonzini-thin-provisioning.pdf) y crearemos _2 imágenes_ a partir de la **original**.

```
~# qemu-img create -b raspbian-buster.qcow2 -f qcow2 raspbian-buster-1.qcow2 
Formatting 'raspbian-buster-1.qcow2', fmt=qcow2 size=12587106304 backing_file=raspbian-buster.qcow2 cluster_size=65536 lazy_refcounts=off refcount_bits=16

~# qemu-img create -b raspbian-buster.qcow2 -f qcow2 raspbian-buster-2.qcow2 
Formatting 'raspbian-buster-2.qcow2', fmt=qcow2 size=12587106304 backing_file=raspbian-buster.qcow2 cluster_size=65536 lazy_refcounts=off refcount_bits=16
```

Solo nos queda definir todos los parámetros para lanzar ambas máquinas. Pero primero vamos a generar las dos direcciones **MAC** aleatorias:

```
MAC0=$(echo "02:"`openssl rand -hex 5 | sed 's/\(..\)/\1:/g; s/.$//'`)
MAC1=$(echo "02:"`openssl rand -hex 5 | sed 's/\(..\)/\1:/g; s/.$//'`)
```

Por último los comandos para lanzar las máquinas serían estos:

```
# máquina 1
qemu-system-arm -kernel kernel-qemu-4.19.50-buster \
-dtb versatile-pb-buster.dtb -m 256 \
-cpu arm1176 -machine versatilepb \
-hda raspbian-buster-1.qcow2 -append "root=/dev/sda2" \
-hdd disco1.qcow2 \
-device virtio-net,netdev=n0,mac=$MAC0 \
-netdev tap,id=n0,ifname=tap0,script=no,downscript=no &

# máquina 2
qemu-system-arm -kernel kernel-qemu-4.19.50-buster \
-dtb versatile-pb-buster.dtb -m 256 \
-cpu arm1176 -machine versatilepb \
-hda raspbian-buster-2.qcow2 -append "root=/dev/sda2" \
-hdd disco2.qcow2 \
-device virtio-net,netdev=n1,mac=$MAC1 \
-netdev tap,id=n1,ifname=tap1,script=no,downscript=no &
```
Una vez lanzadas las **máquinas** podemos comprobar como, efectivamente, tiene cada una, una **ip accesible**, la arquitectura es **arm** y tienen un **disco secundario** de **10G**.

* Máquina 1

![](/recursos/img/initial-rp-1.png)

* Máquina 2

![](/recursos/img/initial-rp-2.png)
