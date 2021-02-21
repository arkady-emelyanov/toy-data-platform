package lib

import (
	"net/http"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

type MetricServer struct {
	hitsCounter prometheus.Counter
	reqDuration prometheus.Histogram
}

func CreateMetricServer() *MetricServer {
	hitsCounter := prometheus.NewCounter(prometheus.CounterOpts{
		Name: "beacon_hits_total",
		Help: "number of requests received",
	})

	reqDuration := prometheus.NewHistogram(prometheus.HistogramOpts{
		Name: "beacon_hit_duration_seconds",
		Help: "time of request processing",
		Buckets: []float64{.005, .01, .025, .05, .1, .25, .5, 0.8},
	})

	prometheus.MustRegister(hitsCounter)
	prometheus.MustRegister(reqDuration)
	return &MetricServer{
		hitsCounter: hitsCounter,
		reqDuration: reqDuration,
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

func (m *MetricServer) Hit(took time.Duration) {
	m.hitsCounter.Inc()
	m.reqDuration.Observe(took.Seconds())
}

func (m *MetricServer) Shutdown() error {
	return nil
}
