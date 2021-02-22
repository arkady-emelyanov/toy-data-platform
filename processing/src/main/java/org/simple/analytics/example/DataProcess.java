package org.simple.analytics.example;

import org.apache.kafka.common.serialization.ByteArrayDeserializer;
import org.apache.kafka.common.serialization.ByteArraySerializer;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.values.TupleTagList;
import org.apache.beam.sdk.io.kafka.KafkaIO;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.transforms.Values;
import org.apache.beam.sdk.values.PCollectionTuple;
import org.apache.beam.sdk.values.TupleTag;
import org.apache.beam.sdk.values.PCollection;

import org.simple.analytics.example.fn.CollectAgentsFn;
import org.simple.analytics.example.fn.NormalizeUriFn;
import org.simple.analytics.example.fn.ParseRequestFn;

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

    // Kafka consumer configs
    private static final String groupId = "processing-consumer";
    private static final String offsets = "earliest";

    // Kafka topics
    private static final String sourceTopic = "v1.raw";
    private static final String dlqTopic = "v1.dlq";
    private static final String userAgentTopic = "v1.user-agents";
    private static final String impressionTopic = "v1.impressions";

    /**
     * Pipeline processor
     *
     * @param args command line arguments
     */
    public static void main(String[] args) {
        String boostrapServer = "127.0.0.1:9092"; // TODO: make configurable

        PipelineOptions options = PipelineOptionsFactory.create();
        Pipeline p = Pipeline.create(options);

        Map<String, Object> consumerConfigs = new HashMap<>();
        consumerConfigs.put(ConsumerConfig.GROUP_ID_CONFIG, groupId);
        consumerConfigs.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, offsets);

        // Create source PCollection from Kafka topic
        // Read byte[] values from source topic.
        PCollection<byte[]> sourceStream = p.apply(KafkaIO.<byte[], byte[]>read()
                .withMaxNumRecords(5) // TODO: remove once done
                .withConsumerConfigUpdates(consumerConfigs)
                .withBootstrapServers(boostrapServer)
                .withTopic(sourceTopic)
                .withKeyDeserializer(ByteArrayDeserializer.class)
                .withValueDeserializer(ByteArrayDeserializer.class)
                .withLogAppendTime()
                .withReadCommitted()
                .withoutMetadata()) // PCollection<KafkaRecord<..>> -> PCollection<byte[], byte[]>
                .apply(Values.create()); // PCollection<byte[], byte[]> -> PCollection<byte[]>

        // Parse incoming requests into two PCollections:
        // tag: parsedTag = Collection<List<String>>
        // tag: brokenTag = Collection<byte[]>
        PCollectionTuple parseResults = sourceStream.apply(
                ParDo.of(new ParseRequestFn(parsedTag, brokenTag))
                        .withOutputTags(parsedTag, TupleTagList.of(brokenTag))
        );

        // Write broken data into dlq topic (dead letter queue).
        // From monitoring perspective: DLQ message arrival means
        // incorrect LoadBalancer/ReverseProxy configuration.
        parseResults
                .get(brokenTag)
                .apply(KafkaIO.<Void, byte[]>write()
                        .withBootstrapServers(boostrapServer)
                        .withTopic(dlqTopic)
                        .withValueSerializer(ByteArraySerializer.class)
                        .values()
                );

        // Analyze User-agent from parsed results.
        // Once done, write final parsed user-agent
        // into separate topic.
        // TODO: serialize
        parseResults
                .get(parsedTag)
                .apply(ParDo.of(new CollectAgentsFn()));

        // Cleanup the request uri from parsed results.
        // Once done, write final parsed impression
        // into separate topic.
        // TODO: serialize
        parseResults
                .get(parsedTag)
                .apply(ParDo.of(new NormalizeUriFn()));


        // Start the pipeline.
        p.run().waitUntilFinish();
    }
}
