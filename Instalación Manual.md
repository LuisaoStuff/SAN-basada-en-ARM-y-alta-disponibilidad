# Instalación de las máquinas

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

