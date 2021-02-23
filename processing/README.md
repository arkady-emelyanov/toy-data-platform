# Processing

Load test data:
```
mvn compile exec:java \
    -Dexec.mainClass=org.simple.analytics.example.DataGen
```

Check:
```
kafkacat -b 127.0.0.1:9092 -C -t v1.raw -f "%T\n%s"
```

Run transform pipeline
```
mvn compile exec:java \
    -Dexec.mainClass=org.simple.analytics.example.DataProcess \
    -Pdirect-runner
```

## Beam (fix it)

DirectRunner
```
mvn compile exec:java -Dexec.mainClass=org.simple.analytics.example.DataProcess \
    -Pdirect-runner \
    -Dexec.args="--runner=DirectRunner --brokerUrl=127.0.0.1:9092"
```

Flink
```
mvn compile exec:java -Dexec.mainClass=org.simple.analytics.example.DataProcess \
    -Pflink-runner \
    -Dexec.args="--runner=FlinkRunner --brokerUrl=127.0.0.1:9092"
```


Spark
```
mvn compile exec:java -Dexec.mainClass=org.simple.analytics.example.DataProcess \
    -Pspark-runner \
    -Dexec.args="--runner=SparkRunner --brokerUrl=127.0.0.1:9092"
```
