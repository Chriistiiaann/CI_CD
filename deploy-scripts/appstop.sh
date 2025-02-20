#!/bin/bash
exec > /tmp/appstop.log 2>&1
echo "Deteniendo Tomcat..."

systemctl stop tomcat

echo "Tomcat detenido."
