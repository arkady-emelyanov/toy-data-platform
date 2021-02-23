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

## Beam (fix it)

DirectRunner
```
mvn compile exec:java -Dexec.mainClass=org.simple.analytics.example.DataProcess \
    -Pdirect-runner \
    -Djava.util.logging.config.file=src/main/resources/logging.properties \
    -Dexec.args="--runner=DirectRunner --brokerUrl=127.0.0.1:9092"
```

```
mvn clean package -Pdirect-runner -DskipTests
java -cp target/processing-bundled-0.1.jar \
    org.simple.analytics.example.DataProcess \
    --runner=DirectRunner \
    --brokerUrl=127.0.0.1:9092
```

Flink
```
mvn compile exec:java -Dexec.mainClass=org.simple.analytics.example.DataProcess \
    -Pflink-runner \
    -Djava.util.logging.config.file=src/main/resources/logging.properties \
    -Dexec.args="--runner=FlinkRunner --brokerUrl=127.0.0.1:9092"
```


Spark
```
mvn compile exec:java -Dexec.mainClass=org.simple.analytics.example.DataProcess \
    -Pspark-runner \
    -Djava.util.logging.config.file=src/main/resources/logging.properties \
    -Dexec.args="--runner=SparkRunner --brokerUrl=127.0.0.1:9092"
```
