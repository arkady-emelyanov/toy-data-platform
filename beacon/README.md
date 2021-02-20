# Beacon

Start Kafka broker and wait it initialized:
```
> docker-compose up -d
> kafka-broker-api-versions.sh --bootstrap-server 127.0.0.1:9092
```

Create Kafka topic with 3 partitions and run beacon:
```
> kafka-topics.sh --bootstrap-server 127.0.0.1:9092 --create --topic v1.raw --partitions 3 --replication-factor 1
> go run ./main.go -bootstrap-server 127.0.0.1:9092 -stdout=false
```

Run benchmark:
```
> ab -n 10000 -c 10 http://127.0.0.1:8080/hello.gif
This is ApacheBench, Version 2.3 <$Revision: 1843412 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 127.0.0.1 (be patient)
Completed 1000 requests
Completed 2000 requests
Completed 3000 requests
Completed 4000 requests
Completed 5000 requests
Completed 6000 requests
Completed 7000 requests
Completed 8000 requests
Completed 9000 requests
Completed 10000 requests
Finished 10000 requests


Server Software:
Server Hostname:        127.0.0.1
Server Port:            8080

Document Path:          /hello.gif
Document Length:        42 bytes

Concurrency Level:      10
Time taken for tests:   3.916 seconds
Complete requests:      10000
Failed requests:        0
Total transferred:      2140000 bytes
HTML transferred:       420000 bytes
Requests per second:    2553.80 [#/sec] (mean)
Time per request:       3.916 [ms] (mean)
Time per request:       0.392 [ms] (mean, across all concurrent requests)
Transfer rate:          533.70 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    2   2.0      1      61
Processing:     0    2   2.5      2      62
Waiting:        0    2   1.8      1      61
Total:          0    4   3.5      3      69

Percentage of the requests served within a certain time (ms)
  50%      3
  66%      4
  75%      5
  80%      5
  90%      6
  95%      7
  98%      9
  99%     11
 100%     69 (longest request)
```

Validate Kafka offsets (message distribution across partitions):
```
> kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list 127.0.0.1:9092 --topic v1.raw
v1.raw:0:3315
v1.raw:1:3371
v1.raw:2:3314
```

Validate Prometheus metrics:
```
> curl -q -s 127.0.0.1:9100/metrics | grep beacon_hits_total
# HELP beacon_hits_total number of requests received
# TYPE beacon_hits_total counter
beacon_hits_total 10000
```

Cleanup:
```
> docker-compose down -v 
```
