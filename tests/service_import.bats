#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
}

teardown() {
  dokku "$PLUGIN_COMMAND_PREFIX:destroy" l -f
  if [[ -d "$PLUGIN_DATA_ROOT/new_service" ]]; then
    dokku "$PLUGIN_COMMAND_PREFIX:destroy" new_service -f
  fi
  rm -f "$BATS_TMPDIR/export.archive"
}

# Reads and writes the record the round trip follows, so that an import is
# judged by the data it moved rather than by the status it exited with.
probe() {
  local action="$1" service="$2" value="${3:-}"
  local password
  password="$(sudo cat "$PLUGIN_DATA_ROOT/$service/PASSWORD")"

  local -a mongo=(
    docker container exec -i "dokku.$PLUGIN_COMMAND_PREFIX.$service"
    mongosh -u "$service" -p "$password" --authenticationDatabase "$service"
    "$service" --quiet --eval
  )

  case "$action" in
  write)
    "${mongo[@]}" "db.probe.deleteMany({}); db.probe.insertOne({value: \"$value\"})" >/dev/null
    ;;
  read)
    "${mongo[@]}" 'db.probe.findOne().value'
    ;;
  *)
    echo "unknown probe action $action" >&2
    return 1
    ;;
  esac
}

@test "($PLUGIN_COMMAND_PREFIX:import) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:import"
  assert_contains "${lines[*]}" "Please specify a valid name for the service"
  assert_failure
}

@test "($PLUGIN_COMMAND_PREFIX:import) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:import" not_existing_service
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
  assert_failure
}

@test "($PLUGIN_COMMAND_PREFIX:import) error when data is not provided" {
  if [[ -n "$GITHUB_WORKFLOW" ]]; then
    skip "No tty is available on Github Actions"
  fi
  run dokku "$PLUGIN_COMMAND_PREFIX:import" l
  assert_contains "${lines[*]}" "No data provided on stdin"
  assert_failure
}

@test "($PLUGIN_COMMAND_PREFIX:import) round trip" {
  dokku "$PLUGIN_COMMAND_PREFIX:create" new_service

  # the destination holds a record of its own, so reading the source's value
  # back afterwards says the import replaced rather than merged
  probe write l known
  probe write new_service clobbered

  dokku "$PLUGIN_COMMAND_PREFIX:export" l >"$BATS_TMPDIR/export.archive"
  [[ -s "$BATS_TMPDIR/export.archive" ]]

  run dokku "$PLUGIN_COMMAND_PREFIX:import" new_service <"$BATS_TMPDIR/export.archive"
  echo "output: $output"
  echo "status: $status"
  assert_success

  run probe read new_service
  assert_output "known"
}
