# tyler36/ddev-laravel-queue <!-- omit in toc -->

[![tests](https://github.com/tyler36/ddev-laravel-queue/actions/workflows/tests.yml/badge.svg)](https://github.com/tyler36/ddev-laravel-queue/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2024.svg)

- [Introduction](#introduction)
- [Getting Started](#getting-started)
- [What does this add-on do and add?](#what-does-this-add-on-do-and-add)

## Introduction

This add-on allows you to start a Laravel queue worker through the DDEV web service. See [offical Queues documentation](https://laravel.com/docs/9.x/queues) for more details.

## Getting Started

This add-on requires DDEV v1.19.3 or higher.

- Install the DDEV laravel worker add-on:

```shell
ddev get tyler36/ddev-laravel-queue
ddev restart
```

## What does this add-on do and add?

1. Checks to make sure the DDEV version is adequate.
2. Adds `.ddev/web-build/laravel-worker.conf`, which configures the queue worker.
3. Adds `.ddev/web-build/Dockerfile.ddev-laravel-worker`, which adds the worker to supervisor.

 See [Configuring Supervisor](https://laravel.com/docs/master/queues#configuring-supervisor) for the latest recommended settings.

**Contributed and maintained by [tyler36](https://github.com/tyler36)**
