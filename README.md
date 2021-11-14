Apache Guacamole in Docker
==========================

An all-in-one docker container for Apache Guacamole. This is conceptually
similar to https://github.com/oznu/docker-guacamole, except actually
maintained. Also, instead of Postgres, this uses MySQL which I'm a bit more
familiar with. This also uses supervisord instead. Further, theoretically the
Dockerfile should work across both armhf, arm64, and amd64. That said, I've
only tested on armhf.

To run:

```
$ docker build . -t guacamole:1.3
$ docker run -v /data/guacamole:/app/data -p 8080:8080 --name=guacamole -it guacamole:1.3
```

Then you can access the guacamole instance at localhost:8080.
