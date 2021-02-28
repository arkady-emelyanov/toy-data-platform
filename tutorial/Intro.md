# Intro

In a modern world, [data is a new oil](https://www.forbes.com/sites/forbestechcouncil/2019/11/15/data-is-the-new-oil-and-thats-a-good-thing/?sh=647471ab7304). Data platform design and implementation skill becomes crucial. There are lot of tutorials covering narrow topics related to the data processing, but it's hard to get ten-thousands feet overview. The idea of the tutorial is to provide an idea of how such Data platforms could be built. 

Right now, there are two approaches to process the data: batch and streaming, in a wider sense also known as [Lambda](https://en.wikipedia.org/wiki/Lambda_architecture) and Kappa architectures (in reality, almost all data platform are hybrids, where batch and stream processing is co-exists).

It's basically impossible to cover 360-degree technology view of modern Data platform, just take a look at [technology landscape](https://mattturck.com/data2020/)!

During this tutorial, I'm going to implement extremely simple (a toy) Data platform, trying to cover as much important aspects as possible. I'll define "the problem statement" in a next section. 

Unfotunately, some aspects will not be covered during this tutorial. Most of them related to Enterprise Architecture and not important in our toy Data platform. Here is very loose list of topics not covered in this tutorial: Security, CI/CD (IaC concept will be covered, though), Data products and Data catalog, [Data lineage](https://en.wikipedia.org/wiki/Data_lineage), [Data governance](https://en.wikipedia.org/wiki/Data_governance).

Here is the list of tools/technologies used in the tutorial:

* macOS
* [GNU Make](https://www.gnu.org/software/make/) (bundled into Mac OS)
* [Brew](https://brew.sh/)
* [Apache Flink](https://flink.apache.org/)
* [Apache Spark](https://spark.apache.org/)
* [Apache Kafka](https://kafka.apache.org/)
* [Apache ZooKeeper](https://zookeeper.apache.org/)
* [Apache Druid](https://druid.apache.org/)
* [Apache Hadoop](http://hadoop.apache.org/)
* [PostgreSQL](https://www.postgresql.org/)
* [Redis](https://redis.io/)
* [Redash](https://redash.io/)
* [Prometheus](https://prometheus.io/)
* [HashiCorp Terraform](https://www.terraform.io/)
* [Helm](https://helm.sh/)
* [Golang](https://golang.org/)
* [Java 11 (AdoptOpenJDK)](https://adoptopenjdk.net/)
* [Apache Maven](https://maven.apache.org/)
* [Docker Desktop](https://www.docker.com/products/docker-desktop)
* [Minikube](https://minikube.sigs.k8s.io/docs/)

As you can see, it's quite big. But don't worry, developer tools installation instructions will be provided later in the tutorial.

Shall we start?
