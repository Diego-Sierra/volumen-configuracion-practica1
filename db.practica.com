;
; BIND data file for local loopback interface
;
$TTL	604800
@	IN	SOA	practica.com. root.practica.com. (
			      2		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	ns.practica.com.
@   IN  A   10.10.0.12
@	IN	AAAA	::1
ns  IN  A   10.10.0.12
maquina1 IN A 10.10.0.2