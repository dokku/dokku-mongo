# dokku mongo [![Build Status](https://img.shields.io/travis/dokku/dokku-mongo.svg?branch=master "Build Status")](https://travis-ci.org/dokku/dokku-mongo) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)

Official mongo plugin for dokku. Currently defaults to installing [mongo 3.4.9](https://hub.docker.com/_/mongo/).

## requirements

- dokku 0.12.x+
- docker 1.8.x

## installation

```shell
# on 0.4.x+
sudo dokku plugin:install https://github.com/dokku/dokku-mongo.git mongo
```

## commands

```
mongo:app-links <app>          List all mongo service links for a given app
mongo:backup <name> <bucket> (--use-iam) Create a backup of the mongo service to an existing s3 bucket
mongo:backup-auth <name> <aws_access_key_id> <aws_secret_access_key> (<aws_default_region>) (<aws_signature_version>) (<endpoint_url>) Sets up authentication for backups on the mongo service
mongo:backup-deauth <name>     Removes backup authentication for the mongo service
mongo:backup-schedule <name> <schedule> <bucket> Schedules a backup of the mongo service
mongo:backup-schedule-cat <name> Cat the contents of the configured backup cronfile for the service
mongo:backup-set-encryption <name> <passphrase> Set a GPG passphrase for backups
mongo:backup-unschedule <name> Unschedules the backup of the mongo service
mongo:backup-unset-encryption <name> Removes backup encryption for future backups of the mongo service
mongo:clone <name> <new-name>  Create container <new-name> then copy data from <name> into <new-name>
mongo:connect <name>           Connect via telnet to a mongo service
mongo:connect-admin <name>     Connect via telnet to a mongo service as admin user
mongo:create <name>            Create a mongo service with environment variables
mongo:destroy <name>           Delete the service, delete the data and stop its container if there are no links left
mongo:enter <name> [command]   Enter or run a command in a running mongo service container
mongo:exists <service>         Check if the mongo service exists
mongo:export <name> > <file>   Export a dump of the mongo service database
mongo:expose <name> [port]     Expose a mongo service on custom port if provided (random port otherwise)
mongo:import <name> < <file>   Import a dump into the mongo service database
mongo:info <name>              Print the connection information
mongo:link <name> <app>        Link the mongo service to the app
mongo:linked <name> <app>      Check if the mongo service is linked to an app
mongo:list                     List all mongo services
mongo:logs <name> [-t]         Print the most recent log(s) for this service
mongo:promote <name> <app>     Promote service <name> as MONGO_URL in <app>
mongo:restart <name>           Graceful shutdown and restart of the mongo service container
mongo:start <name>             Start a previously stopped mongo service
mongo:stop <name>              Stop a running mongo service
mongo:unexpose <name>          Unexpose a previously exposed mongo service
mongo:unlink <name> <app>      Unlink the mongo service from the app
mongo:upgrade <name>           Upgrade service <service> to the specified version
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

# you can also specify custom environment
# variables to start the mongo service
# in semi-colon separated form
export MONGO_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku mongo:create lolipop

# by default we use the wiredTiger storage solution
# if you are using an image version less than 3.x
# you will need to set a custom MONGO_CONFIG_OPTIONS
# environment variable
export MONGO_CONFIG_OPTIONS=" --auth "
export MONGO_IMAGE_VERSION="2.6.11"
dokku mongo:create lolipop

# get connection information as follows
dokku mongo:info lolipop

# you can also retrieve a specific piece of service info via flags
dokku mongo:info lolipop --config-dir
dokku mongo:info lolipop --data-dir
dokku mongo:info lolipop --dsn
dokku mongo:info lolipop --exposed-ports
dokku mongo:info lolipop --id
dokku mongo:info lolipop --internal-ip
dokku mongo:info lolipop --links
dokku mongo:info lolipop --service-root
dokku mongo:info lolipop --status
dokku mongo:info lolipop --version

# a bash prompt can be opened against a running service
# filesystem changes will not be saved to disk
dokku mongo:enter lolipop

# you may also run a command directly against the service
# filesystem changes will not be saved to disk
dokku mongo:enter lolipop ls -lah /

# a mongo service can be linked to a
# container this will use native docker
# links via the docker-options plugin
# here we link it to our 'playground' app
# NOTE: this will restart your app
dokku mongo:link lolipop playground

# the following environment variables will be set automatically by docker (not
# on the app itself, so they won’t be listed when calling dokku config)
#
#   DOKKU_MONGO_LOLIPOP_NAME=/lolipop/DATABASE
#   DOKKU_MONGO_LOLIPOP_PORT=tcp://172.17.0.1:27017
#   DOKKU_MONGO_LOLIPOP_PORT_27017_TCP=tcp://172.17.0.1:27017
#   DOKKU_MONGO_LOLIPOP_PORT_27017_TCP_PROTO=tcp
#   DOKKU_MONGO_LOLIPOP_PORT_27017_TCP_PORT=27017
#   DOKKU_MONGO_LOLIPOP_PORT_27017_TCP_ADDR=172.17.0.1
#
# and the following will be set on the linked application by default
#
#   MONGO_URL=mongodb://lolipop:SOME_PASSWORD@dokku-mongo-lolipop:27017/lolipop
#
# NOTE: the host exposed here only works internally in docker containers. If
# you want your container to be reachable from outside, you should use `expose`.

# another service can be linked to your app
dokku mongo:link other_service playground

# since DATABASE_URL is already in use, another environment variable will be
# generated automatically
#
#   DOKKU_MONGO_BLUE_URL=mongodb://other_service:ANOTHER_PASSWORD@dokku-mongo-other-service:27017/other_service

# you can then promote the new service to be the primary one
# NOTE: this will restart your app
dokku mongo:promote other_service playground

# this will replace MONGO_URL with the url from other_service and generate
# another environment variable to hold the previous value if necessary.
# you could end up with the following for example:
#
#   MONGO_URL=mongodb://other_service:ANOTHER_PASSWORD@dokku-mongo-other-service:27017/other_service
#   DOKKU_MONGO_BLUE_URL=mongodb://other_service:ANOTHER_PASSWORD@dokku-mongo-other-service:27017/other_service
#   DOKKU_MONGO_SILVER_URL=mongodb://lolipop:SOME_PASSWORD@dokku-mongo-lolipop:27017/lolipop

# you can also unlink a mongo service
# NOTE: this will restart your app and unset related environment variables
dokku mongo:unlink lolipop playground

# you can tail logs for a particular service
dokku mongo:logs lolipop
dokku mongo:logs lolipop -t # to tail

# you can dump the database
dokku mongo:export lolipop > lolipop.dump.gz

# you can import a dump
dokku mongo:import lolipop < database.dump.gz

# you can clone an existing database to a new one
dokku mongo:clone lolipop new_database

# finally, you can destroy the container
dokku mongo:destroy lolipop
```

## Changing database adapter

It's possible to change the protocol for MONGO_URL by setting
the environment variable MONGO_DATABASE_SCHEME on the app:

```
dokku config:set playground MONGO_DATABASE_SCHEME=mongo2
dokku mongo:link lolipop playground
```

Will cause MONGO_URL to be set as
mongo2://lolipop:SOME_PASSWORD@dokku-mongo-lolipop:27017/lolipop

CAUTION: Changing MONGO_DATABASE_SCHEME after linking will cause dokku to
believe the mongo is not linked when attempting to use `dokku mongo:unlink`
or `dokku mongo:promote`.
You should be able to fix this by

- Changing MONGO_URL manually to the new value.

OR

- Set MONGO_DATABASE_SCHEME back to its original setting
- Unlink the service
- Change MONGO_DATABASE_SCHEME to the desired setting
- Relink the service

## Backups

Datastore backups are supported via AWS S3 and S3 compatible services like [minio](https://github.com/minio/minio).

You may skip the `backup-auth` step if your dokku install is running within EC2
and has access to the bucket via an IAM profile. In that case, use the `--use-iam`
option with the `backup` command.

Backups can be performed using the backup commands:

```
# setup s3 backup authentication
dokku mongo:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY

# remove s3 authentication
dokku mongo:backup-deauth lolipop

# backup the `lolipop` service to the `BUCKET_NAME` bucket on AWS
dokku mongo:backup lolipop BUCKET_NAME

# schedule a backup
# CRON_SCHEDULE is a crontab expression, eg. "0 3 * * *" for each day at 3am
dokku mongo:backup-schedule lolipop CRON_SCHEDULE BUCKET_NAME

# cat the contents of the configured backup cronfile for the service
dokku mongo:backup-schedule-cat lolipop

# remove the scheduled backup from cron
dokku mongo:backup-unschedule lolipop
```

Backup auth can also be set up for different regions, signature versions and endpoints (e.g. for minio):
 
```
# setup s3 backup authentication with different region
dokku mongo:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION
 
# setup s3 backup authentication with different signature version and endpoint
dokku mongo:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_SIGNATURE_VERSION ENDPOINT_URL
 
# more specific example for minio auth
dokku mongo:backup-auth lolipop MINIO_ACCESS_KEY_ID MINIO_SECRET_ACCESS_KEY us-east-1 s3v4 https://YOURMINIOSERVICE
```

## Disabling `docker pull` calls

If you wish to disable the `docker pull` calls that the plugin triggers, you may set the `MONGO_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker pull` is disabled.
