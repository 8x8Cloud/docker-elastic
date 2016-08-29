ElasticSearch Docker Image
=============
## What is this?

This image is based off of [frolvlad/alpine-oraclejdk8](https://hub.docker.com/r/frolvlad/alpine-oraclejdk8/), an Alpine Linux-based container that provides a slimmed down version of Java 8. The Dockerfile then does the following:
 * Grabs ElasticSearch 2.3.4
 * Installs a handful of useful plugins (see below)
 * Configures the container to allow for non-root access. ES won't run as root, which causes us some container-based acrobatics.
 * Exposes port 9200 and 9300

## Plugins

The image comes with the following plugins:
 * [HQ](https://github.com/royrusso/elasticsearch-HQ) - the poor man's monitoring plugin
 * License - a boilerplate Elastic license so we can use Marvel. Good for 30 days (see below).
 * [Marvel](https://www.elastic.co/products/marvel) Agent - for visualizing cluster stats in Kibana via the Marvel app. Requires Kibana to view.

## Licensing

It is important to note that Marvel requires a license. As of the 2.x release of ElasticSearch Marvel is free for basic (single-cluster) use. The license obtained above will function as a trial for 30 days, and then you will be required to either buy a subscription or obtain a free basic license. Please see the [official documentation](https://www.elastic.co/guide/en/marvel/current/license-management.html) for up to date, detailed information.

Please note that these Docker images are not intended to be used in a production environment, and are not configured beyond simple clustering. These images are instead more for local exploration of features and parsing of ad-hoc data with different groups of plugins.

If there is sufficient interest, we may release an image without Marvel baked in.

## Clustering

Networking in Docker can be a tad bit tricky. This image exposes ports 9200 and 9300, but when running in a cluster only one container can expose 9200 (the REST/JSON API) to the world, and thus render HQ. We're currently using what is apparently a "legacy" system via [links](https://docs.docker.com/engine/userguide/networking/default_network/dockerlinks/#/connect-with-the-linking-system).

There are two configurations that can be used:

#### Non-Clustered
You can run ElasticSearch stand-alone, in a single node cluster:

```
docker run -d --name elasticsearch -p 9200:9200 8x8cloud/elasticsearch
```
You will get an ElasticSearch cluster of size 1, and you will be able to talk to it on port `9200`. This should be sufficient for a quick test run. Naming the container means that you can also attach the 8x8cloud/kibana image as well:

```
docker run --link elasticsearch -p 5601:5601 -d 8x8cloud/kibana
```

Note that the ElasticSearch image must be run first as Kibana uses a link. When done, you can get to HQ via `localhost:9200/_plugin/hq`, and Mavel via `http://localhost:5601/app/marvel`.


#### Clustered
To run ElasticSearch in a clustered environment, you should use the Docker Compose file in the root of this git repository. Out of the box it will build you a three node cluster:

 * elasticsearch-master (*node.master=true*, *node.data=false*)
 * elasticsearch-slave (*node.master=false, node.data=true*)
 * kibana

Note that again we're using links. `Kibana` and `elasticsearch-slave` will both link back to the `elasticsearch-master` node, which in turn is also the only node that will map ports `9200` and `9300` externally. Likewise, the Kibana host will also map `5601` externally. You'll also notice that the `elasticsearch-slave` node will use ZenDisco unicast, specifying the `elasticsearch-master` node as the master.

The networking is a little funky because the default ElasticSearch mechanism is to plop yourself in the middle of something like an AWS AutoScaling Group, or in an environment where you can use multicast to discover nodes. In this case we're running multiple nodes on the same host, and obviously not all of them can bind the default ports of `9200` and `9300`. There are probably different ways of doing it, but preliminary googling suggested links were the way to do this. More to come...

When you want to scale new nodes, make sure to scale `elasticsearch-slave`. Here's a handy shell script:

```bash
#!/bin/bash
NODE_COUNT=3
if [ ! -z "$1" ]; then
 NODE_COUNT=$1
fi

NODE_TYPE="elasticsearch-slave"
if [ ! -z "$2" ]; then
  NODE_TYPE="$2"
fi

echo "scaling to $NODE_COUNT $NODE_TYPE nodes..."
docker-compose scale $NODE_TYPE=$NODE_COUNT
```

When you scale in new nodes you'll see them spin up and connect to the cluster successfully. If you attach to a given Docker image you'll see in netstat that all the nodes are properly talking to each other. It's worth noting that this is *not* a production grade deployment, so if you lose your master, you're toast.

#### Node disposition in a cluster

The default `docker-compose.yml` builds a cluster where only `elasticsearch-master` is eligible for master election, and the `elasticsearch.yml` for all nodes has `discovery.zen.minimum_master_nodes=1`. This is because you are incredibly unlikely to have a network partition when running in containers on your local machine. Only the `elasticsearch-slave` nodes are configured to be data nodes, and there are no query-only nodes.

If you want to try more exotic topologies/routing strategies go ahead and modify the `command` block for the node classes in `docker-compose.yml`, or or even create a new class of node such as `elasticsearch-query` with `node.master=false` and `node.data=false`. Just make sure you you have enough RAM to run all your nodes.

## Why

All the images seemed to have something of value: the right version of ElasticSearch, the right version of Java, maybe even a couple of cool plugins. None of them were the right combination of version, Java, plugins, size, or clustering ability.

We welcome issues and pull requests! (Within reason.)
