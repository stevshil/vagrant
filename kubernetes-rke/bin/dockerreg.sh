#!/bin/bash

mkdir /home/vagrant/certs

# Generate certificates if you plan to use SSL
openssl req \
  -newkey rsa:4096 -nodes -sha256 -keyout /home/vagrant/certs/domain.key \
  -x509 -days 36500 -out /home/vagrant/certs/domain.crt -subj "/C=training/ST=global/L=any/O=training/OU=all/CN=*/"

chown -R vagrant:vagrant /home/vagrant/certs

# Launch container
docker run -itd -p 5000:5000 \
	--name dockerreg \
	-m 40m \
	-v /var/lib/dockerreg:/var/lib/registry \
	-v certs:/certs \
	--restart=always \
	registry:2