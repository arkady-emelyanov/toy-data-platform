package main

import (
	"flag"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"github.com/arkady-emelyanov/simple-analytics-example/beacon/lib"
	"github.com/valyala/fasthttp"
)

var (
	// 1x1 GIF transparent pixel
	gTransparentPixel = []byte{
		0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00, 0x01, 0x00,
		0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0x21,
		0xf9, 0x04, 0x01, 0x00, 0x00, 0x00, 0x00, 0x2c, 0x00, 0x00,
		0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x02, 0x01, 0x44,
		0x00, 0x3b,
	}
)

func main() {
	// parse command-line arguments
	flagBroker := flag.String("bootstrap-server", "", "Kafka bootstrap server: 127.0.0.1:9092")
	flagTopic := flag.String("topic", "v1.raw", "Kafka topic to write to")
	flagStdout := flag.Bool("stdout", true, "Use stdout request writer")
	flagListen := flag.String("listen", "127.0.0.1:8080", "HTTP listen address")
	flagMetric := flag.String("metric-listen", "127.0.0.1:9100", "Metrics listen address")
	flag.Parse()

	// create metrics server
	m := lib.CreateMetricServer()
	s := lib.CreateHttpServer()
	w, err := lib.CreateWriter(*flagBroker, *flagTopic, *flagStdout)
	if err != nil {
		log.Fatalf("Writer: create error: %s\n", err)
	}

	// attach handler to http server
	s.Handler = func(ctx *fasthttp.RequestCtx) {
		if _, err := ctx.Request.WriteTo(w); err != nil {
			log.Printf("Write error: %s\n", err)
		}

		ctx.Response.SetStatusCode(http.StatusOK)
		ctx.Response.Header.Add("Cache-Control", "no-cache, no-store, must-revalidate")
		ctx.Response.Header.Add("Content-Type", "image/gif")
		ctx.Response.SetBody(gTransparentPixel)
		m.Hit()
	}

	// start servers
	go func() {
		if err := m.ListenAndServe(*flagMetric); err != nil {
			log.Fatalf("PROM: ListenAndServe error: %s\n", err)
		}
	}()
	go func() {
		if err := s.ListenAndServe(*flagListen); err != nil {
			log.Fatalf("HTTP: ListenAndServe error: %s\n", err)
		}
	}()

	// setup signal handler
	done := make(chan os.Signal, 1)
	signal.Notify(done, syscall.SIGINT, syscall.SIGTERM)

	// wait for signal
	log.Println("HTTP server address:", *flagListen)
	log.Println("Metrics server address:", *flagMetric)
	<-done
	log.Println("Shutdown signal received, exiting...")

	// gracefully shutdown things..
	if err := s.Shutdown(); err != nil {
		log.Fatalf("HTTP Server shutdown error: %s\n", err)
	}
	if err := w.Shutdown(); err != nil {
		log.Fatalf("Writer shutdown error: %s\n", err)
	}
	if err := m.Shutdown(); err != nil {
		log.Fatalf("Prometheus shutdown error: %s\n", err)
	}

	// ok, we done
	log.Println("Shutdown complete, bye..")
}
