package org.simple.analytics.example;

import org.apache.beam.sdk.io.kafka.KafkaRecord;
import org.apache.beam.sdk.schemas.Schema;
import org.apache.beam.sdk.schemas.SchemaCoder;
import org.apache.beam.sdk.transforms.ToJson;
import org.apache.beam.sdk.values.*;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.ByteArrayDeserializer;
import org.apache.kafka.common.serialization.ByteArraySerializer;
import org.apache.kafka.common.serialization.StringSerializer;

import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.io.kafka.KafkaIO;
import org.apache.beam.sdk.transforms.ParDo;

import java.util.HashMap;
import java.util.Map;


/**
 * Main Processing pipeline
 */
public class DataProcess {

    // Tag for parsed records, records will be processed further.
    private static final TupleTag<Row> parsedTag = new TupleTag<>() {
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
        // Parse command-line options
        DataProcessOptions options = PipelineOptionsFactory.fromArgs(args)
                .withValidation()
                .as(DataProcessOptions.class);

        // Prepare Kafka producer/consumer configurations:
        Map<String, Object> consumerProps = new HashMap<>();
        consumerProps.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, options.getBrokerUrl());
        consumerProps.put(ConsumerConfig.GROUP_ID_CONFIG, options.getGroupId());
        consumerProps.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, options.getAutoResetOffsets());

        Map<String, Object> producerProps = new HashMap<>();
        producerProps.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, options.getBrokerUrl());
        producerProps.put(ProducerConfig.ACKS_CONFIG, "all");

        Pipeline processingPipeline = Pipeline.create(options);
        PCollection<KafkaRecord<byte[], byte[]>> kafkaRawStream = processingPipeline
                .apply(KafkaIO.<byte[], byte[]>read()
                        .withConsumerConfigUpdates(consumerProps)
                        .withTopic(options.getSourceTopic())
                        .withKeyDeserializer(ByteArrayDeserializer.class)
                        .withValueDeserializer(ByteArrayDeserializer.class)
                        .withReadCommitted()
                );

        // Define our row schema
        Schema rowSchema = Schema.builder()
                .addInt64Field("timestamp")
                .addStringField("pixel")
                .addNullableField("remote_addr", Schema.FieldType.STRING)
                .addStringField("device_class")
                .addStringField("device_name")
                .addStringField("operating_system")
                .build();

        // Parse incoming requests into two PCollections:
        PCollectionTuple parsedStream = kafkaRawStream
                .apply(ParDo.of(new RequestProcessParDo(parsedTag, brokenTag, rowSchema))
                        .withOutputTags(parsedTag, TupleTagList.of(brokenTag)));

        // Write broken data to DLQ topic
        parsedStream
                .get(brokenTag)
                .apply(KafkaIO.<Void, byte[]>write()
                        .withProducerConfigUpdates(producerProps)
                        .withTopic(options.getDeadLetterQueueTopic())
                        .withValueSerializer(ByteArraySerializer.class)
                        .values()
                );

        // Write parsed data to Hits topic
        parsedStream
                .get(parsedTag)
                .setCoder(SchemaCoder.of(rowSchema))
                .apply(ToJson.of())
                .apply(KafkaIO.<Void, String>write()
                        .withProducerConfigUpdates(producerProps)
                        .withTopic(options.getHitsTopic())
                        .withValueSerializer(StringSerializer.class)
                        .values()
                );

        // Start the Pipeline
        processingPipeline
                .run()
                .waitUntilFinish();
    }
}
