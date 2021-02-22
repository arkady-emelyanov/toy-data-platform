package org.simple.analytics.example;

import org.apache.commons.text.StringSubstitutor;

import java.util.HashMap;
import java.util.Map;

/**
 * Load mock data into Kafka broker
 * (used for testing purposes)
 */
public class DataGen {

    public static void main(String[] args) {
        Map<String, String> values = new HashMap<>();
        values.put("request-uri", "/pixel.png");
        values.put("x-forwarded-for", "127.0.0.1");
        values.put("referer", "www.example.com");
        values.put("user-agent", "curl");

        String fmt = "GET ${request-uri} HTTP/1.0\n" +
                "Host: beacon.example.com\n" +
                "Referer: ${referer}\n" +
                "X-Forwarded-For: ${x-forwarded-for}\n" +
                "User-Agent: ${user-agent}\n" +
                "\n\n";

        StringSubstitutor sub = new StringSubstitutor(values);
        String out = sub.replace(fmt);

        System.out.println(out);
    }
}
