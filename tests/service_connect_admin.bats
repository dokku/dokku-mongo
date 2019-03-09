#!/usr/bin/env bats
load test_helper

setup() {
  export ECHO_DOCKER_COMMAND="false"
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}

teardown() {
  export ECHO_DOCKER_COMMAND="false"
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
}

@test "($PLUGIN_COMMAND_PREFIX:connect-admin) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:connect-admin"
  assert_contains "${lines[*]}" "Please specify a valid name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:connect-admin) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:connect-admin" not_existing_service
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:connect-admin) success" {
  export ECHO_DOCKER_COMMAND="true"
  run dokku "$PLUGIN_COMMAND_PREFIX:connect-admin" l
  password="$(cat "$PLUGIN_DATA_ROOT/l/ROOTPASSWORD")"
  assert_output "docker exec -i -t dokku.mongo.l mongo -u admin -p $password --authenticationDatabase admin l"
}
