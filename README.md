# Simple Analytics Example

Toy start-up company providing web-analytics.

* Edge service: Golang
* Message Bus: [Apache Kafka](https://kafka.apache.org/)
* Stream processing: [Apache Beam](https://beam.apache.org/) @ Java ([Apache Spark](https://spark.apache.org/)
  / [Apache Flink](https://flink.apache.org/))
* OLAP engine/ingest: [Apache Pinot](http://pinot.apache.org/)
* Visualisation: [Apache Superset](https://superset.apache.org/)
* Simulation: Golang

# ToC

Intro

* Summarize knowledge, try to provide 360 degree overview
* Topics not covered: Security, CI/CD
* Problem statement
* Storage OLAP-like backend: Into
* Observability: Intro
* Visualization: Intro
* High-level architecture

Development

* Edge service development: Go
* Simulator service development: Go
* Stream processing: Intro
* Processing service development: Beam pipeline
* Processing service development: Flink runner
* Processing service development: Spark runner

Deployment

* Deployment architecture
* Terraform and Minikube
* Setting everything up (manual steps)
  * Druid
  * Redash
* Edge service deployment
* Simulator deployment
* Flink/Spark deployment
* Check it out!
* Summary
