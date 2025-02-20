#!/bin/bash
exec > /tmp/appstart.log 2>&1

useradd -m -d /opt/tomcat -U -s /bin/false tomcat

apt update
apt upgrade -y
apt install openjdk-21-jdk -y

apt install ruby-full -y
apt install wget -y
cd /home/ubuntu
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
./install auto

cd /tmp
wget https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.3/bin/apache-tomcat-11.0.3.tar.gz
tar xzvf apache-tomcat-11*tar.gz -C /opt/tomcat --strip-components=1

chown -R tomcat:tomcat /opt/tomcat/
chmod -R u+x /opt/tomcat/bin

sed -i '/<\/tomcat-users>/i \
<role rolename="manager-gui" />\n<user username="manager" password="manager_password" roles="manager-gui" />\n<role rolename="admin-gui" />\n<user username="admin" password="admin_password" roles="manager-gui,admin-gui" />' /opt/tomcat/conf/tomcat-users.xml

sed -i '/<Valve /,/\/>/ s|<Valve|<!--<Valve|; /<Valve /,/\/>/ s|/>|/>-->|' /opt/tomcat/webapps/manager/META-INF/context.xml
sed -i '/<Valve /,/\/>/ s|<Valve|<!--<Valve|; /<Valve /,/\/>/ s|/>|/>-->|' /opt/tomcat/webapps/host-manager/META-INF/context.xml

echo '[Unit]
Description=Tomcat
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-1.21.0-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/tomcat.service

systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat

chmod 777 /opt
cd /opt
git clone https://github.com/Chriistiiaann/studentify.git
cd studentify

chmod +x gradlew
./gradlew build -x test

cp build/libs/studentify-1.0.0.war /opt/tomcat/webapps/studentify.war
chown tomcat:tomcat /opt/tomcat/webapps/studentify.war

systemctl restart tomcat
sleep 10

ls -l /opt/tomcat/webapps/ >> /tmp/appstart.log

/usr/local/bin/cfn-signal -e $? --stack ${AWS::StackName} --resource InstanciaEC2 --region ${AWS::Region}