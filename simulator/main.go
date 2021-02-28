package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/signal"
	"strings"
	"sync/atomic"
	"syscall"
	"time"

	"github.com/jaswdr/faker"
	v "github.com/tsenart/vegeta/v12/lib"
)

var globalPixelIds = []string{
	"48a778e5bb9f4694a1c88a6d2a6415a4",
	"22096fafa98b4bc79774ecc3441449f1",
	"49ee3adcc8dc4f20ae12bafee01eb4e8",
	"7c581dc63726471f8fe3710d0c735633",
	"20c92331f59b4ef78151ffb1b62164e7",
	"ff593ca1d94f4d8e970cf8e89e0efe55",
	"e5b756e4eac948efb8ee2076a4af2017",
	"119e5173a0c94c00b37823c5527e88dd",
	"bb5802912be5457092f2ae58d296cf34",
	"b580871d92f84144841405e3e37e2f2c",
}

type beaconHitSource struct {
	dest string
	host string
	mock faker.Faker

	pid int64
}

func (s *beaconHitSource) Read(p []byte) (int, error) {
	reqFmt := strings.Join(
		[]string{
			"GET %s/%s.png",
			"Host: %s",
			"X-Forwarded-For: %s",
			"User-Agent: %s",
			"\n",
		},
		"\n",
	)

	pixelId := globalPixelIds[atomic.AddInt64(&s.pid, 1)%int64(len(globalPixelIds))]
	t := fmt.Sprintf(
		reqFmt,
		s.dest,
		pixelId,
		s.host,
		s.mock.Internet().Ipv4(),
		s.mock.UserAgent().UserAgent(),
	)

	n := copy(p, t)
	return n, nil
}

func main() {
	flagTarget := flag.String("target", "http://127.0.0.1:8080", "Target (e.g. http://127.0.0.1:8080")
	flagRate := flag.Int("rate", 10, "Number of requests per second")
	flagHost := flag.String("host", "beacon.example.com", "Host header to send")
	flag.Parse()

	// Prepare parameters
	rate := v.Rate{
		Freq: *flagRate,
		Per:  time.Second,
	}
	metrics := &v.Metrics{}
	mock := faker.New()
	emitter := &beaconHitSource{
		dest: *flagTarget,
		mock: mock,
		host: *flagHost,
	}

	// Prepare our load tool
	pointer := v.NewHTTPTargeter(emitter, nil, nil)
	shooter := v.NewAttacker()

	// Start traffic loader
	go func() {
		for res := range shooter.Attack(pointer, rate, 0, "StaticLoad") {
			if res.Error != "" {
				log.Fatalf("Hit failed: %#v", res)
			}
			metrics.Add(res)
		}
	}()

	// Setup signal handler and wait for signal
	done := make(chan os.Signal, 1)
	signal.Notify(done, syscall.SIGINT, syscall.SIGTERM)

	log.Printf("Traffic rate: %s", rate.String())
	<-done
	shooter.Stop()
	metrics.Close()

	log.Println("Done!")
	log.Printf("99th percentile: %s\n", metrics.Latencies.P99)
}
