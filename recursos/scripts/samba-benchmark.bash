#!/bin/bash

# Escritura ARM
dd if=/dev/zero of=/ARM/file-test.img bs=1M count=1024 oflag=direct

# Escritura x86
dd if=/dev/zero of=/x86/file-test.img bs=1M count=1024 oflag=direct

# Lectura ARM
dd if=/ARM/file-test.img of=/dev/null bs=1M count=1024 iflag=direct

# Lectura x86
dd if=/x86/file-test.img of=/dev/null bs=1M count=1024 iflag=direct


##################################################################################
# Resultados
#Escritura ARM
#
#root@Kutulu:/# dd if=/dev/zero of=/ARM/file-test.img bs=1M count=1024 oflag=direct
#1024+0 registros leídos
#1024+0 registros escritos
#1073741824 bytes (1,1 GB, 1,0 GiB) copied, 19,2126 s, 55,9 MB/s
#
#Escritura x86
#
#root@Kutulu:/# dd if=/dev/zero of=/x86/file-test.img bs=1M count=1024 oflag=direct
#1024+0 registros leídos
#1024+0 registros escritos
#1073741824 bytes (1,1 GB, 1,0 GiB) copied, 12,9094 s, 83,2 MB/s
#
#Lectura ARM
#
#root@Kutulu:/# dd if=/ARM/file-test.img of=/dev/null bs=1M count=1024 iflag=direct
#1024+0 registros leídos
#1024+0 registros escritos
#1073741824 bytes (1,1 GB, 1,0 GiB) copied, 16,2436 s, 66,1 MB/s
#
#Lectura x86
#
#root@Kutulu:/# dd if=/x86/file-test.img of=/dev/null bs=1M count=1024 iflag=direct
#1024+0 registros leídos
#1024+0 registros escritos
#1073741824 bytes (1,1 GB, 1,0 GiB) copied, 10,6225 s, 101 MB/s