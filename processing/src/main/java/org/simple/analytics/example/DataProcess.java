package org.simple.analytics.example;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.ByteArrayDeserializer;
import org.apache.kafka.common.serialization.ByteArraySerializer;
import org.apache.kafka.common.serialization.StringSerializer;

import org.apache.beam.sdk.transforms.ToJson;
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

    // Kafka consumer configs
    private static final String groupId = "processing-consumer";
    private static final String offsets = "earliest";

    // Kafka topics
    private static final String sourceTopic = "v1.raw";
    private static final String impressionTopic = "v1.impressions";
    private static final String userAgentTopic = "v1.user-agents";
    private static final String dlqTopic = "v1.dlq";

    /**
     * Pipeline processor
     *
     * @param args command line arguments
     */
    public static void main(String[] args) {
        String boostrapServer = "127.0.0.1:9092"; // TODO: make configurable

        PipelineOptions options = PipelineOptionsFactory.create();
        Pipeline p = Pipeline.create(options);

        Map<String, Object> consumerProps = new HashMap<>();
        consumerProps.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, boostrapServer);
        consumerProps.put(ConsumerConfig.GROUP_ID_CONFIG, groupId);
        consumerProps.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, offsets);

        Map<String, Object> producerProps = new HashMap<>();
        producerProps.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, boostrapServer);
        producerProps.put(ProducerConfig.ACKS_CONFIG, "all");

        // Create source PCollection from Kafka topic
        // Read byte[] values from source topic.
        PCollection<byte[]> sourceStream = p.apply(KafkaIO.<byte[], byte[]>read()
                .withConsumerConfigUpdates(consumerProps)
                .withTopic(sourceTopic)
                .withKeyDeserializer(ByteArrayDeserializer.class)
                .withValueDeserializer(ByteArrayDeserializer.class)
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
                        .withProducerConfigUpdates(producerProps)
                        .withTopic(dlqTopic)
                        .withValueSerializer(ByteArraySerializer.class)
                        .values()
                );

        // Analyze User-agent from parsed results.
        // Once done, write final parsed user-agent
        // into separate topic.
        parseResults
                .get(parsedTag)
                .apply(ParDo.of(new CollectAgentsFn()))
                .apply(ParDo.of(new MapUserAgent()))
                .apply(ToJson.of())
                .apply(KafkaIO.<Void, String>write()
                        .withProducerConfigUpdates(producerProps)
                        .withTopic(userAgentTopic)
                        .withValueSerializer(StringSerializer.class)
                        .values());

        // Cleanup the request uri from parsed results.
        // Once done, write final parsed impression
        // into separate topic.
        parseResults
                .get(parsedTag)
                .apply(ParDo.of(new NormalizeUriFn()))
                .apply(ParDo.of(new MapImpression()))
                .apply(ToJson.of())
                .apply(KafkaIO.<Void, String>write()
                        .withProducerConfigUpdates(producerProps)
                        .withTopic(impressionTopic)
                        .withValueSerializer(StringSerializer.class)
                        .values());

        // Start the pipeline.
        p.run().waitUntilFinish();
    }
}
