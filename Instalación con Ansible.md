# Desarrollo y estructura del "playbook"

Antes de nada, vamos a conocer un poco qué es **Ansible**, y para qué se utiliza. En pocas palabras, es un **software de orquestación** que se utiliza para, a través de ficheros **yaml**, _desplegar y configurar_ una infraestructura. En mi caso, utilizaré dicho _software_ para instalar los paquetes necesarios, y en resumen desplegar todo el entorno descrito en el apartado [Instalación Manual](/Instalación-Manual.md).

## Estructura

A la hora de desarrollar un "_playbook_" de **Ansible** siempre vamos a intentar diferenciar bien qué **tareas** vamos a llevar a cabo, los **roles** que vamos a definir, y en qué **orden** se ejecutarán. Para esto disponemos de algunos conceptos como **rol** y **tasks**, aunque creo que viendo la estructura que he desarrollado, se entenderán mejor.

```bash
ansible/
├── ansible.cfg
├── hosts
├── roles
│   ├── commons
│   │   ├── files
│   │   │   └── etc
│   │   │       └── hosts
│   │   └── tasks
│   │       └── main.yml
│   ├── drbd
│   │   ├── files
│   │   │   ├── hadisk.res
│   │   │   └── sincro.bash
│   │   └── tasks
│   │       └── main.yml
│   └── pacemaker
│       ├── files
│       │   ├── cluster_config.bash
│       │   └── cluster_start.bash
│       └── tasks
│           └── main.yml
└── site.yaml

```

En este caso los _roles_ serían:

* [commons](/ansible/roles/commons): Es un rol que suele aparecer en la mayoría de los _playbooks_ y que sirve para definir algunas tareas que son comunes para todos los nodos. Por ejemplo, la instalación de paquetes comunes o la definición de la resolución de nombres a través de un fichero **/etc/hosts**.
* [drdbd](/ansible/roles/drbd): Aquí definiré la configuración de del recurso **drbd** y definiré una _pausa_ para esperar la sincronización completa de los discos, algo necesario para el uso de este recurso en el cluster.
* [pacemaker](/ansible/roles/pacemaker): Crea el cluster y define los _agentes_ de **drbd** e inicia el **target** y la **lun** de **ISCSI** con el _agente_ correspondiente. 


Por otro lado tenemos el fichero 