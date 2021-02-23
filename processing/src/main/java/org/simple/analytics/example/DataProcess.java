package org.simple.analytics.example;

import org.apache.beam.sdk.values.*;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.ByteArrayDeserializer;
import org.apache.kafka.common.serialization.ByteArraySerializer;
import org.apache.kafka.common.serialization.StringSerializer;

import org.apache.beam.sdk.transforms.ToJson;
import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.io.kafka.KafkaIO;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.transforms.Values;

import org.simple.analytics.example.fn.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


/**
 * Main Processing pipeline
 */
public class DataProcess {

    // Tag for parsed records, records will be processed further.
    private static final TupleTag<List<String>> parsedTag = new TupleTag<>() {
    };

    // Tag for broken records, will be written to DLQ topic
    private static final TupleTag<byte[]> brokenTag = new TupleTag<>() {
    };

    /**
     * Pipeline processor
     *
     * @param args command line arguments
     */
    public static void main(String[] args) {
        DataProcessOptions options = PipelineOptionsFactory.fromArgs(args)
                .withValidation()
                .as(DataProcessOptions.class);

        // Prepare Kafka producer/consumer configurations
        Map<String, Object> consumerProps = new HashMap<>();
        consumerProps.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, options.getBrokerUrl());
        consumerProps.put(ConsumerConfig.GROUP_ID_CONFIG, options.getGroupId());
        consumerProps.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, options.getAutoResetOffsets());

        Map<String, Object> producerProps = new HashMap<>();
        producerProps.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, options.getBrokerUrl());
        producerProps.put(ProducerConfig.ACKS_CONFIG, "all");

        // Create source PCollection from Kafka topic
        // Read byte[] values from source topic.
        Pipeline p = Pipeline.create(options);
        PCollection<byte[]> sourceStream = p.apply(
                "Read raw stream",
                KafkaIO.<byte[], byte[]>read()
                        .withConsumerConfigUpdates(consumerProps)
                        .withTopic(options.getRawTopic())
                        .withKeyDeserializer(ByteArrayDeserializer.class)
                        .withValueDeserializer(ByteArrayDeserializer.class)
                        .withReadCommitted()
                        .withoutMetadata())
                .apply("Extract KafkaRecord values", Values.create());

        // Parse incoming requests into two PCollections:
        // tag: parsedTag = Collection<List<String>>
        // tag: brokenTag = Collection<byte[]>
        PCollectionTuple parsedResults = sourceStream.apply(
                "Parse raw request",
                ParDo.of(new ParseRequestFn(parsedTag, brokenTag))
                        .withOutputTags(parsedTag, TupleTagList.of(brokenTag))
        );

        // Write broken data into dlq topic (dead letter queue).
        // From monitoring perspective: DLQ message arrival means
        // incorrect LoadBalancer/ReverseProxy configuration.
        parsedResults
                .get(brokenTag)
                .apply(
                        "Write broken requests",
                        KafkaIO.<Void, byte[]>write()
                                .withProducerConfigUpdates(producerProps)
                                .withTopic(options.getDeadLetterQueueTopic())
                                .withValueSerializer(ByteArraySerializer.class)
                                .values()
                );

        // Normalize URI of parsed stream
        PCollection<List<String>> normalizedResults = parsedResults
                .get(parsedTag)
                .apply("Normalize request uri", ParDo.of(new NormalizeUriFn()));

        // Once done, write final parsed user-agent into separate topic.
        normalizedResults
                .apply("Collect user-agents", ParDo.of(new CollectAgentsFn()))
                .apply("Map List to UserAgent", ParDo.of(new MapUserAgent()))
                .apply("Map UserAgent to JSON", ToJson.of())
                .apply(
                        "Sink UserAgent JSON",
                        KafkaIO.<Void, String>write()
                                .withProducerConfigUpdates(producerProps)
                                .withTopic(options.getUserAgentsTopic())
                                .withValueSerializer(StringSerializer.class)
                                .values()
                );

        // Map normalized stream to Impression objects, and convert them to JSON.
        // Once done, write final parsed impression into separate topic.
        normalizedResults
                .apply("Map List to Impression", ParDo.of(new MapImpression()))
                .apply("Map Impression to JSON", ToJson.of())
                .apply(
                        "Sink Impression JSON",
                        KafkaIO.<Void, String>write()
                                .withProducerConfigUpdates(producerProps)
                                .withTopic(options.getImpressionsTopic())
                                .withValueSerializer(StringSerializer.class)
                                .values()
                );

        // Start the pipeline.
        p.run().waitUntilFinish();
    }
}
