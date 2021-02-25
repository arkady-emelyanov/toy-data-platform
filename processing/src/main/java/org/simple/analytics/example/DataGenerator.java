package org.simple.analytics.example;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import com.github.javafaker.Faker;
import org.apache.commons.text.StringSubstitutor;
import org.apache.kafka.common.serialization.ByteArraySerializer;

import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.ExecutionException;

/**
 * Load mock data into Kafka broker
 * (used for testing purposes)
 */
public class DataGenerator {

    private static final Faker faker = new Faker();
    private static final String requestFmt = "GET /${pixel-id}.png HTTP/1.0\n" +
            "Host: beacon.example.com\n" +
            "X-Forwarded-For: ${x-forwarded-for}\n" +
            "User-Agent: ${user-agent}\n" +
            "\n\n";

    private static byte[] getRequest(Map<String, String> values) {
        StringSubstitutor sub = new StringSubstitutor(values);
        String req = sub.replace(requestFmt);
        return req.getBytes(StandardCharsets.UTF_8);
    }

    public static void main(String[] args) throws InterruptedException, ExecutionException {
        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "127.0.0.1:9092");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, ByteArraySerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, ByteArraySerializer.class.getName());
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        KafkaProducer<byte[], byte[]> producer = new KafkaProducer<>(props);

        String pixelId = faker.internet().uuid();
        for (int i = 0; i < 50; i++) {
            Map<String, String> values = new HashMap<>();
            values.put("pixel-id", pixelId);
            values.put("x-forwarded-for", faker.internet().ipV4Address());
            values.put("user-agent", faker.internet().userAgentAny());
            byte[] req = getRequest(values);

            ProducerRecord<byte[], byte[]> hit = new ProducerRecord<>("v1.raw", null, req);
            producer.send(hit);
        }

        producer.close();
        System.out.println("Load done!");
    }
}
