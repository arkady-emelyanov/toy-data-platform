package simple.analytics.example.fn;

import org.apache.beam.sdk.testing.PAssert;
import org.apache.beam.sdk.testing.TestPipeline;
import org.apache.beam.sdk.transforms.Create;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.values.PCollection;
import org.apache.beam.sdk.values.PCollectionTuple;
import org.apache.beam.sdk.values.TupleTag;
import org.apache.beam.sdk.values.TupleTagList;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import org.simple.analytics.example.fn.NormalizeHostFn;
import org.simple.analytics.example.fn.NormalizeUriFn;
import org.simple.analytics.example.fn.ParseRequestFn;

import java.io.Serializable;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@RunWith(JUnit4.class)
public class ParDoFnTest implements Serializable {

    @Rule
    public final transient TestPipeline pipeline = TestPipeline.create();

    @Test
    public void normalizeDomainFnTest() {
        List<List<String>> source = Arrays.asList(
                Arrays.asList("a69aa587eee4", "127.0.0.1:8080", "1.1.1.1", "example.com", "curl"),
                Arrays.asList("b2c545bffc4e", "example.com:443", "1.1.1.1", "example.com", "curl")
        );

        PCollection<List<String>> received = pipeline
                .apply(Create.of(source))
                .apply(ParDo.of(new NormalizeHostFn()));

        List<List<String>> expected = Arrays.asList(
                Arrays.asList("a69aa587eee4", "127.0.0.1", "1.1.1.1", "example.com", "curl"),
                Arrays.asList("b2c545bffc4e", "example.com", "1.1.1.1", "example.com", "curl")
        );

        PAssert.that(received).containsInAnyOrder(expected);
        pipeline.run().waitUntilFinish();
    }

    @Test
    public void normalizeUriFnTest() {
        List<List<String>> source = Arrays.asList(
                Arrays.asList("/a69aa587eee4.png", "127.0.0.1:8080", "1.1.1.1", "example.com", "curl"),
                Arrays.asList("/b2c545bffc4e.gif", "-", "1.1.1.1", "example.com", "curl")
        );

        PCollection<List<String>> received = pipeline
                .apply(Create.of(source))
                .apply(ParDo.of(new NormalizeUriFn()));

        List<List<String>> expected = Arrays.asList(
                Arrays.asList("a69aa587eee4", "127.0.0.1:8080", "1.1.1.1", "example.com", "curl"),
                Arrays.asList("b2c545bffc4e", "-", "1.1.1.1", "example.com", "curl")
        );

        PAssert.that(received).containsInAnyOrder(expected);
        pipeline.run().waitUntilFinish();
    }

    @Test
    public void parseRawRequestFnTest() {
        List<String> requestRawList = new ArrayList<>();
        requestRawList.add(
                "GET /hello-world.png HTTP/1.0\n" +
                        "Host: 127.0.0.1:8080\n" +
                        "Referer: example.com\n" +
                        "X-Forwarded-For: 1.1.1.1\n" +
                        "User-Agent: curl\n" +
                        "\n\n"
        );
        requestRawList.add(
                "GET /hello-world.png HTTP/1.0\n" +
                        "Referer: example.com\n" +
                        "X-Forwarded-For: 1.1.1.1\n" +
                        "User-Agent: curl\n" +
                        "\n\n"
        );
        requestRawList.add(
                "GET / HTTP/1.0\n" +
                        "Broken-Record"
        );

        List<byte[]> requestRawBytesList = new ArrayList<>();
        for (String srcString : requestRawList) {
            requestRawBytesList.add(srcString.getBytes(StandardCharsets.UTF_8));
        }

        // Two receivers: one for parsed responses, one for broken
        TupleTag<List<String>> parsedTag = new TupleTag<>() {
        };
        TupleTag<byte[]> brokenTag = new TupleTag<>() {
        };

        // Pipeline
        PCollectionTuple received = pipeline
                .apply(Create.of(requestRawBytesList))
                .apply(ParDo.of(new ParseRequestFn(parsedTag, brokenTag))
                        .withOutputTags(parsedTag, TupleTagList.of(brokenTag))
                );


        // Here is our list of expectations:
        List<List<String>> dstRowClean = Arrays.asList(
                Arrays.asList("/hello-world.png", "127.0.0.1:8080", "1.1.1.1", "example.com", "curl"),
                Arrays.asList("/hello-world.png", "-", "1.1.1.1", "example.com", "curl")
        );
        PAssert.that(received.get(parsedTag)).containsInAnyOrder(dstRowClean);

        // Here is our parse failure expectation
        byte[] dstRowBroken = requestRawBytesList.get(2);
        PAssert.that(received.get(brokenTag)).containsInAnyOrder(dstRowBroken);

        // Run and observe results..
        pipeline.run().waitUntilFinish();
    }
}
