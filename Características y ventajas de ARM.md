## Revisión del hardware

Utilizaremos dos máquinas [Odroid-HC1](https://www.hardkernel.com/shop/odroid-hc1-home-cloud-one/), alimentadas por un [transformador](https://www.hardkernel.com/shop/5v-4a-power-supply-eu-plug-2/) de 5V/4A cada una, e instalaremos el sistema operativo en una _tarjeta microSD_ modelo [Sandisk Industrial 8Gb](https://www.mouser.com/datasheet/2/669/SanDisk_Industrial%20Grade%20SD%20%20MicroSD%20Product%20Brief-805940.pdf), además de dos latiguillos [ethernet Cat-5e](https://www.amazon.es/dp/B00BS9JXPA?ref=ppx_pop_mob_ap_share). Como disco duro para el almacenamiento en alta disponibilidad, usaremos dos discos _SSD_ [Kingston 128Gb](https://www.amazon.es/dp/B073VFG4C7/ref=cm_sw_r_wa_apap_LAsbMrtrxJSpL).

### Características de Odroid-HC1

* CPU: [Samsung Exynos5422 Cortex-A15](https://www.samsung.com/semiconductor/global.semi.static/minisite/exynos/file/solution/MobileProcessor-5-Octa-5422.pdf)
* RAM: 2Gb LPDDR3
* Interfaz SATA3
* Puerto Gigabit Ethernet
* Consumo: 3.7W ~ 9.8W

## Consumo

Si compraramos el consumo con el servidor NAS que tengo en casa (cuyo procesador es un [Intel Xeon X3470](https://ark.intel.com/content/www/es/es/ark/products/42932/intel-xeon-processor-x3470-8m-cache-2-93-ghz.html)), su consumo está comprendido entre **46W** y los **127W**. Como podemos observar, estamos hablando de un consumo entre **12 y 13** menor con un rendimiento bastante parejo.

## Pruebas de rendimiento

Para realizar las pruebas, me limitaré a utilizar el paquete **samba**. Probaré a subir y descargar un fichero de 5Gb.
