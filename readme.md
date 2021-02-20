# Connio NGINX load balancer
This is a docker image for load balancing connio. 
## Using the container
Certbot needs to be installed on the server for ssl certificate creation and automated certificate renevals. 

You can follow the official installation guide at https://certbot.eff.org/lets-encrypt/ubuntubionic-nginx until step 6.

Create `.well-known/acme-challenge/` directory inside `/opt/connio/` . This will be used by certbot and the load balancer to confirm that we own the domain.

Change connio_solo.yaml to include the connio load balancer image. Make sure to change connio_app listen ports so that the load balancer can bind to ports 80 and 443. Make sure the environmental variables for ports and subdomains are correct.


```
proxy:
    image: "quitra/connio-nginx-test"
    ports:
      - '80:80'
      - '443:443'
    restart: "always"
    networks:
      - connio
    environment:      
      DEPLOY_DOMAIN: ${DEPLOY_DOMAIN}
      API_PORT: "8081"
      API_DOMAIN: api.${DEPLOY_DOMAIN}
      APP_PORT: "8082"
      APP_DOMAIN: app.${DEPLOY_DOMAIN}
      FLOW_PORT: "8083"
      FLOW_DOMAIN: flow.${DEPLOY_DOMAIN}
      DASHBOARD_PORT: "8084"
      DASHBOARD_DOMAIN: dashboard.${DEPLOY_DOMAIN}
      REPORT_PORT: "8085"
      REPORT_DOMAIN: report.${DEPLOY_DOMAIN}
      SSO_PORT: "8086"
      SSO_DOMAIN: sso.${DEPLOY_DOMAIN}
      INTERNAL_APP_HOST: ${SYS_LOCAL_IP}
      INTERNAL_API_HOST: ${SYS_LOCAL_IP}
      INTERNAL_MQTT_HOST: ${SYS_LOCAL_IP}
      INTERNAL_SSO_HOST: ${SYS_LOCAL_IP}
      INTERNAL_FLOW_HOST: ${SYS_LOCAL_IP}
      INTERNAL_DASHBOARD_HOST: ${SYS_LOCAL_IP}
      INTERNAL_REPORT_HOST: ${SYS_LOCAL_IP}
    volumes:
      - /etc/letsencrypt/:/etc/letsencrypt/
      - /opt/connio/.well-known/acme-challenge:/.well-known/acme-challenge/
```

Note that `SYS_LOCAL_IP` environment variable is `localhost` most of the time but you can change it if your system's local IP assigned differently.

Make sure no container or application is bound to port 80 at this point. It will be used by certbot to create our first certificate manually.

Before starting the containers, use command `certbot certonly` to create your first certificate. The load balancer will not start without a certificate. Select `1.Spin up a temporary webserver` as the ACME auth method. Enter the domain names starting with the deploy domain when asked (`deploydomain.com` before `app.deploydomain.com` and others).

e.g.

```
aryaplatform.com app.aryaplatform.com api.aryaplatform.com mqtt.aryaplatform.com sso.aryaplatform.com dash.aryaplatform.com flow.aryaplatform.com report.aryaplatform.com
```

If everything went well, certbot shoud create a certificate file in a directory similar to `/etc/letsencrypt/live/aryaplatform.com/privkey.pem`.

Now, starting the container should use this certificate and start properly. Confirm that the Connio app can be reached using port 443.

Now that the server is up, we should change our authentication method to use our load balancer as the web server in future certificate renewals.

Run `certbot certonly --cert-name deploydomain.com --force-renewal -a webroot -w /opt/connio` after starting the container, this will change the authentication method and renew the certificate. 

Run `sudo certbot renew --dry-run` to make sure there is no problem with renewing our certificate.

If everything works, add following to crontab for automated renewals.
`10 0 * * * certbot renew; docker service update --force connio_solo_proxy`

As a final step, you can also check the newly created certificates using https://decoder.link/

# Building Docker Container

`docker build --tag conniot/reverseproxy .`
