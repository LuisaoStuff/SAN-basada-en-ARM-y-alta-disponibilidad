# SAN basada en ARM y alta disponibilidad

### Descripción del proyecto

Usaré tres placas **Odroid-hc1** para crear un cluster de almacenamiento (con alta disponibilidad) basado en la arquitectura de procesamiento **ARM**. Dicha arquitectura es cada vez más usadas para **tareas** de **bajo coste computacional** debido a su extremadamente **bajo consumo energético**.

### Tecnologías que se van a utilizar

Usaré el la última versión de **Ubuntu 20.04.1 LTS**, una distribución pensada para esta arquitectura y que soporta el procesador que tiene la placa. Para el sistema de _alta disponibilidad_ usaré **PaceMaker**, junto con **DRBD** para la sincronización de los discos e **ISCSI** a la hora de exportar los dispositivos de bloques.

### Resultados que se esperan obtener

Mi intención es conseguir un cluster de almacenamiento escalable, con un consumo energético muy bajo y en alta disponibilidad.

Esto es en lo que, como mínimo, basaré el proyecto. No obstante dependiendo del tiempo que tenga, lo ampliaré añadiendo una o varias de las siguientes funcionalidades:

- **Sistema de ficheros avanzado** (para conseguir un mayor rendimiento y redundancia de los datos)
- Sistema de **monitorización**
- Receta de **ansible** para el despliegue (y posible escalado) de los nodos.

---------------------
**Modelo** de la placa: https://www.hardkernel.com/shop/odroid-hc1-home-cloud-one/

**Especificaciones procesador**: https://gadgetversus.com/processor/samsung-exynos-5-octa-5422-specs/

## Índice

* [¿Por qué ARM?](/Características-y-ventajas-de-ARM.md#por-qué-arm)
  * [Especificaciones Odroid HC1](/Características-y-ventajas-de-ARM.md#características-de-odroid-hc1)
  * [Consumo](/Características-y-ventajas-de-ARM.md#consumo)
  * [Pruebas de rendimiento](/Características-y-ventajas-de-ARM.md#pruebas-de-rendimiento)
* [Emulación del entorno](/Entorno-Virtual.md)
  * [Linux Bridges](/Entorno-Virtual.md#interfaz-de-red-virtual)
  * [Creación de las máquinas](/Entorno-Virtual.md#creación-de-las-máquinas)
* [Instalación](/Instalación-Manual.md)
  * [Preparación de las tarjetas microSD](/Instalación-Manual.md#preparación-de-las-tarjetas-microsd)
  * [Montaje del equipo](/Instalación-Manual.md#montaje-del-equipo)
  * [Instalación y configuración de la paquetería](/Instalación-Manual.md#instalación-y-configuración-de-la-paquetería)
    * [DRBD](/Instalación-Manual.md#drbd)
    * [Pacemaker](/Instalación-Manual.md#pacemaker)
* [Despliegue automático](/Instalación-con-Ansible.md)


