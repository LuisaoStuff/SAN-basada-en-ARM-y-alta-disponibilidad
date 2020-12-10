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
└── site.yml

```

En este caso los _roles_ serían:

* [commons](/ansible/roles/commons): Es un rol que suele aparecer en la mayoría de los _playbooks_ y que sirve para definir algunas tareas que son comunes para todos los nodos. Por ejemplo, la instalación de paquetes comunes o la definición de la resolución de nombres a través de un fichero **/etc/hosts**.
* [drdbd](/ansible/roles/drbd): Aquí definiré la configuración de del recurso **drbd** y definiré una _pausa_ para esperar la sincronización completa de los discos, algo necesario para el uso de este recurso en el cluster.
* [pacemaker](/ansible/roles/pacemaker): Crea el cluster y define los _agentes_ de **drbd** e inicia el **target** y la **lun** de **ISCSI** con el _agente_ correspondiente. 


Las tareas de dichos roles están definidas a su vez dentro de su propio directorio en **/tasks/main.yml**. Por otro lado tenemos el fichero [site.yml](/ansible/site.yml), que contiene la "_receta_" o el _orden_  en el que se ejecutarán estos roles y en qué _nodos_ se aplicarán.
Dentro de cada _rol_, tendremos ficheros de configuración y/o scripts que se copiarán en los nodos correspondientes para su posterior uso. Un ejemplo de esto es el fichero [hadisk.res](/ansible/roles/drbd/files/hadisk.res) que contiene la configuración del recurso **drbd**.


Por último tenemos los ficheros de configuración del entorno, donde se definen parámetros como el usuario remoto, la _clave privada_ que se va a usar para el acceso **ssh** ([ansible.cfg](/ansible/ansible.cfg)) y la resolución de los nombres de los nodos, así como su respectiva agrupación ([hosts](/ansible/hosts)).

### Requisitos previos

Para su correcto funcionamiento, necesitaremos preparar los nodos. Tan solo tendremos que instalar el paquete `python` y configurar `ssh`. Para instalar el paquete simplemente ejecutamos:

`apt install python`

Después añadimos la clave pública al fichero **.ssh/authorized_keys** del usuario **root**. Esto podemos hacerlo simplemente copiando el contenido de la clave pública que vayamos a utilizar y pegándolo dentro de ese fichero. Después tendremos que dirigirnos a **/etc/ssh/sshd_config** y modificar las siguientes dos lineas quedando así:

```bash
...

PermitRootLogin prohibit-password
PubkeyAuthentication yes

...
```

De esta forma evitaremos que se acceda como root al sistema por contraseña y permitiremos la autenticación por _clave pública-clave privada_.

En el controlador (desde el que ejecutaremos el _playbook_), solo necesitaremos instalar el paquete **ansible**.

`apt install ansible`

Una vez que ejecutamos el playbook, debemos obtener una salida por pantalla como esta:

```bash
PLAY [all] ***************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************
ok: [patrick]
ok: [spongebob]

TASK [commons : Actualizar sistemas] *************************************************************************************************************
changed: [spongebob]
changed: [patrick]

TASK [commons : Instalar todos los paquetes] *****************************************************************************************************
changed: [spongebob]
changed: [patrick]

TASK [commons : Cambiar contraseña al usuario hacluster] *****************************************************************************************
changed: [spongebob]
changed: [patrick]

TASK [commons : Copiar /etc/hosts] ***************************************************************************************************************
ok: [spongebob]
ok: [patrick]

TASK [drbd : Copiar fichero recurso drbd] ********************************************************************************************************
changed: [spongebob]
changed: [patrick]

TASK [drbd : Crear recurso drbd] *****************************************************************************************************************
changed: [patrick]
changed: [spongebob]

TASK [drbd : Activar recurso drbd] ***************************************************************************************************************
changed: [spongebob]
changed: [patrick]

TASK [drbd : Forzar disco primario] **************************************************************************************************************
skipping: [patrick]
changed: [spongebob]

TASK [drbd : Copiar script comprobación sincronización] ******************************************************************************************
skipping: [patrick]
changed: [spongebob]

TASK [drbd : Esperar sincronización discos] ******************************************************************************************************
skipping: [patrick]
changed: [spongebob]

TASK [drbd : Habilitar unidad Drbd] **************************************************************************************************************
changed: [spongebob]
changed: [patrick]

TASK [pacemaker : Copiar script inicialización] **************************************************************************************************
changed: [spongebob]
changed: [patrick]

TASK [pacemaker : Inicializar el cluster] ********************************************************************************************************
changed: [spongebob]
changed: [patrick]

TASK [pacemaker : Copiar script configuración] ***************************************************************************************************
skipping: [patrick]
changed: [spongebob]

TASK [pacemaker : Configurar recursos del cluster] ***********************************************************************************************
skipping: [patrick]
changed: [spongebob]

TASK [pacemaker : Habilitar unidad Pacemaker] ****************************************************************************************************
ok: [spongebob]
ok: [patrick]

TASK [pacemaker : Habilitar unidad Corosync] *****************************************************************************************************
ok: [patrick]
ok: [spongebob]

PLAY RECAP ***************************************************************************************************************************************
patrick                    : ok=13   changed=9    unreachable=0    failed=0   
spongebob                  : ok=18   changed=14   unreachable=0    failed=0 
```