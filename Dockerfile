FROM nginx:latest
EXPOSE 80
EXPOSE 443
COPY ./nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY ./nginx/connio_ssl.conf /etc/nginx/connio_ssl.conf
RUN mkdir /.well-known
RUN mkdir /.well-known/acme-challenge/
RUN mkdir /etc/letsencrypt/
ADD ./run.sh . 
ENTRYPOINT bash run.sh