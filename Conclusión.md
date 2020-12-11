# Conclusiones

Tras haberme documentado y haber trabajado con **ARM**, creo que es una arquitectura que cada tiene más sentido utilizar en el "lado del cliente". Estamos viviendo a día de hoy una transición en la que la mayoría de servicios y aplicaciones destinadas a usuarios finales están siendo migradas al cloud. Cada vez queremos que nuestros dispositivos móviles sean más eficientes y **big.LITTLE** es justo lo que ofrece.
Por otro lado, la infraestructura que he montado cumple con lo que prometía; alta disponibilidad, redundancia de los datos y un consumo muy bajo. Al principio tuve algunos problemas a la hora de configurar el agente de **ISCSI** con **pacemaker** para levantar los recursos ya que la poca documentación que existe es la oficial, y esta es bastante escueta. No obstante, una vez que entendí la sintaxis de dichos comandos, y cómo funciona el paquete `pcs` no tardé mucho en configurarlo todo.

# Próximos pasos

En el caso de seguir ampliando este proyecto, podríamos cambiar por ejemplo, el sistema de ficheros a [Lustre](https://es.wikipedia.org/wiki/Lustre_(sistema_de_archivos)) de tal forma que conseguiríamos un mayor rendimiento que con drbd. También podríamos implementar algún tipo de sistema de monitorización como [Prometheus](https://prometheus.io/docs/introduction/overview/) gestionado con [Grafana](https://grafana.com/).