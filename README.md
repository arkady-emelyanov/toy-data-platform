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

* Intro
  * Summarize knowledge, try to provide 360 degree overview
  * Topics not covered: Security, CI/CD
* Problem statement
* High-level architecture
* Edge service development: Go
* Stream processing: Intro
* Processing service development: Beam pipeline
* Processing service development: Flink runner
* Processing service development: Spark runner
* Observability: Intro
* Visualization: Intro
* Deployment architecture
* Terraform and Minikube
* Flink/Spark clusters
* Setting everything up (manual steps)
  * Pinot
  * Superset
  * Prometheus
  * Grafana
* Simulator service development
* Simulator deployment
* Check it out!
* Summary
