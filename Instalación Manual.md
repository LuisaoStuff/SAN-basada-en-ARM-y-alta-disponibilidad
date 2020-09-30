# Instalación de las máquinas

## Revisión del hardware

Utilizaremos dos máquinas [Odroid-HC1](https://www.hardkernel.com/shop/odroid-hc1-home-cloud-one/), alimentadas por un [transformador](https://www.hardkernel.com/shop/5v-4a-power-supply-eu-plug-2/) de 5V/4A cada una, e instalaremos el sistema operativo en una _tarjeta microSD_ modelo [Sandisk Industrial 8Gb](https://www.mouser.com/datasheet/2/669/SanDisk_Industrial%20Grade%20SD%20%20MicroSD%20Product%20Brief-805940.pdf), además de dos latiguillos [ethernet Cat-5e](https://www.amazon.es/dp/B00BS9JXPA?ref=ppx_pop_mob_ap_share). Como disco duro para el almacenamiento en alta disponibilidad, usaremos dos discos _SSD_ [Kingston 128Gb](https://www.amazon.es/dp/B073VFG4C7/ref=cm_sw_r_wa_apap_LAsbMrtrxJSpL).

### Características de Odroid-HC1

* CPU: [Samsung Exynos5422 Cortex-A15](https://www.samsung.com/semiconductor/global.semi.static/minisite/exynos/file/solution/MobileProcessor-5-Octa-5422.pdf)
* RAM: 2Gb LPDDR3
* Interfaz SATA3
* Puerto Gigabit Ethernet
* Consumo: 3.7W ~ 9.8W

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

## Instalación de la paquetería

Una vez tenemos ya todo montado, 