FROM nginx:alpine

WORKDIR /usr/share/nginx/html
COPY docs .

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
