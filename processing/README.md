# Processing

Load test data:
```
mvn compile exec:java \
    -Dexec.mainClass=org.simple.analytics.example.DataGenerator
```

Check:
```
kafkacat -b 127.0.0.1:9092 -C -t v1.raw -f "%T\n%s\n"
```

## Beam (fix it)

DirectRunner
```
mvn compile exec:java \
    -Dexec.mainClass=org.simple.analytics.example.DataProcess \
    -Pdirect-runner \
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
mvn compile exec:java \
    -Dexec.mainClass=org.simple.analytics.example.DataProcess \
    -Pflink-runner \
    -Dexec.args="--runner=FlinkRunner --brokerUrl=127.0.0.1:9092"
```

Spark
```
mvn compile exec:java \
    -Dexec.mainClass=org.simple.analytics.example.DataProcess \
    -Pspark-runner \
    -Dexec.args="--runner=SparkRunner --brokerUrl=127.0.0.1:9092"
```

```
kafkacat -b 127.0.0.1:9092 -o end -C -t v1.hits
```
