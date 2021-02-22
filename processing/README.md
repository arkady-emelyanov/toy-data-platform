# Processing

Load test data:
```
mvn compile exec:java \
    -Dexec.mainClass=org.simple.analytics.example.DataGen
```

Run transform pipeline
```
```

## Beam (fix it)

DirectRunner
```
mvn compile exec:java -Dexec.mainClass=org.apache.beam.examples.WordCount \
    -Pdirect-runner \
    -Dexec.args="--runner=DirectRunner \
      --inputFile=../beacon/README.md \
      --output=target/counts"
```

Flink
```
mvn compile exec:java -Dexec.mainClass=org.apache.beam.examples.WordCount \
    -Pflink-runner \
    -Dexec.args="--runner=FlinkRunner \
      --inputFile=../beacon/README.md \
      --output=target/counts \
      --filesToStage=target/word-count-beam-bundled-0.1.jar"

```


Spark
```
mvn compile exec:java -Dexec.mainClass=org.apache.beam.examples.WordCount \
    -Pspark-runner \
    -Dexec.args="--runner=SparkRunner \
      --inputFile=../beacon/README.md \
      --output=target/counts"
```
