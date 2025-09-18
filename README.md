# tyler36/ddev-laravel-queue <!-- omit in toc -->

[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/tyler36/ddev-laravel-queue/actions/workflows/tests.yml/badge.svg)](https://github.com/tyler36/ddev-laravel-queue/actions/workflows/tests.yml)
[![last commit](https://img.shields.io/github/last-commit/tyler36/ddev-laravel-queue)](https://github.com/tyler36/ddev-laravel-queue/commits)
[![release](https://img.shields.io/github/v/release/tyler36/ddev-laravel-queue)](https://github.com/tyler36/ddev-laravel-queue/releases/latest)

- [Introduction](#introduction)
- [Getting Started](#getting-started)
- [What does this add-on do and add?](#what-does-this-add-on-do-and-add)

## Introduction

This add-on allows you to start a Laravel queue worker through the DDEV web service. See [offical Queues documentation](https://laravel.com/docs/9.x/queues) for more details.

## Getting Started

- Install the DDEV laravel worker add-on:

```shell
ddev add-on get tyler36/ddev-laravel-queue
```

Then restart the project

```shell
ddev restart
```

## What does this add-on do and add?

1. Checks to make sure the DDEV version is adequate.
2. Adds `.ddev/config.laravel-workers.yaml`, which starts the queue worker daemon.

**Contributed and maintained by [tyler36](https://github.com/tyler36)**
