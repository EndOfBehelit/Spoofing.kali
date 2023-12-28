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
Una vez creado el script, podemos hacer que se ejecute con un cron de forma automática:
```
    sudo crontab -e
```
```
    ##Sustituir ruta por la ruta en la que se encuentre el script
    @reboot /home/administrador/masquerade.sh
```
- **Reinicio del sistema y comprobación**
Comprobar que tenemos la configuración red correcta, el forwarding activado y el nateo:
  * IP <br>
    ```
         ip a
    ```
        ![imagen](https://github.com/EndOfBehelit/Spoofing.kali/assets/154753826/4aeb46b3-8221-4a30-bd6d-099b877f8b17)

  * Forwarding <br>
    ```
        cat /proc/sys/net/ipv4/ip_forward
    ```
  * Nateo <br>
    ```
        sudo iptables -nv -t nat -L POSTROUTING
    ```
![imagen](https://github.com/EndOfBehelit/Spoofing.kali/assets/154753826/c16142ad-cfeb-4062-91a2-096255fa2907)
