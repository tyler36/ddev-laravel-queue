#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

  # Override this variable for your add-on:
  export GITHUB_REPO=tyler36/ddev-laravel-queue

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p ~/tmp
  export TESTDIR=$(mktemp -d ~/tmp/${PROJNAME}.XXXXXX)
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site
  assert_success
  run ddev start -y
  assert_success
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  # Persist TESTDIR if running inside GitHub Actions. Useful for uploading test result artifacts
  # See example at https://github.com/ddev/github-action-add-on-test#preserving-artifacts
  if [ -n "${GITHUB_ENV:-}" ]; then
    [ -e "${GITHUB_ENV:-}" ] && echo "TESTDIR=${HOME}/tmp/${PROJNAME}" >> "${GITHUB_ENV}"
  else
    [ "${TESTDIR}" != "" ] && rm -rf "${TESTDIR}"
  fi
}

health_checks() {
  ddev exec "curl -s https://web/"
}

queue_checks() {
  set -eu -o pipefail

  # Add a route that dispatches a job when hit
  echo "Route::get('test-dispatch', function () {
    logger('accessing test-dispatch ...');

    dispatch(function () {
        logger('hello from test-dispatch');
    });
});" >> ./routes/web.php

  # Visit the new route to trigger the dispatch
  ddev exec "curl -s https://web/test-dispatch"
  # We'll wait a few seconds to allow the queue worker to pick and process the job.
  sleep 10

  if ! grep -q "hello from test-dispatch" ./storage/logs/laravel.log; then
    exit 1;
  fi
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}

  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success

  run ddev restart -y
  assert_success

  health_checks
}

@test "it processes jobs in Laravel" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3

  # Setup a Laravel project
  run ddev config --project-type=laravel --docroot=public
  assert_success
  run ddev composer create --prefer-dist laravel/laravel
  assert_success
  run ddev exec "php artisan key:generate"
  assert_success

  run ddev add-on get "${DIR}"
  assert_success

  run ddev restart -y
  assert_success

  health_checks
}

@test "it cleans up files from pre-release versions" {
  set -eu -o pipefail
  cd ${TESTDIR}

  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3

  # Create fake pre-release files
  files="
  .ddev/web-build/Dockerfile.ddev-laravel-worker
  .ddev/web-build/laravel-worker.conf
  "
  for file in $files; do
    echo '#ddev-generated' > $file
    if grep -q -v '#ddev-generated' $file; then
      echo 'Fake pre-release file should exist but does NOT.'
      exit 1
    fi
  done

  # Install the current release of the addon, which should remove the pre-release files.
  run ddev add-on get "${DIR}"
  assert_success

  run ddev restart -y
  assert_success

  health_checks

  # Check pre-release files were removed
  for file in $files; do
    if grep -q '#ddev-generated' $file; then
      echo 'Fake pre-release file exists but should NOT.'
      exit 1
    fi
  done
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"
  assert_success

  run ddev restart -y
  assert_success

  health_checks
}
