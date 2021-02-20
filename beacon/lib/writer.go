package lib

import (
	"github.com/Shopify/sarama"
	"io"
	"log"
	"time"
)

type RequestWriter struct {
	writers []io.WriteCloser
}

func CreateWriter(kafkaEndpoint string, kafkaTopic string, useStdout bool) (*RequestWriter, error) {
	var writers []io.WriteCloser

	// initialize stdout writer (if requested)
	if useStdout {
		writers = append(writers, &stdoutRequestWriter{})
		log.Println("Started stdout writer")
	}

	// initialize kafka writer (if requested)
	if kafkaEndpoint != "" {
		kafkaWriter := &kafkaRequestWriter{
			broker: kafkaEndpoint,
			topic:  kafkaTopic,
		}
		if err := kafkaWriter.init(); err != nil {
			return nil, err
		}
		writers = append(writers, kafkaWriter)
		log.Println("Started Kafka writer", kafkaEndpoint, kafkaTopic)
	}

	return &RequestWriter{writers: writers}, nil
}

func (w *RequestWriter) Write(data []byte) (n int, err error) {
	for i := 0; i < len(w.writers); i++ {
		n, err := w.writers[i].Write(data)
		if err != nil {
			return n, err
		}
	}
	return len(data), nil
}

func (w *RequestWriter) Shutdown() error {
	for i := 0; i < len(w.writers); i++ {
		if err := w.writers[i].Close(); err != nil {
			return err
		}
	}
	return nil
}

// Stdout Writer, the one that could be used for debugging purposes
type stdoutRequestWriter struct {
}

func (w *stdoutRequestWriter) Write(data []byte) (n int, err error) {
	log.Printf("%s\n", string(data))
	return len(data), nil
}

func (w *stdoutRequestWriter) Close() error {
	return nil
}

// Kafka writer, the real one that should be used
type kafkaRequestWriter struct {
	broker   string
	topic    string
	producer sarama.AsyncProducer
}

func (w *kafkaRequestWriter) init() error {
	config := sarama.NewConfig()
	config.Producer.RequiredAcks = sarama.WaitForAll
	config.Producer.Retry.Max = 5
	config.Producer.Compression = sarama.CompressionLZ4
	config.Producer.Flush.Frequency = 500 * time.Millisecond
	config.Producer.Return.Errors = true
	config.Producer.Return.Successes = false

	producer, err := sarama.NewAsyncProducer([]string{w.broker}, config)
	if err != nil {
		return err
	}
	go func() {
		for err := range producer.Errors() {
			log.Fatalf("Failed to write to Kafka: %s\n", err)
		}
	}()

	w.producer = producer
	return nil
}

func (w *kafkaRequestWriter) Write(data []byte) (n int, err error) {
	w.producer.Input() <- &sarama.ProducerMessage{
		Topic: w.topic,
		Value: sarama.ByteEncoder(data),
	}
	return len(data), nil
}

func (w *kafkaRequestWriter) Close() error {
	return w.producer.Close()
}
