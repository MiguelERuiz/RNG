# TEMA 1: IPv6

- Explica en qué caso puede existir ambigüedad en las direcciones IPv6 y
por qué pueden llegar a producirse.


Las direcciones IPv6 tienen un determinado ámbito donde son
válidas y están asociadas a una determinada zona de ámbito donde se
garantiza su unicidad. El problema es que aquellas máquinas que se
encuentren en el límite de una zona (por ejemplo un encaminador con
interfaces a dos redes de enlace local distintas) pueden tener interfaces a
redes distintas con igual ámbito en las que haya las mismas direcciones.
Por ejemplo, un router que tenga interfaces a dos redes de enlace local en
las que haya una máquina con dirección fe80::1. Esto genera una ambigüedad
ya que cuando desde el router se mande un mensaje a esa dirección no está
claro quién es el destinatario y por qué interfaz hay que mandarlo. En
la práctica, es necesario añadir `%<interfaz salida>` al final de la dirección
para romper la ambigüedad.


- Explica los problemas de privacidad y las distintas soluciones
planteadas en relación a la autoconfiguración de direcciones en IPv6


IPv6 permite la autoconfiguración de direcciones mediante el
anuncio de prefijos que hacen los routers, que se completa con un
identificador de interfaz. Una forma sencilla, pero poco segura de hacerlo
es mediante la dirección MAC (48b) que se parte por la mitad metiendo FFFE
entre medias y alterando el valor de uno de los bits. El problema de esto
es que la dirección física va asociada a la máquina, que suele ir asociada
a una persona, y es posible rastrearla a través de la dirección IPv6. Una
solución alternativa más segura es generar direcciones
pseudoaleatorias temporales (por ejemplo, cada hora) de forma que las
conexiones antiguas se mantienen con la IP antigua pero las nuevas se hacen
con la nueva IP. Esta solución tampoco es muy convincente porque dificulta
la identificación de comportamientos inadecuados ya que la IP está
continuamente cambiando. La mejor solución es generar identificadores de
interfaz estables y opacos de tal forma que cuando estamos en la misma red
el identificador es fijo, pero cuando nos conectamos a otra red cambia.
Esto se hace mediante cierta función criptográfica que se aplica sobre
distintos parámetros (entre ellos el prefijo de la red).


- Describe la manera más adecuada de asignar direcciones de red IPv6


Mediante un árbol binario que facilite después el agregado de
direcciones. Es decir, si tenemos 16 bits para la red, asignar primero la
0, luego las 65535, luego la 32758 (la de la mitad), luego la 32758/2
=16379, luego la 32758 + 16379=49137 etc. Así, si luego surge una nueva red
relacionada con la 0, podemos asignarla la 1 y que sea fácilmente agregada
con la 0. Al hacer este reparto binario tratamos de cubrirnos las espaldas
para luego poder agregar de esa manera.


- ¿Que son las direcciones Anycast?


Son direcciones que van destinadas a un grupo pero que solo se entregan a uno de sus miembros. Estas direcciones son indistinguibles de las direcciones unicast (a una sola interfaz) Por ejemplo NTP (Network Time Protocol).


- ¿Qué función tiene el campo Hop Limit de la cabecera IPv6?


Evitar que un paquete pueda estar indefinidamente retransmitiéndose en la red. Para ello se decrementa su valor cada vez que llega a un encaminador y se descarta si llega a 0.


# TEMA 2: RIP y OSPF

Explica en qué consiste el problema de la inundación en el protocolo
OSPF y cómo se soluciona.

En el protocolo OSPF la información del estado de los enlaces
se difunde por la red mediante una inundación. Es necesario acotar el
proceso de inundación para que si existen bucles en la red los mensajes no
estén viajando por ella de manera indefinida. Para ello, los LSA que
intercambian los encaminadores adyacentes llevan una marca de tiempo y el
router-id de quien generó el anuncio. Estos campos permiten a los
encaminadores descartar ciertos anuncios, que no se vuelven a reenviar a
sus adyacentes.


Enumera y explica brevemente los distintos tipos de información de los LSA


