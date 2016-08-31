ElasticSearch Related Docker Suite
=============

## What's in it

There are currently three pieces here:
 * An ElasticSearch image (elasticsearch/Dockerfile)
 * A Kibana image (kibana/Dockerfile)
 * A Docker compose file for an ElasticSearch cluster with a Kibana visualization node (docker-compose.yml)

The ElasticSearch image will work either stand-alone as a single node, or in a clustered formation using the Docker compose file. The Docker compose file is version 2.0, and requires Docker 1.10.0 or greater.

Each sub-directory has a more detailed readme, explaining what the image does.

## Using via Docker Compose:

```bash
docker-compose up -d
```

This will spin up 3 nodes:
 * elasticsearch-master (mapped to 9200 externally)
 * kibana (mapped to 5601 externally)
 * elasticsearch-slave (mapped to nothing externally)

To scale more nodes into the cluster:

```bash
docker-compose scale elasticsearch-slave 3
```

If you want to kill the cluster, you can do so via:

```bash
docker-compose down
```

## Using without Docker Compose:

```bash
# For a single ES node
docker run -d --name elasticsearch -p 9200:9200 8x8cloud/elasticsearch

# optionally, if you'd also like Kibana. Because this has a link, run it after ElasticSearch.
docker run --link elasticsearch -p 5601:5601 -d 8x8cloud/kibana
```

*Note: links are used here for simplicity. You can also use a Docker network if you'd like.*

## Using without Docker Compose and a different ElasticSearch image name:

The compose-based clustering contains an ElasticSearch master server named `elasticsearch-master`, which all slave nodes, and Kibana, will talk to. In a single-node mode, the Kibana server will default to looking at `elasticsearch`. If you'd like to name your ElasticSearch server something else, you can do so like this:

```bash
# Alias our ES node to "beautiful_snowflake"
docker run -d --name beautiful_snowflake -p 9200:9200 8x8cloud/elasticsearch

# Link our Kibana node to the name above, and set our ELASTICSEARCH_HOST
# environment variable to point to that instead of 'elasticsearch'.
docker run -e "ELASTICSEARCH_HOST=http://beautiful_snowflake:9200" --link beautiful_snowflake -p 5601:5601 -d 8x8cloud/kibana
```

*Note: links are used here for simplicity. You can also use a Docker network if you'd like, but you will still need to pass `ELASTICSEARCH_HOST`.*

## A note on disk usage

The ElasticSearch Dockerfile uses a [VOLUME](https://docs.docker.com/engine/reference/builder/#/volume) to store its data, and if you're indexing non-trivial amounts of data this means that you can easily eat a lot of disk space. It's very  important to remember that volumes exist outside of the scope of a given image instantiation and must be cleaned manually.

Indexing larger amounts of data can quickly eat your disk space, or even kill your VM if you're running something like Docker Machine, or one of the Docker for Windows/Docker for Mac betas. To list the set of volumes that aren't attached, you can run `docker volume ls -f dangling=true`. Be careful with this as it will list *all* unmounted volumes, some of which you might want to keep. At this point you can pass a single ID to `docker volume rm` and delete a given volume.

If you are absolutely sure that you don't need any of your volumes, you can always use something like xargs to nuke all your dangling volumes: `docker volume ls -f dangling=true -q | xargs docker ...` *(the ellipses were purposefully added to make sure that impatient readers don't skip to the end of the README and nuke all of their detached volumes)*.

## Disclaimer

These images were designed for exploration, and are not configured for a production or other publicly available service. The purpose of these images is instead to explore ElasticSearch in an easy to access, safe environment (IE: not your production servers). They are also quite handy if you want to do ad-hoc parsing of, say, request logs.

Please note that the standard disclaimers apply. There is no warranty, implied or otherwise, and there is no support offered. Do not run these in sensitive or public-facing environments.
