# Processing

Start Kafka broker and wait it initialized:
```
> docker-compose up -d
> kafka-topics.sh --bootstrap-server 127.0.0.1:9092 --list
v1.dlq
v1.hit
v1.raw
```

Load test data:
```
```

Run transform pipeline
```
```

## Beam

DirectRunner
```
mvn clean package -Pdirect-runner -DskipTests
mvn exec:java -Dexec.mainClass=org.apache.beam.examples.WordCount \
    -Pdirect-runner \
    -Dexec.args="--runner=DirectRunner \
      --inputFile=../beacon/README.md \
      --output=target/counts"
```

Flink
```
mvn clean package -Pflink-runner -DskipTests
mvn exec:java -Dexec.mainClass=org.apache.beam.examples.WordCount \
    -Pflink-runner \
    -Dexec.args="--runner=FlinkRunner \
      --inputFile=../beacon/README.md \
      --output=target/counts \
      --filesToStage=target/word-count-beam-bundled-0.1.jar"

```


Spark
```
mvn clean package -Pspark-runner -DskipTests
mvn exec:java -Dexec.mainClass=org.apache.beam.examples.WordCount \
    -Pspark-runner \
    -Dexec.args="--runner=SparkRunner \
      --inputFile=../beacon/README.md \
      --output=target/counts"
```
