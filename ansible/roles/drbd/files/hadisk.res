resource hadisk {
 protocol C;
 meta-disk internal;
 device /dev/drbd0;
 syncer {
  verify-alg sha1;
 }
 net {
  allow-two-primaries;
 }
 on spongebob {
  disk /dev/sda;
  address 192.168.1.20:7788;
  meta-disk internal;
 }
 on patrick {
  disk /dev/sda;
  address 192.168.1.21:7788;
  meta-disk internal;
 }
}
