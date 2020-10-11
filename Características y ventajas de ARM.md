## Características de Odroid-HC1

* CPU: [Samsung Exynos5422 Cortex-A15](https://www.samsung.com/semiconductor/global.semi.static/minisite/exynos/file/solution/MobileProcessor-5-Octa-5422.pdf)
* RAM: 2Gb LPDDR3
* Interfaz SATA3
* Puerto Gigabit Ethernet
* Consumo: 3.7W ~ 9.8W

## Consumo

Si compraramos el consumo con el servidor NAS que tengo en casa (cuyo procesador es un [Intel Xeon X3470](https://ark.intel.com/content/www/es/es/ark/products/42932/intel-xeon-processor-x3470-8m-cache-2-93-ghz.html)), su consumo está comprendido entre **46W** y los **127W**. Como podemos observar, estamos hablando de un consumo entre **12 y 13** menor con un rendimiento bastante parejo.

Esta diferencia de consumo tan destacada tiene su explicación en cómo están diseñadas ambas arquitecturas. Mientras **x86** es una arquitectura con un esquema de procesadores lógicos **genéricos**, **ARM** está basado en el esquema **Big-Little**. ¿En qué consiste?
Cada vez nos encontramos con dispositivos diseñados para tareas específicas que necesitan poca potencia o un consumo muy bajo maximizar el tiempo de uso de las baterías en el caso de dispositivos móviles. Es por eso que se diseñó **Big-Little** que consiste en dos bloques de procesamiento; uno para tareas poco demandantes a nivel computacional (ofimática, servicios esenciales, navegar por internet, etc) y otro para tareas de altas prestaciones (renderizado de imágenes o video, videojuegos, etc). En el caso del procesador **samsung** que dispone esta placa, tendríamos este esquema:

![](/recursos/img/big-little.png)

Aquí el bloque "Big" sería el procesador **Cortex A15** y el bloque "little" sería el procesador **Cortex A7** de menores prestaciones.

Además de esta particularidad, en los últimos años **ARM** ha optado por seguir la linea _System-on-a-Chip_ o **SoC**, y que se trata de incluir todo el sistema (cpu, gpu, ram, controladores periféricos) en el mismo espacio. Esto lo convierte en un sistema _flexible_ y complétamente _modular_. Aquí tenemos un ejemplo:

![](/recursos/img/system-on-a-chip.png)



## Pruebas de rendimiento

Para realizar las pruebas, me limitaré a utilizar el paquete **samba**. Probaré a subir y descargar un fichero de 5Gb.