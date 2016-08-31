Kibana Docker Image
=============
## What is this?

This image is based off the raw [Alpine](https://hub.docker.com/_/alpine/) image. This shaves 100MB+ of image size off our Docker container! The Docker file also:
 * Grabs Kibana 4.5.4
 * Symlinks a version of Node/NPM that actually work with Busybox
 * Installs handy plugins (more below)
 * Exposes port 5601

## Plugins

This image comes with the following plugins:

 * [Marvel](https://www.elastic.co/products/marvel) - a cluster monitoring plugin. See below for license details.
 * [Sense](https://www.elastic.co/guide/en/sense/current/installing.html) - an ad-hoc query plugin.


Sense is a completely awesome plugin for ad-hoc queries. It has auto-complete, a memory of queries run, syntax highlighting. It's also free and does not require a support plan or license.

## Licensing

It is important to note that Marvel requires a license. As of the 2.x release of ElasticSearch Marvel is free for basic (single-cluster) use. The license obtained above will function as a trial for 30 days, and then you will be required to either buy a subscription or obtain a free basic license. Please see the [official documentation](https://www.elastic.co/guide/en/marvel/current/license-management.html) for up to date, detailed information.

Please note that these Docker images are not intended to be used in a production environment, and are not configured beyond simple clustering. These images are instead more for local exploration of features and parsing of ad-hoc data with different groups of plugins.

If there is sufficient interest, we may release an image without Marvel baked in.

## Clustering

Kibana requires a copy of ElasticSearch in order to do anything useful. When running this image, you can either use it as a part of the `docker-compose.yml` in the root directory like so:

```bash
docker-compose up -d
```

Or you can point it at a single container, aliased to "elasticsearch" (see the ElasticSearch image README for details):

```bash
docker run --link elasticsearch -p 5601:5601 -d 8x8cloud/kibana
```

*Note: links are used here for simplicity. You can also use a Docker network.*

## Why

Much like ElasticSearch, there are a number of Kibana images. None of them seemed to have the right combination of an up-to-date copy of Kibana, with a small image size, and the desired set of plugins. Plus, if we're already taking the trouble to dockerize the ElasticSearch nodes, why not create a small and customized Kibana node to go along with them...

As always, we welcome pull requests and issues. Within reason.