- Encaminador: describe el estado de las interfaces (enlaces) de cada
encaminador y se difunde por toda el área.
- Red: contiene los encaminadores conectados a una red de difusión. Lo
genera el DR y se difunde por toda el área.
- Resumen: lo genera un ABR, se inyecta en la troncal y luego se inyecta en
otras áreas. Hay resúmenes que describen cómo llegar a destinos de otras
áreas y hay resúmenes que describen cómo alcanzar un ASBR.
- Externa: describe rutas a destinos fuera de la red OSPF. Son generados
por un ASBR y se difunden por todas las áreas OSPF.


¿Qué es un Sistema Autónomo?


Un conjunto de redes y encaminadores que están bajo el control de una organización
y que tiene una política de encaminamiento común.

   - Dispone de un sistema de encaminamiento.

   - Intercambia información de encaminamiento con otros encaminadores externos.

   - Decide qué hacer con el tráfico de su red.

¿Qué es RIP?


Un protocolo de encaminamiento interno (Routing Internet Protocol) basado en el vector distancia (número de saltos hasta llegar al destino) válido solo para redes pequeñas (de entre 6 o 7 encaminadores, 15 como máximo).


¿Por qué RIP solo se puede usar en redes con menos de 16 encaminadores?


Porque RIP tiene un tiempo alto de convergencia (tiempo en el que todas las tablas de rutas de todos los encaminadores están en un estado estable) que se incrementa cuanto mayor sea el número de encaminadores, para mitigarlo se usa la regla de Horizontes Divididos (no incluir en la información de encaminamiento las redes que se alcanzan por esa interfaz). Además se puede producir el problema de la cuenta a infinito, que consiste en que dos encaminadores incrementan indefinidamente el número de saltos necesarios cuando cada uno cree que el otro es el encaminador por el que has de pasar los paquetes, y para evitarlo se hace la presunción de que una distancia de 16 es equivalente a infinito.


¿Cuándo se crea un Encaminador designado en OSPF y cómo se decide cuál es?


Cuando hay una red de Difusión (un enlace al que están conectados varios encaminadores OSPF). Se elige el que tenga mayor prioridad, si no está definida se elige al que tenga un identificador mayor.


¿Cómo se calcula en OSPF el coste a una red externa?

Se tienen 2 maneras:

   - Tipo 1: Al coste OSPF hasta el encaminador ASBR (Frontera externa) se le
   suma un coste administrativo que decide el administrador de la red.

   - Tipo 2: Se ignora el coste OSPF y solo se tiene en cuenta el coste
   administrativo asignado. Este tipo solo se usa en casos particulares en los
   que se tiene una ruta por defecto.


# TEMA 3: BGP

Enumera y explica muy brevemente los distintos tipos de atributos que
puede tener un mensaje update en BGP.


- Bien conocidos y obligatorios: tienen que ser reconocidos por todas las
implementaciones BGP y estar presentes en cada mensaje update.
- Bien conocidos y no obligatorios: tienen que ser reconocidos por todas
las implementaciones BGP pero su presencia en mensajes update es opcional.
- Opcionales transitivos: no es necesario que todas las implementaciones
BGP los reconozcan, pero siempre deben reenviarlos a sus vecinos.
- Opcionales no transitivos: no es necesario que todas las implementaciones
BGP los reconozcan ni que se reenvíen a los vecinos (pueden descartarse).


Define brevemente el concepto de *wedgie.*


Los *wedgies* son comportamientos no deterministas que se presentan en BGP.
Ante una misma situación en la red es posible que se escojan rutas
diferentes. Si hay un fallo en algún componente de la red, se recalculan
las rutas, pero cuando se arregla el fallo es posible que las rutas no
vuelvan a ser las que teníamos originalmente.


¿Qué son Peers en BGP?


Son encaminadores que intercambian información de encaminamiento y políticas de forma privada. Ninguno de los dos es tránsito del otro.


¿Qué tipos de Sistemas Autónomos puede haber?


   - Multihomed: Si está conectado a más de un Sistema Autónomo que usa como proveedores.
   - Stub: Si está conectado a con un solo Sistema a Autónomo que usa como proveedor.
   - Transit: Si proporciona conexión entre distintos Sistemas Autónomos.

¿Qué es el CIDR (Classless Interdomain Routing) y por qué surge?


Surge por la dificultad que entraña el enrutamiento para una gran cantidad de redes  para lo cual se requiere mantener grandes tablas de enrutado que incrementan considerablemente el tiempo de envío. Como posible solución CIDR consiste en repartir direcciones IP en bloques a delegaciones regionales que las asignen, de esta forma se puede realizar un encaminamiento jerárquico.


