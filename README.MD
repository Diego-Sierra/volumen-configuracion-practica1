# **Configuración de zona**
***
## **-Forwarders**  
El servidor DNS solamente contiene registros de la zona sobre la que tiene autoridad, que en este caso va a ser nuestro dominio. Para que los equipos del dominio puedan realizar consultas DNS hacia el exterior configuramos nuestro servidor DNS en modo caché.  
 
Un servidor DNS CACHE sirve para redireccionar y posteriormente almacenar (durante el tiempo especificado en el TTL) las peticiones que los clientes de una red hacen a un servidor de nombres de dominio (DNS SERVER) externo, que es proporcionado por el proveedor de Internet, empresas como Cloudfire o Google, etc.

Para realizar la configuración del servidor caché es necesario indicar los servidores DNS externos a los que se van a redireccionar las consultas que no pueda satisfacer nuestro servidor DNS local. Esto se hace modificando el archivo **_/etc/bind/named.conf.options_**

En este archivo es necesario descomentar las siguientes lineas y añadir en ellas las ip de los servidores DNS a los que desemos redireccionar: 

```
forwarders {
    1.2.3.4;
    5.6.7.8;
};
```

Tras ello deberemos reiniciar el servicio, en este caso el contenedor que lo alberga.

## **-Configuración como servidor primario**
Un servidor DNS primario mantiene la información autoritativa de una zona (Una zona DNS se usa para hospedar los registros DNS de un dominio concreto), cuyos registros estan almacenados y gestionados directamente en sus propios ficheros. Para ello se debe crear dicha zona a través del fichero **_/etc/bind/named.conf.local_** añadiendo:

```
zone "practica.com" {
    type master;
    file "/etc/bind/db.practica.com";
};
```
Con esto este servidor será el servidor DNS maestro (type master)del dominio practica.com y los registros de la zona se guardaran en el fichero **_/etc/bind/db.practica.com_**. Crearemos dicho archivo copiando otro archivo de zona predefinido, por ejemplo db.local, como plantilla:

```
cp db.local db.practica.com
```


## **-Configuración de los registros de zona**


Abrimos el archivo db.practica.com que acabamos de crear. Contiene la siguiente estructura y la usaremos como plantilla para crear la configuracion de los registros de nuestra zona:

```
;
; BIND data file for local loopback interface
;
$TTL	604800
@	IN	SOA	localhost. root.localhost. (
			      2		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	localhost.
@	IN	A	127.0.0.1
@	IN	AAAA	::1
```
**_Inciso importante_**:

Cuando un registro de este fichero finaliza con un "." significa que hemos introducido la informacion completa, en caso de no añadirle el punto final se completará la informacion añadiendo el nombre del dominio (www se convierte en www.practica.com. y www.practica.com se convierte en www.practica.com.practica.com)

+ Lo primero que vemos es el registro SOA, que define nuestra area y muestra informacion sobre ella. 

  Aqui sustituimos "localhost." por el **FQDN** (nombre de dominio completo) y root.localhost. (el primer punto equivale a una @) por una direccion de correo de administracion del dominio. 

  A continuación tenemos el **serial**. Este campo es importante y debe ser modificado tras cada modificación que se realice en el archivo (bien sea siguiendo un orden numerico o utilizando un patron de fecha), pues, además de permitir depurar errores en el arranque del servidor, esta modificación permite que los posibles servidores DNS secundarios se resincronicen con la nueva configuración.
   
  Refresh — Es el numero de segundos entre peticiones de actualizacion de los servidores secundarios.

  Retry — Es el numero de segundos que los servidores secundarios esperaran para reintentar una actualizacion tras un intento fallido de actualizacion.

  Expire — Numero de segundos tras el cual los servidores secundarios considerarán que los registros han expirado en caso de no ser capaces de contactar con un servidor primario.

  Negative Cache TTL — Utilizado para indicar los segundos que un cliente almacenará una respuesta negativa del servidor, por lo que no volverá a realizarle la solicitud, en caso de que este no disponga de la información requerida. Es una especie de TTL inverso.  

+ Tras el SOA vienen los demas registros:
  
  -El registro NS permite indicar cuales son servidores DNS de la zona y el registro A permite relacionar un nombre con una IP. Es decir que:

  ```
  ns        IN   A   10.10.0.12
  ```
  
  Y

  ```
  @	      IN   NS	ns.practica.com.
  ```

  Permiten indicar que en la IP 10.10.0.12 existe un equipo llamado "ns" que, a su vez, es el servidor NS del dominio practica.com. La @ equivale al nombre del dominio de forma que
  
  ```
  @         IN   A   10.10.0.12
  ```
  indica la direccion ip de practica.com

  Podemos asociar cada equipo del dominio con un nombre y una IP de forma que:

  ```
  maquina1  IN   A   10.10.0.2
  ```

  Cuando el servidor DNS reciba una solicitud DNS sobre maquina1.practica.com devolverá la IP 10.10.0.2

  

  