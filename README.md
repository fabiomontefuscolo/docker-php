# PHP

A PHP image extended to bundle libraries commonly used in PHP projects. The following
libraires are included:

* libpng12
* libjpeg
* libmemcached
* libmcrypt
* gd
* mysqli
* opcache
* zip
* mbstring
* mcrypt
* memcache
* memcached
* xdebug


## Usage

### Simple server

```
docker run --name elephant -v /path/to/project:/var/www/html -d hacklabr/php
```


### Development with Atom and php-debug

When creating your container, enable XDebug by setting env variable `XDEBUG`

```
docker run --name elephant -e XDEBUG=1 -v /path/to/project:/var/www/html -d hacklabr/php
```

Tell your Atom about folder mapping by editin `config.cson`. You have to configure the
section called "php-debug". It should look like this:

```
  "php-debug":
    PathMaps: [
      "remotepath;localpath"
      "/var/www/html/;/home/fabio/devel/catraca/src/"
    ]
    PhpException:
      CatchableFatalError: false
      Deprecated: false
      FatalError: false
      Notice: false
      ParseError: false
      StrictStandards: false
      UnknownError: false
      Warning: false
      Xdebug: false
    ServerPort: 9000
```


### Extending with new configurations

You can extend this image with a Dockerfile. Imagine you want to let your user
upload 2GB files.


```
FROM hacklab/php
LABEL mantainer "Hacklab <contato@hacklab.com.br>"

RUN {                                      \
        echo "file_uploads = On";          \
        echo "upload_max_filesize = 2048M";\
        echo "post_max_size = 2048M";      \
        echo "max_file_uploads = 20";      \
    } > /usr/local/etc/php/conf.d/docker-max-upload.ini

USER root
```

