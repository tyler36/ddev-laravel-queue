setup() {
  set -eu -o pipefail

  export DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)/.."
  export TESTDIR=~/tmp/test-laravel-queue
  mkdir -p $TESTDIR
  export PROJNAME=test-laravel-queue
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME}
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
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
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev config --project-name=${PROJNAME}
  ddev start -y >/dev/null
  ddev add-on get ${DIR}
  ddev restart
  health_checks
}

@test "it processes jobs in Lavarel 11" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  # Setup a Laravel project
  ddev config --project-type=laravel --docroot=public
  ddev composer create --prefer-dist laravel/laravel:^11
  ddev exec "php artisan key:generate"
  # Get addon and test
  ddev add-on get ${DIR}
  ddev restart

  queue_checks
}

@test "it cleans up files from pre-release versions" {
  set -eu -o pipefail
  cd ${TESTDIR}
  # echo "# ddev add-on get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev config --project-name=${PROJNAME}
  ddev start -y >/dev/null

  # Create fake pre-release files
  files="
  .ddev/web-build/Dockerfile.ddev-laravel-worker
  .ddev/web-build/laravel-worker.conf
  "
  for file in $files; do
    echo '#ddev-generated' > $file
    if grep -q -v '#ddev-generated' $file; then
      echo 'Fake prelease file should exist but does NOT.'
      exit 1
    fi
  done

  # Install the current release of the addon, which should remove the pre-release files.
  ddev add-on get ${DIR}
  ddev restart
  health_checks

  # Check pre-release files were removed
  for file in $files; do
    if grep -q '#ddev-generated' $file; then
      echo 'Fake prelease file exists but should NOT.'
      exit 1
    fi
  done
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev add-on get tyler36/ddev-laravel-queue with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev config --project-name=${PROJNAME}
  ddev start -y >/dev/null
  ddev add-on get tyler36/ddev-laravel-queue
  ddev restart >/dev/null
  health_checks
}
