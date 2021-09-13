# dokku mongo [![Build Status](https://img.shields.io/github/workflow/status/dokku/dokku-mongo/CI/master?style=flat-square "Build Status")](https://github.com/dokku/dokku-mongo/actions/workflows/ci.yml?query=branch%3Amaster) [![IRC Network](https://img.shields.io/badge/irc-libera-blue.svg?style=flat-square "IRC Libera")](https://webchat.libera.chat/?channels=dokku)

Official mongo plugin for dokku. Currently defaults to installing [mongo 5.0.2](https://hub.docker.com/_/mongo/).

## Requirements

- dokku 0.19.x+
- docker 1.8.x

## Installation

```shell
# on 0.19.x+
sudo dokku plugin:install https://github.com/dokku/dokku-mongo.git mongo
```

## Commands

```
mongo:app-links <app>                              # list all mongo service links for a given app
mongo:backup <service> <bucket-name> [--use-iam]   # creates a backup of the mongo service to an existing s3 bucket
mongo:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url> # sets up authentication for backups on the mongo service
mongo:backup-deauth <service>                      # removes backup authentication for the mongo service
mongo:backup-schedule <service> <schedule> <bucket-name> [--use-iam] # schedules a backup of the mongo service
mongo:backup-schedule-cat <service>                # cat the contents of the configured backup cronfile for the service
mongo:backup-set-encryption <service> <passphrase> # sets encryption for all future backups of mongo service
mongo:backup-unschedule <service>                  # unschedules the backup of the mongo service
mongo:backup-unset-encryption <service>            # unsets encryption for future backups of the mongo service
mongo:clone <service> <new-service> [--clone-flags...] # create container <new-name> then copy data from <name> into <new-name>
mongo:connect <service>                            # connect to the service via the mongo connection tool
mongo:connect-admin <service>                      # connect via mongo to a mongo service as admin user
mongo:create <service> [--create-flags...]         # create a mongo service
mongo:destroy <service> [-f|--force]               # delete the mongo service/data/container if there are no links left
mongo:enter <service>                              # enter or run a command in a running mongo service container
mongo:exists <service>                             # check if the mongo service exists
mongo:export <service>                             # export a dump of the mongo service database
mongo:expose <service> <ports...>                  # expose a mongo service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)
mongo:import <service>                             # import a dump into the mongo service database
mongo:info <service> [--single-info-flag]          # print the service information
mongo:link <service> <app> [--link-flags...]       # link the mongo service to the app
mongo:linked <service> <app>                       # check if the mongo service is linked to an app
mongo:links <service>                              # list all apps linked to the mongo service
mongo:list                                         # list all mongo services
mongo:logs <service> [-t|--tail]                   # print the most recent log(s) for this service
mongo:promote <service> <app>                      # promote service <service> as MONGO_URL in <app>
mongo:restart <service>                            # graceful shutdown and restart of the mongo service container
mongo:start <service>                              # start a previously stopped mongo service
mongo:stop <service>                               # stop a running mongo service
mongo:unexpose <service>                           # unexpose a previously exposed mongo service
mongo:unlink <service> <app>                       # unlink the mongo service from the app
mongo:upgrade <service> [--upgrade-flags...]       # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to mongo:help. Please consult the `mongo:help` command for any undocumented commands.

### Basic Usage

### create a mongo service

```shell
# usage
dokku mongo:create <service> [--create-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: ` --storageEngine wiredTiger --auth `)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-m|--memory MEMORY`: container memory limit (default: unlimited)
- `-p|--password PASSWORD`: override the user-level service password
- `-r|--root-password PASSWORD`: override the root-level service password

Create a mongo service named lolipop:

```shell
dokku mongo:create lolipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the mongo image.

```shell
export MONGO_IMAGE="mongo"
export MONGO_IMAGE_VERSION="${PLUGIN_IMAGE_VERSION}"
dokku mongo:create lolipop
```

You can also specify custom environment variables to start the mongo service in semi-colon separated form.

```shell
export MONGO_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku mongo:create lolipop
```

### print the service information

```shell
# usage
dokku mongo:info <service> [--single-info-flag]
```

flags:

- `--config-dir`: show the service configuration directory
- `--data-dir`: show the service data directory
- `--dsn`: show the service DSN
- `--exposed-ports`: show service exposed ports
- `--id`: show the service container id
- `--internal-ip`: show the service internal ip
- `--links`: show the service app links
- `--service-root`: show the service root directory
- `--status`: show the service running status
- `--version`: show the service image version

Get connection information as follows:

```shell
dokku mongo:info lolipop
```

You can also retrieve a specific piece of service info via flags:

```shell
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
```

### list all mongo services

```shell
# usage
dokku mongo:list 
```

List all services:

```shell
dokku mongo:list
```

### print the most recent log(s) for this service

```shell
# usage
dokku mongo:logs <service> [-t|--tail]
```

flags:

- `-t|--tail`: do not stop when end of the logs are reached and wait for additional output

You can tail logs for a particular service:

```shell
dokku mongo:logs lolipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku mongo:logs lolipop --tail
```

### link the mongo service to the app

```shell
# usage
dokku mongo:link <service> <app> [--link-flags...]
```

flags:

- `-a|--alias "BLUE_DATABASE"`: an alternative alias to use for linking to an app via environment variable
- `-q|--querystring "pool=5"`: ampersand delimited querystring arguments to append to the service link

A mongo service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our `playground` app.

> NOTE: this will restart your app

```shell
dokku mongo:link lolipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won’t be listed when calling dokku config):

```
DOKKU_MONGO_LOLIPOP_NAME=/lolipop/DATABASE
DOKKU_MONGO_LOLIPOP_PORT=tcp://172.17.0.1:27017
DOKKU_MONGO_LOLIPOP_PORT_27017_TCP=tcp://172.17.0.1:27017
DOKKU_MONGO_LOLIPOP_PORT_27017_TCP_PROTO=tcp
DOKKU_MONGO_LOLIPOP_PORT_27017_TCP_PORT=27017
DOKKU_MONGO_LOLIPOP_PORT_27017_TCP_ADDR=172.17.0.1
```

The following will be set on the linked application by default:

```
MONGO_URL=mongodb://lolipop:SOME_PASSWORD@dokku-mongo-lolipop:27017/lolipop
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the `expose` subcommand. Another service can be linked to your app:

```shell
dokku mongo:link other_service playground
```

It is possible to change the protocol for `MONGO_URL` by setting the environment variable `MONGO_DATABASE_SCHEME` on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding.

```shell
dokku config:set playground MONGO_DATABASE_SCHEME=mongodb2
dokku mongo:link lolipop playground
```

This will cause `MONGO_URL` to be set as:

```
mongodb2://lolipop:SOME_PASSWORD@dokku-mongo-lolipop:27017/lolipop
```

### unlink the mongo service from the app

```shell
# usage
dokku mongo:unlink <service> <app>
```

You can unlink a mongo service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku mongo:unlink lolipop playground
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### connect to the service via the mongo connection tool

```shell
# usage
dokku mongo:connect <service>
```

Connect to the service via the mongo connection tool:

```shell
dokku mongo:connect lolipop
```

### enter or run a command in a running mongo service container

```shell
# usage
dokku mongo:enter <service>
```

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk.

```shell
dokku mongo:enter lolipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk.

```shell
dokku mongo:enter lolipop touch /tmp/test
```

### expose a mongo service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)

```shell
# usage
dokku mongo:expose <service> <ports...>
```

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku mongo:expose lolipop 27017 27018 27019 28017
```

Expose the service on the service's normal ports, with the first on a specified ip adddress (127.0.0.1):

```shell
dokku mongo:expose lolipop 127.0.0.1:27017 27018 27019 28017
```

### unexpose a previously exposed mongo service

```shell
# usage
dokku mongo:unexpose <service>
```

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku mongo:unexpose lolipop
```

### promote service <service> as MONGO_URL in <app>

```shell
# usage
dokku mongo:promote <service> <app>
```

If you have a mongo service linked to an app and try to link another mongo service another link environment variable will be generated automatically:

```
DOKKU_MONGO_BLUE_URL=mongodb://other_service:ANOTHER_PASSWORD@dokku-mongo-other-service:27017/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku mongo:promote other_service playground
```

This will replace `MONGO_URL` with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
MONGO_URL=mongodb://other_service:ANOTHER_PASSWORD@dokku-mongo-other-service:27017/other_service
DOKKU_MONGO_BLUE_URL=mongodb://other_service:ANOTHER_PASSWORD@dokku-mongo-other-service:27017/other_service
DOKKU_MONGO_SILVER_URL=mongodb://lolipop:SOME_PASSWORD@dokku-mongo-lolipop:27017/lolipop
```

### start a previously stopped mongo service

```shell
# usage
dokku mongo:start <service>
```

Start the service:

```shell
dokku mongo:start lolipop
```

### stop a running mongo service

```shell
# usage
dokku mongo:stop <service>
```

Stop the service and the running container:

```shell
dokku mongo:stop lolipop
```

### graceful shutdown and restart of the mongo service container

```shell
# usage
dokku mongo:restart <service>
```

Restart the service:

```shell
dokku mongo:restart lolipop
```

### upgrade service <service> to the specified versions

```shell
# usage
dokku mongo:upgrade <service> [--upgrade-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: ` --storageEngine wiredTiger --auth `)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-R|--restart-apps "true"`: whether to force an app restart

You can upgrade an existing service to a new image or image-version:

```shell
dokku mongo:upgrade lolipop
```

### Service Automation

Service scripting can be executed using the following commands:

### list all mongo service links for a given app

```shell
# usage
dokku mongo:app-links <app>
```

List all mongo services that are linked to the `playground` app.

```shell
dokku mongo:app-links playground
```

### create container <new-name> then copy data from <name> into <new-name>

```shell
# usage
dokku mongo:clone <service> <new-service> [--clone-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: ` --storageEngine wiredTiger --auth `)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-m|--memory MEMORY`: container memory limit (default: unlimited)
- `-p|--password PASSWORD`: override the user-level service password
- `-r|--root-password PASSWORD`: override the root-level service password

You can clone an existing service to a new one:

```shell
dokku mongo:clone lolipop lolipop-2
```

### check if the mongo service exists

```shell
# usage
dokku mongo:exists <service>
```

Here we check if the lolipop mongo service exists.

```shell
dokku mongo:exists lolipop
```

### check if the mongo service is linked to an app

```shell
# usage
dokku mongo:linked <service> <app>
```

Here we check if the lolipop mongo service is linked to the `playground` app.

```shell
dokku mongo:linked lolipop playground
```

### list all apps linked to the mongo service

```shell
# usage
dokku mongo:links <service>
```

List all apps linked to the `lolipop` mongo service.

```shell
dokku mongo:links lolipop
```

### Data Management

The underlying service data can be imported and exported with the following commands:

### import a dump into the mongo service database

```shell
# usage
dokku mongo:import <service>
```

Import a datastore dump:

```shell
dokku mongo:import lolipop < database.dump
```

### export a dump of the mongo service database

```shell
# usage
dokku mongo:export <service>
```

By default, datastore output is exported to stdout:

```shell
dokku mongo:export lolipop
```

You can redirect this output to a file:

```shell
dokku mongo:export lolipop > lolipop.dump
```

### Backups

Datastore backups are supported via AWS S3 and S3 compatible services like [minio](https://github.com/minio/minio).

You may skip the `backup-auth` step if your dokku install is running within EC2 and has access to the bucket via an IAM profile. In that case, use the `--use-iam` option with the `backup` command.

Backups can be performed using the backup commands:

### sets up authentication for backups on the mongo service

```shell
# usage
dokku mongo:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url>
```

Setup s3 backup authentication:

```shell
dokku mongo:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
```

Setup s3 backup authentication with different region:

```shell
dokku mongo:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION
```

Setup s3 backup authentication with different signature version and endpoint:

```shell
dokku mongo:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_SIGNATURE_VERSION ENDPOINT_URL
```

More specific example for minio auth:

```shell
dokku mongo:backup-auth lolipop MINIO_ACCESS_KEY_ID MINIO_SECRET_ACCESS_KEY us-east-1 s3v4 https://YOURMINIOSERVICE
```

### removes backup authentication for the mongo service

```shell
# usage
dokku mongo:backup-deauth <service>
```

Remove s3 authentication:

```shell
dokku mongo:backup-deauth lolipop
```

### creates a backup of the mongo service to an existing s3 bucket

```shell
# usage
dokku mongo:backup <service> <bucket-name> [--use-iam]
```

flags:

- `-u|--use-iam`: use the IAM profile associated with the current server

Backup the `lolipop` service to the `my-s3-bucket` bucket on `AWS`:`

```shell
dokku mongo:backup lolipop my-s3-bucket --use-iam
```

Restore a backup file (assuming it was extracted via `tar -xf backup.tgz`):

```shell
dokku mongo:import lolipop < backup-folder/export
```

### sets encryption for all future backups of mongo service

```shell
# usage
dokku mongo:backup-set-encryption <service> <passphrase>
```

Set the GPG-compatible passphrase for encrypting backups for backups:

```shell
dokku mongo:backup-set-encryption lolipop
```

### unsets encryption for future backups of the mongo service

```shell
# usage
dokku mongo:backup-unset-encryption <service>
```

Unset the `GPG` encryption passphrase for backups:

```shell
dokku mongo:backup-unset-encryption lolipop
```

### schedules a backup of the mongo service

```shell
# usage
dokku mongo:backup-schedule <service> <schedule> <bucket-name> [--use-iam]
```

flags:

- `-u|--use-iam`: use the IAM profile associated with the current server

Schedule a backup:

> 'schedule' is a crontab expression, eg. "0 3 * * *" for each day at 3am

```shell
dokku mongo:backup-schedule lolipop "0 3 * * *" my-s3-bucket
```

Schedule a backup and authenticate via iam:

```shell
dokku mongo:backup-schedule lolipop "0 3 * * *" my-s3-bucket --use-iam
```

### cat the contents of the configured backup cronfile for the service

```shell
# usage
dokku mongo:backup-schedule-cat <service>
```

Cat the contents of the configured backup cronfile for the service:

```shell
dokku mongo:backup-schedule-cat lolipop
```

### unschedules the backup of the mongo service

```shell
# usage
dokku mongo:backup-unschedule <service>
```

Remove the scheduled backup from cron:

```shell
dokku mongo:backup-unschedule lolipop
```

### Disabling `docker pull` calls

If you wish to disable the `docker pull` calls that the plugin triggers, you may set the `MONGO_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker pull` is disabled.
