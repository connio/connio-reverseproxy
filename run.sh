#!/bin/sh


CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER"
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    touch $CONTAINER_ALREADY_STARTED
    sed -i -e "s/APP_DOMAIN/$APP_DOMAIN/g" /etc/nginx/conf.d/default.conf
    sed -i -e "s/API_DOMAIN/$API_DOMAIN/g" /etc/nginx/conf.d/default.conf
    sed -i -e "s/DEPLOY_DOMAIN/$DEPLOY_DOMAIN/g" /etc/nginx/connio_ssl.conf
    sed -i -e "s/FLOW_DOMAIN/$FLOW_DOMAIN/g" /etc/nginx/conf.d/default.conf
    sed -i -e "s/DASHBOARD_DOMAIN/$DASHBOARD_DOMAIN/g" /etc/nginx/conf.d/default.conf
    sed -i -e "s/REPORT_DOMAIN/$REPORT_DOMAIN/g" /etc/nginx/conf.d/default.conf
    sed -i -e "s/SSO_DOMAIN/$SSO_DOMAIN/g" /etc/nginx/conf.d/default.conf
    sed -i -e "s/DEPLOY_DOMAIN/$DEPLOY_DOMAIN/g" /etc/nginx/conf.d/default.conf


    (echo "upstream app_backend { server $INTERNAL_APP_HOST:$APP_PORT; }" && cat /etc/nginx/conf.d/default.conf) > default.conf.new1
    (echo "upstream api_backend { server $INTERNAL_API_HOST:$API_PORT; }" && cat ./default.conf.new1) > default.conf.new2
    (echo "upstream flow { server $INTERNAL_FLOW_HOST:$FLOW_PORT; }" && cat ./default.conf.new2) > default.conf.new3
    (echo "upstream dashboard { server $INTERNAL_DASHBOARD_HOST:$DASHBOARD_PORT; }" && cat ./default.conf.new3) > default.conf.new4
    (echo "upstream report { server $INTERNAL_REPORT_HOST:$REPORT_PORT; }" && cat ./default.conf.new4) > default.conf.new5
    (echo "upstream sso { server $INTERNAL_SSO_HOST:$SSO_PORT; }" && cat ./default.conf.new5) > default.conf.new6
    
    mv default.conf.new6 /etc/nginx/conf.d/default.conf
    cat /etc/nginx/conf.d/default.conf
    nginx -g "daemon off;"
else
    nginx -g "daemon off;"
fi