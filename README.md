# Spoofing.kali
Suplantación del servidor DHCP en una red mediante un ataque "starvation" y posterior suplantación para escucha de informacion.

## Configuración red de maquina atacante Kali
Lo primero es configurar nuestra máquina atacante con dos tarjetas de red, una para la red interna en la que hará la suplantación del servicio DHCP y otra que conectará con el internet para proveer de internet a los usuarios engañados y poder escuchar su información, haciendo función de un router normal.<br>
```
    sudo nano -c /etc/network/interfaces
```
```
    ####RED INTERNA####
    auto eth0
    iface eth0 inet static
        address 192.168.1.66
        netmask 255.255.255.0
        dns-nameservers 8.8.8.8, 8.8.4.4

    ####RED EXTERNA####
    auto eht1
    iface eth1 inet static
        address 10.4.33.130
        netmask 255.255.255.0
        gateway 10.33.4.1
```
![imagen](https://github.com/EndOfBehelit/Spoofing.kali/assets/154753826/3f313f7e-8bd3-461b-868d-7822a120b7d2) <br>

- **Habilitación de Forwarding persistente** <br>

Ahora debemos configurar nuestra máquina atacante para que pueda hacer un reenvío de paquetes y funcionar como router.
```
    sudo nano -c /sysctl.conf
```
Esta opción viene comentada, con buscarla y descomentarla sirve. Esta es una forma persistente de activar el forwarding.
```
    net.ipv4.ip_forward=1
```
- **Habilitación de nateo persistente** <br>
Por último debemos crear un pequeño script que habilite el nateo cada vez que se arranque el ordenador:
```
    sudo nano -c masquerade.sh
```
```
    #!/bin/bash
    sudo iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
```
![imagen](https://github.com/EndOfBehelit/Spoofing.kali/assets/154753826/056aa1ba-51f7-400f-a051-69fa823f0ae6)

Una vez creado el script, podemos hacer que se ejecute con un cron de forma automática:
```
    sudo crontab -e
```
```
    ##Sustituir ruta por la ruta en la que se encuentre el script
    @reboot /home/administrador/masquerade.sh
```
![imagen](https://github.com/EndOfBehelit/Spoofing.kali/assets/154753826/bf13804f-180d-43ea-96b0-01b4bc0dcdb9)

- **Reinicio del sistema y comprobación**
Comprobar que tenemos la configuración red correcta, el forwarding activado y el nateo:
  * Reiniciar<br>
      ```
          sudo reboot
      ```
  * IP <br>
  ![imagen](https://github.com/EndOfBehelit/Spoofing.kali/assets/154753826/4aeb46b3-8221-4a30-bd6d-099b877f8b17)
    ```
         ip a
    ```
  * Forwarding <br>
    ```
        cat /proc/sys/net/ipv4/ip_forward
    ```
  * Nateo <br>
    ```
        sudo iptables -nv -t nat -L POSTROUTING
    ```
    ![imagen](https://github.com/EndOfBehelit/Spoofing.kali/assets/154753826/c16142ad-cfeb-4062-91a2-096255fa2907)

## Inicio del ataque starvation
Para el ataque starvation usaremos yersinia, su interfaz gráfica no funciona bien, así que usaremos su consola en fomato visual
```
    sudo apt-get install yersinia
```
```
    sudo yersinia -I
```
![imagen](https://github.com/EndOfBehelit/Spoofing.kali/assets/154753826/aa63a0ea-4fdd-402e-a80d-a18b66f6d813) <br>
Debemos usar el modo DHCP, así que pulsamos `Espacio + F2` <br>
---
![imagen](https://github.com/EndOfBehelit/Spoofing.kali/assets/154753826/5fbda515-0010-42c9-a531-e10fea809567) <br>
Ahora abrimos el menú de ataques con `x` y pulsamos el ataque `1` envío de DHCPDISCOVER <br>
![imagen](https://github.com/EndOfBehelit/Spoofing.kali/assets/154753826/77e0c585-b8d7-438f-bd21-102a7789da94) <br>
El ataque ya ha sido lanzado, podemos dejarlo en ejecución o bien dejarlo un tiempo prudencial en el que le de tiempo a ocupar todas las IPs y luego apagarlo con `l` (L minúscula) <br>
![imagen](https://github.com/EndOfBehelit/Spoofing.kali/assets/154753826/11810f7b-cd3b-4a21-9c0c-6d1adaf3cb76) <br>
Una vez lanzado el ataque y ocupado todas las IPs del servidor DHCP, debemos hacernos pasar nosotros por servidor DHCP. Para ello volvemos al menú con `x` y y elegimos la opción `2` de creación de un servidor DHCP.<br>
![imagen](https://github.com/EndOfBehelit/Spoofing.kali/assets/154753826/4dda990d-ef86-47e4-bebd-754511593c7e) <br>
Configuración del servidor DHCP malicioso: <br>
![imagen](https://github.com/EndOfBehelit/Spoofing.kali/assets/154753826/5eea8c83-558f-4358-a37c-c8a20a4ff225) <br>

## Escucha de información con Wireshark
Una vez alguien trate de conectarse al router original, no tendrá IPs para otorgarle y entonces nosotros le daremos una IP falsa sin que él se percate, este podrá conectarse a internet con normalidad pero a través de nuestro router no del suyo, lo que nos permite escuchar toda su información.
```
    sudo apt install wireshark
```
```
    sudo wireshark
```
Seleccionamos nuestra tarjeta de red interna y podremos ver todos los paquetes enviados y recividos de la máquina engañada.
![imagen](https://github.com/EndOfBehelit/Spoofing.kali/assets/154753826/105fdbd8-fc46-4c29-979e-32fd90ea8473)


