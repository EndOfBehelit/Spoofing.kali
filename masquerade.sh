#!/bin/bash
sudo iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
