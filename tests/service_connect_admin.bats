#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l
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
  skip "Connect hangs indefinitely without input"
  run dokku "$PLUGIN_COMMAND_PREFIX:connect-admin" l
  assert_success
}