¿Qué tipos de mensajes BGP hay?

   - OPEN: inicia la sesión BGP entre dos encaminadores vecinos.

   - UPDATE: Transmite información de encaminamiento (red y atributos). Se
   puede usar para añadir o borrar una red.

   - KEEPALIVE: Se usa para responder a un mensaje OPEN y mantener la sesión BGP.

   - NOTIFICATION: Se usa para informar de la detección de una condición de
   error y cerrar la sesión BGP.


¿Qué ocurre cuando se cierra una sesión BGP?


Se descartan todas las rutas asociadas a ese vecino (las que pasaban por él). Además se avisa al resto de vecinos de que esas rutas ya no son válidas. En caso de disponer de otras rutas para alcanzar las redes que usaban las rutas descartadas, se reasignan.


¿Qué es un Reflector de Rutas en iBGP y para que se utiliza?


Se utiliza para reducir el número de conexiones. El Reflector de Rutas es un router que hace de proxy para el resto de encaminadores iBGP, de manera que cuando se recibe una actualización externa, se envía solo al reflector de Rutas y este se la comunica al resto de routers iBGP.


# TEMA 4: MPLS

¿En qué consiste MPLS (Multiprotocol Label Switching)?


En MPLS solo los encaminadores frontera tienen información completa de todas las redes. Estos encaminadores se encargan de clasificar y etiquetar los paquetes de entrada al dominio. Los encaminadores internos realizan el enrutado en función de esa etiqueta. Esta etiqueta cambia en cada  encaminador intermedio y cuando el paquete se dispone a abandonar el dominio se elimina del paquete. Con esto se reduce el tiempo de enrutamiento y se pueden aplicar políticas de QoS (quality of service).


¿En qué consiste Penultimate Hop Popping en MPLS?


Consiste en que el penúltimo encaminador es el que quita la etiqueta al paquete antes de que llegue al LER (Label Edge Router) de salida, ya que este tendrá que enrutar el paquete en función de la dirección IP de destino, ahorrándole así un poco de trabajo extra.


¿En qué consiste Fast Reroute en MPLS?


Consiste en tener definida un ruta alternativa previamente en caso de que caiga algún enlace o un nodo de la red. En esos casos se cambia la etiqueta original por la de la ruta alternativa, como en MPLS la etiqueta se cambia en cada encaminador la recuperación es mucho más rápida ya que las rutas alternativas pueden estar definidas en cada uno de los encaminadores del LSP (Label Switching Path).


¿Por qué MPLS incluye un campo TTL y qué ocurre si el llega a 0 en un encaminador intermedio o LSR (Label Switching Router)?


Para que los encaminadores intermedios no tengan que examinar la cabecera IP. Si llega a cero en un encaminador intermedio, este descarta el paquete y genera un mensaje ICMP de error (TTL exceeded) al que se envía por la misma LSP (Label Switching Path) que tenía el paquete original. Entonces el mensaje ICMP llegará al encaminador LER (Label Edge Router) por donde iba a salir el paquete original y cuando este lo examine lo reenviará a la dirección de destino (que es la dirección fuente del paquete original), por lo que, probablemente, el paquete ICMP retomará por mismo camino de vuelta que ha seguido hasta el LER.


# TEMA 6: Encaminamiento Multicast

¿Cuándo acepta (retransmite) un encaminador una transmisión multicast?


Cuando esa transmisión ha de llegarle por el mismo interfaz que él usaría para comunicarse con la fuente y además tiene en su MFT (Multicast Forwarding Table) anotada alguna interfaz de salida.


¿Qué ocurre cuando un encaminador recibe una transmisión multicast en la que no está interesado?


Envía un mensaje de poda al encaminador inmediatamente anterior del que ha recibido la transmisión para que deje de enviarla. El router que lo recibe borra de su MFT (Multicast Forwarding Table) para esa transmisión el interfaz de salida por el que ha recibido el mensaje de poda.


¿Qué es un RP (Rendezvous Point) y BSR (Bootstrap Router) en Multicast?


El  RP (Rendezvous Point) es un router que se encarga de retransmitir la transmisión multicast original de las fuentes a todo Internet, y el BSR (Bootstrap Router) es el encaminador que se encarga de decidir quién va a ser el RP y difundir esa información por Internet.

