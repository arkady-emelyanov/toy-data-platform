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

import org.simple.analytics.example.fn.ParseHitFn;

import java.io.Serializable;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

@RunWith(JUnit4.class)
public class ParseHitFnTest implements Serializable {

    @Rule
    public final transient TestPipeline pipeline = TestPipeline.create();

    @Test
    public void parseSingleHitFn() {
        List<String> allOfThem = new ArrayList<>();
        allOfThem.add(
                "GET /hello-world.png HTTP/1.0\n" +
                        "Referer: example.com\n" +
                        "X-Forwarded-For: 1.1.1.1\n" +
                        "User-Agent: curl\n" +
                        "\n\n"
        );
        allOfThem.add(
                "GET / HTTP/1.0\n" +
                        "Broken-Record"
        );

        List<byte[]> srcListBytes = new ArrayList<>();
        for (String srcString : allOfThem) {
            srcListBytes.add(srcString.getBytes(StandardCharsets.UTF_8));
        }

        // Two receivers: one for parsed responses, one for broken
        final TupleTag<List<String>> parsedTag = new TupleTag<>() {};
        final TupleTag<byte[]> brokenTag = new TupleTag<>() {};

        // Parse raw source request header into tuple
        PCollectionTuple received = pipeline
                .apply(Create.of(srcListBytes))
                .apply(ParDo.of(new ParseHitFn(parsedTag, brokenTag))
                        .withOutputTags(parsedTag, TupleTagList.of(brokenTag))
                );


        // TODO: describe why
        List<String> dstTuple = Arrays.asList(
                "/hello-world.png",
                "1.1.1.1",
                "example.com",
                "curl"
        );
        List<List<String>> dstColl = Collections.singletonList(dstTuple);
        PAssert.that(received.get(parsedTag)).containsInAnyOrder(dstColl);
        PAssert.that(received.get(brokenTag)).containsInAnyOrder(srcListBytes.get(1));

        // Run and observe results..
        pipeline.run().waitUntilFinish();
    }
}
