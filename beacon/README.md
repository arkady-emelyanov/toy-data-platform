# Beacon

Start Kafka broker and wait it initialized:
```
> docker-compose up -d
> kafka-topics.sh --bootstrap-server 127.0.0.1:9092 --list
v1.raw
```

Run beacon:
```
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
Time taken for tests:   2.382 seconds
Complete requests:      10000
Failed requests:        0
Total transferred:      2140000 bytes
HTML transferred:       420000 bytes
Requests per second:    4197.90 [#/sec] (mean)
Time per request:       2.382 [ms] (mean)
Time per request:       0.238 [ms] (mean, across all concurrent requests)
Transfer rate:          877.30 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    1   9.4      1     327
Processing:     0    1   4.6      1     228
Waiting:        0    1   4.4      1     227
Total:          0    2  10.4      2     329

Percentage of the requests served within a certain time (ms)
  50%      2
  66%      2
  75%      2
  80%      2
  90%      3
  95%      3
  98%      3
  99%      4
 100%    329 (longest request)
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
> curl -q -s 127.0.0.1:9100/metrics | grep beacon_
# HELP beacon_hit_duration_seconds time of request processing
# TYPE beacon_hit_duration_seconds histogram
beacon_hit_duration_seconds_bucket{le="0.005"} 9997
beacon_hit_duration_seconds_bucket{le="0.01"} 9997
beacon_hit_duration_seconds_bucket{le="0.025"} 9997
beacon_hit_duration_seconds_bucket{le="0.05"} 9997
beacon_hit_duration_seconds_bucket{le="0.1"} 9997
beacon_hit_duration_seconds_bucket{le="0.25"} 10000
beacon_hit_duration_seconds_bucket{le="0.5"} 10000
beacon_hit_duration_seconds_bucket{le="1"} 10000
beacon_hit_duration_seconds_bucket{le="2.5"} 10000
beacon_hit_duration_seconds_bucket{le="5"} 10000
beacon_hit_duration_seconds_bucket{le="10"} 10000
beacon_hit_duration_seconds_bucket{le="+Inf"} 10000
beacon_hit_duration_seconds_sum 4.705167178000018
beacon_hit_duration_seconds_count 10000
# HELP beacon_hits_total number of requests received
# TYPE beacon_hits_total counter
beacon_hits_total 10000
```

Latency:
`beacon_hit_duration_seconds_sum` / `beacon_hit_duration_seconds_count`

Cleanup:
```
> docker-compose down -v 
```
