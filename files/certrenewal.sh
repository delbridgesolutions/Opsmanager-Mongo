#!/bin/bash

# renew cert
certbot renew --dns-route53 --dns-route53-propagation-seconds 60

# combine latest letsencrypt files for mongo

# find latest fullchain.pem
newestFull=$(ls -v /etc/letsencrypt/live/staging*/fullchain.pem | tail -n 1)
echo "$newestFull"

# find latest privkey.pem
newestPriv=$(ls -v /etc/letsencrypt/live/staging*/privkey.pem | tail -n 1)
echo "$newestPriv"

# combine to mongo.pem
sudo cat {$newestFull,$newestPriv} | sudo tee /etc/pki/tls/certs/mongo.pem
