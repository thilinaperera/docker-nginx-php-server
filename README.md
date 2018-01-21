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
docker service create --name nginx-php-server -p 80:80 -p 443:443 --mount "type=bind,source=/local_folder_path,target=/usr/share/nginx/html" thilinaperera/nginx-php-server
```