# SAN basada en ARM y alta disponibilidad

### Descripción del proyecto

Usaré tres placas **Odroid-hc1** para crear un cluster de almacenamiento (con alta disponibilidad) basado en la arquitectura de procesamiento **ARM**. Dicha arquitectura es cada vez más usadas para **tareas** de **bajo coste computacional** debido a su extremadamente **bajo consumo energético**.

### Tecnologías que se van a utilizar

Usaré el la última versión de **Armbian**, una distribución pensada para esta arquitectura y que soporta el procesador que tiene la placa. Para el sistema de _alta disponibilidad_ usaré **PeaceMaker**, junto con **DRBD** para la sincronización de los discos e **ISCSI** a la hora de exportar los dispositivos de bloques.

### Resultados que se esperan obtener

Mi intención es conseguir un cluster de almacenamiento, escalable, con un consumo energético muy bajo y en alta disponibilidad.

Esto es en lo que, como mínimo, basaré el proyecto. No obstante dependiendo del tiempo que tenga, lo ampliaré añadiendo una o varias de las siguientes funcionalidades:

- **Sistema de ficheros avanzado** (para conseguir un mayor rendimiento y redundancia de los datos)
- Sistema de **monitorización**
- Receta de **ansible** para el despliegue (y posible escalado) de los nodos.

---------------------
**Modelo** de la placa: https://www.ldlc.com/es-es/ficha/PB00269570.html

**Especificaciones procesador**: https://gadgetversus.com/processor/samsung-exynos-5-octa-5422-specs/

Documentación **Armbian**: https://docs.armbian.com/

## Preparativos
    
> Los pasos que seguiré a continuación son los mismos indicados por la guía de instalación proporcionada por Odroid

Debido a la situación de confinamiento por **COVID-19**, tendré que empezar a realizar pruebas con máquinas virtuales. Entre todas las posibles soluciones me decanto por el uso de [QEMU](https://www.qemu.org/) para la emulación de una máquina con un procesador [Cortex A9](https://en.wikipedia.org/wiki/ARM_Cortex-A9) y posterior instalación del sistema operativo **Armbian**.
Comenzamos instalando una serie de paquetes y dependencias que nos serán necesarias para dicha emulación.

```
apt update
apt install libpixman-1-dev zlib1g-dev libglib2.0-dev shtool build-essential qemu-system-arm
```
Para conseguir un escenario lo más parecido posible al que plantearé con la placa [Odroid-hc1](https://magazine.odroid.com/es/article/odroid-hc1-and-odroid-mc1/), vamos a intentar emular una placa de la misma marca. Concretamente vamos a hacer uso de la imagen que tienen preparada en su [web](wget http://odroid.us/odroid/users/osterluk/qemu-example/qemu-example.tgz) para este emulador. Dicho esto, creamos un directorio que será nuestro entorno de desarrollo y descargamos el paquete.

```
mkdir -p PROYECTO/odroidu2/
cd PROYECTO/odroidu2/
# Descargamos el paquete
wget http://odroid.us/odroid/users/osterluk/qemu-example/qemu-example.tgz
# Y lo descomprimimos en el mismo directorio
tar -xf qemu-example.tgz
```
A continuación vamos a comprobar que existe un modelo de emulación que soporta el procesador **Cortex-A9**.

```
qemu-system-arm -M ? | grep vexpress-a9
vexpress-a9          ARM Versatile Express for Cortex-A9
```

Una vez comprobado esto, el siguiente paso será **crear** el disco virtual que funcionará como el la **raiz** del sistema.

```
# Creamos el fichero que funcionará como disco
qemu-img create rootfs-buildroot.ext4 5G
# Le damos el formato correspondiente
mkfs.ext4 rootfs-buildroot.ext4
# Creamos el directorio mnt/ dentro de nuestro entorno de desarrollo
mkdir mnt/
# Y montamos el dispositivo
mount rootfs-buildroot.ext4 mnt/
```
Después de montar el dispositivo vamos a descomprimir el sistema raiz que nos han proporcionado en el dicho dispositivo. Por lo que accedemos al directorio donde lo hemos montado y usamos `tar`.

```
cd mnt/
tar -xzf ../rootfs.tar.gz

# Podemos comprobar que se ha descomprimido y desempaquetado correctamente
~/PROYECTO/odroidu2/mnt# ls
bin  etc   lib	    lost+found	mnt  proc  run	 sys  usr
dev  home  linuxrc  media	opt  root  sbin  tmp  var
```

Si queremos comprobar que este sistema raiz funciona, podemos lanzar una máquina de prueba sin interfaz de red en modo puente. Para que resulte más sencillo de leer, voy a exportar algunas de las variables de la máquina, como el disco o la red.

```
# Exportamos las variables
export ROOTFS=rootfs-buildroot.ext4
export NETWORK="-net nic -net user"
export KERNEL="-kernel zImage "
# Y lanzamos la máquina
qemu-system-arm -append "root=/dev/mmcblk0 rw physmap.enabled=0 console=ttyAMA0" -M vexpress-a9 $KERNEL -sd $ROOTFS  $NETWORK -nographic
```
