# dokku mongo (beta)

Official mongo plugin for dokku. Currently installs mongo 3.1.6.

## requirements

- dokku 0.3.25+
- docker 1.6.x

## installation

```
cd /var/lib/dokku/plugins
git clone https://github.com/dokku/dokku-mongo.git mongo
dokku plugins-install-dependencies
dokku plugins-install
```

## commands

```
mongo:alias <name> <alias>     Set an alias for the docker link
mongo:clone <name> <new-name>  NOT IMPLEMENTED
mongo:connect <name>           Connect via telnet to a mongo service
mongo:create <name>            Create a mongo service
mongo:destroy <name>           Delete the service and stop its container if there are no links left
mongo:export <name>            NOT IMPLEMENTED
mongo:expose <name> <port>     NOT IMPLEMENTED
mongo:import <name> <file>     NOT IMPLEMENTED
mongo:info <name>              Print the connection information
mongo:link <name> <app>        Link the mongo service to the app
mongo:list                     List all mongo services
mongo:logs <name> [-t]         Print the most recent log(s) for this service
mongo:restart <name>           Graceful shutdown and restart of the service container
mongo:unexpose <name> <port>   NOT IMPLEMENTED
mongo:unlink <name> <app>      Unlink the mongo service from the app
```

## usage

```shell
# create a mongo service named lolipop
dokku mongo:create lolipop

# you can also specify the image and image
# version to use for the service
# it *must* be compatible with the
# official mongo image
export MONGO_IMAGE="mongo"
export MONGO_IMAGE_VERSION="3.0.5"
dokku mongo:create lolipop

# get connection information as follows
dokku mongo:info lolipop

# lets assume the ip of our mongo service is 172.17.0.1

# a mongo service can be linked to a
# container this will use native docker
# links via the docker-options plugin
# here we link it to our 'playground' app
# NOTE: this will restart your app
dokku mongo:link lolipop playground

# the above will expose the following environment variables
#
#   MONGO_URL=mongo://172.17.0.1:27017
#   MONGO_NAME=/playground/DATABASE
#   MONGO_PORT=tcp://172.17.0.1:27017
#   MONGO_PORT_27017_TCP=tcp://172.17.0.1:27017
#   MONGO_PORT_27017_TCP_PROTO=tcp
#   MONGO_PORT_27017_TCP_PORT=27017
#   MONGO_PORT_27017_TCP_ADDR=172.17.0.1

# you can customize the environment
# variables through a custom docker link alias
dokku mongo:alias lolipop MONGO_DATABASE

# you can also unlink a mongo service
# NOTE: this will restart your app
dokku mongo:unlink lolipop playground

# you can tail logs for a particular service
dokku mongo:logs lolipop
dokku mongo:logs lolipop -t # to tail

# finally, you can destroy the container
dokku mongo:destroy playground
```

## todo

- implement mongo:clone
- implement mongo:expose
- implement mongo:import
