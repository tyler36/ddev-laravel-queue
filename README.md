[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/tyler36/ddev-laravel-queue/actions/workflows/tests.yml/badge.svg)](https://github.com/tyler36/ddev-laravel-queue/actions/workflows/tests.yml)
[![last commit](https://img.shields.io/github/last-commit/tyler36/ddev-laravel-queue)](https://github.com/tyler36/ddev-laravel-queue/commits)
[![release](https://img.shields.io/github/v/release/tyler36/ddev-laravel-queue)](https://github.com/tyler36/ddev-laravel-queue/releases/latest)

# DDEV Laravel Queue

## Overview

This add-on runs a Laravel queue worker inside the DDEV web container.
This add-on is recommended for `QUEUE_CONNECTION=database` environments.

See [official Queues documentation](https://laravel.com/docs/master/queues) for more details.

## Installation

```shell
ddev add-on get tyler36/ddev-laravel-queue
ddev restart
```

After installation, make sure to commit the `.ddev` directory to version control.

## Usage

The queue worker automatically runs as a background daemon inside the container. No configuration is required.
To view queue worker output, check the web container logs.

```shell
$ ddev logs -s web
...
2025-09-19 09:12:23,817 INFO spawned: 'queue-1' with pid 1666
2025-09-19 09:12:27,571 INFO success: queue-1 entered RUNNING state, process has stayed up for > than 3 seconds (startsecs)
...
2025-09-19 00:16:13 App\Events\TaskUpdated ....................................................................... RUNNING
2025-09-19 00:16:13 App\Events\TaskUpdated ....................................................................... 73.82ms DONE
```

## Configuration

`.ddev/config.laravel-workers.yaml` starts the queue work daemon.
It uses the following configuration settings:

- `--sleep=3` : This option tells the queue worker to sleep for 3 seconds between polling for new jobs when the queue is empty.
- `--tries=3` : This option specifies that if a job fails, the worker should try to process the job up to three times before sending it to a failed—jobs storage.
- `sleep 1` : After processing a job, the script pauses for 1 second before re—checking conditions in the loop; this reduces CPU usage by preventing the loop from running too aggressively .

To configure this add-on, remove `#ddev-generated` from `.ddev/config.laravel-workers.yaml` and edit the file as required.

## Credits

**Contributed and maintained by [tyler36](https://github.com/tyler36)**
