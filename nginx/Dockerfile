FROM nginx:alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY ./static /usr/share/nginx/html/static
COPY nginx.conf /etc/nginx/conf.d/