# ¿Por qué ARM?
## Características de Odroid-HC1

* CPU: [Samsung Exynos5422 Cortex-A15](https://www.samsung.com/semiconductor/global.semi.static/minisite/exynos/file/solution/MobileProcessor-5-Octa-5422.pdf)
* RAM: 2Gb LPDDR3
* Interfaz SATA3
* Puerto Gigabit Ethernet
* Consumo: 3.7W ~ 9.8W

## Consumo

Si compraramos el consumo con el servidor NAS que tengo en casa (cuyo procesador es un [Intel Xeon X3470](https://ark.intel.com/content/www/es/es/ark/products/42932/intel-xeon-processor-x3470-8m-cache-2-93-ghz.html)), su consumo está comprendido entre **46W** y los **127W**. Como podemos observar, estamos hablando de un consumo entre **12 y 13** menor con un rendimiento bastante parejo.

Esta diferencia de consumo tan destacada tiene su explicación en cómo están diseñadas ambas arquitecturas. Mientras **x86** es una arquitectura con un esquema de **procesadores lógicos genéricos**, **ARM** está basado en el esquema **big.LITTLE**. ¿En qué consiste?
Cada vez nos encontramos con dispositivos diseñados para tareas específicas que necesitan poca potencia o un consumo muy bajo maximizar el tiempo de uso de las baterías en el caso de dispositivos móviles. Es por eso que se diseñó **big.LITTLE** que consiste en dos bloques de procesamiento; uno para tareas poco demandantes a nivel computacional (ofimática, servicios esenciales, navegar por internet, etc) y otro para tareas de altas prestaciones (renderizado de imágenes o video, videojuegos, etc). En el caso del procesador **samsung** que dispone esta placa, tendríamos este esquema:

![](/recursos/img/big-little.png)

Aquí el bloque "Big" sería el procesador **Cortex A15** y el bloque "little" sería el procesador **Cortex A7** de menores prestaciones.

Además de esta particularidad, en los últimos años **ARM** ha optado por seguir la linea _System-on-a-Chip_ o **SoC**, y que se trata de incluir todo el sistema (cpu, gpu, ram, controladores periféricos) en el mismo espacio. Esto lo convierte en un sistema _flexible_ y complétamente _modular_. Aquí tenemos un ejemplo:

![](/recursos/img/system-on-a-chip.png)

Una prueba de que este modelo de sistema está siendo un éxito es que hace poco, **Intel** ha desarrollado la nueva familia [Lakefield](https://ark.intel.com/content/www/es/es/ark/products/codename/81657/lakefield.html). Es una nueva generación de procesadores **x86** está basado en **big.LITTLE** de _5 núcleos_; 4 "little" y 1 "big". También tenemos que **Apple** desde hace unos meses, ha empezado a fabricar sus propios procesadores, los llamados [Apple M1](https://www.apple.com/mac/m1/) para su nueva generación de ordenadores portátiles, y que utiliza el mismo concepto **big.LITTLE**.

## Pruebas de rendimiento

Para realizar las pruebas, he decidido usar `samba` y el paquete `cifs-utils` que me permetirá montar ambos directorios en el equipo desde el que realizaré dichas pruebas. Para no complicarlo demasiado, usaré `dd` ya que es sencillo y tiene múltiples parámetros.
La configuración que he definido en ambas máquinas es la siguiente:

```
# Fichero /etc/samba/smb.conf

# Odroid HC1

[ARM]

comment = Benchmark
path = /Samba
browseable = yes
guest ok = yes
read only = no

# x86 System

[x86]

comment = Benchmark
path = /Samba
browseable = yes
read only = no
guest ok = yes
```
> Cabe mencionar que ambos directorios tienen los permisos habilitados de lectura y escritura para todos los usuarios

Después reinicio el servicio `smbd.service` y listo. Tan solo quedaría montar ambos directorios en la máquina de pruebas. Para ello usamos el comando `mount` tal y como nos indican en [Linuxize](https://linuxize.com/post/how-to-mount-cifs-windows-share-on-linux/). En mi caso sería:

```
mount -t cifs //cloud/x86 /x86 -o rw
mount -t cifs //spongebob/ARM ARM -o rw
```

Una vez preparado todo, procedemos con las pruebas de rendimiento. Dejo por [aquí](/recursos/scripts/samba-benchmark.bash) la lista de los 4 comandos que he utilizado. Por otro lado, la explicación del porqué de cada parámetro, podréis encontrarla en este [post](https://www.linux.org/threads/nas-storage-performance-testing-using-dd-command.8717/).

El resultado de estas pruebas es el siguiente:

![](/recursos/img/benchmark.png)