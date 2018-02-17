# Docker NGiNX PHP server
## Included configurations
- NGiNX 1.13.7
- PHP-FPM 7.2.x

#### Docker hub image 
Use `docker pull thilinaperera/nginx-php-server` to get new or modified image.

#### Create your own image
```Dockerfile
docker build -t <image-name> .
docker tag <IMAGE ID> yourhubusername/reponame
docker push yourhubusername/reponame
```
#### Use as a service (Docker swarm mode)
```
docker service create \
--name nginx-php-server \
-p 80:80 -p 443:443 \
--mount "type=bind,source=/local_folder_path,target=/usr/share/nginx/html" \
--mount "type=bind,source=/local_server_blocks_configs_folder_path,target=/etc/nginx/custom-sites" \
thilinaperera/nginx-php-server
```

Default server block (Virtual Host) config
```
server {
    listen   80; ## listen for ipv4; this line is default and implied
    listen   443 ssl;
    listen   [::]:80 default ipv6only=on; ## listen for ipv6

    root /usr/share/nginx/html;
    index index.php index.html index.htm;

    # Make site accessible from http://localhost/
    server_name _;

    include      /etc/nginx/common-configs/nginx-wp-common.conf;
}
```