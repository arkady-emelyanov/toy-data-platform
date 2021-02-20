package lib

import (
	"net/http"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

type MetricServer struct {
	hitsCounter prometheus.Counter
}

func CreateMetricServer() *MetricServer {
	hitsCounter := prometheus.NewCounter(prometheus.CounterOpts{
		Name: "beacon_hits_total",
		Help: "number of requests received",
	})

	prometheus.MustRegister(hitsCounter)
	return &MetricServer{
		hitsCounter: hitsCounter,
	}
}

func (m *MetricServer) ListenAndServe(addr string) error {
	http.Handle("/metrics", promhttp.HandlerFor(
		prometheus.DefaultGatherer,
		promhttp.HandlerOpts{
			EnableOpenMetrics: true,
		}))
	return http.ListenAndServe(addr, nil)
}

func (m *MetricServer) Hit() {
	m.hitsCounter.Inc()
}

func (m *MetricServer) Shutdown() error {
	return nil
}
