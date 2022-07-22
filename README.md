Apache Guacamole in Docker
==========================

An all-in-one docker container for Apache Guacamole. This is conceptually
similar to https://github.com/oznu/docker-guacamole, except actually
maintained. Also, instead of Postgres, this uses MySQL which I'm a bit more
familiar with. This also uses supervisord instead. 

The same image definitely works on armhf and amd64, and should also work on
arm64. That said, the performance of something like a low-cost ARM SBC may not
adequate. When dragging around windows, or when orbiting in a 3D program on a
RDP session, I've observed 100% CPU usage on an Odroid XU4, which causes
a significant amount of lag. Running it on a Skylake Intel processor works well
at 60% CPU usage doing the same thing and with no lag.

To run:

```
$ docker build . -t guacamole:1.3
$ docker run -v /data/guacamole:/app/data -p 8080:8080 --name=guacamole -it guacamole:1.3
```

Then you can access the guacamole instance at localhost:8080.
