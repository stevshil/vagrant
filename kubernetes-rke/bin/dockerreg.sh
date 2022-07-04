#!/bin/bash

# Generate certificates if you plan to use SSL
openssl req \
  -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key \
  -x509 -days 36500 -out certs/domain.crt

# Launch container
docker run -itd -p 5000:5000 \
	--name dockerreg \
	-m 40m \
	-v /var/lib/dockerreg:/var/lib/registry \
	-v certs:/certs \
	--restart=always \
	registry:2
