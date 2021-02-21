package simple.analytics.example.fn;

import org.apache.beam.sdk.testing.PAssert;
import org.apache.beam.sdk.testing.TestPipeline;
import org.apache.beam.sdk.transforms.Create;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.values.PCollection;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import org.simple.analytics.example.fn.ParseHitFn;

import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

@RunWith(JUnit4.class)
public class ParseHitFnTest {

    @Rule
    public final transient TestPipeline pipeline = TestPipeline.create();

    @Test
    public void parseSingleHitFn() {
        String srcString = "GET /hello-world.png HTTP/1.0\n" +
                "Referer: example.com\n" +
                "X-Forwarded-For: 1.1.1.1\n" +
                "User-Agent: curl\n" +
                "\n\n";

        byte[] srcBytes = srcString.getBytes(StandardCharsets.UTF_8);
        List<byte[]> req = Collections.singletonList(srcBytes);

        // Parse raw source request header into tuple
        PCollection<List<String>> parsed = pipeline
                .apply(Create.of(req))
                .apply(ParDo.of(new ParseHitFn()));


        // TODO: describe why
        List<String> dstTuple = Arrays.asList(
                "/hello-world.png",
                "1.1.1.1",
                "example.com",
                "curl"
        );
        List<List<String>> dstColl = Collections.singletonList(dstTuple);
        PAssert.that(parsed).containsInAnyOrder(dstColl);

        // Run and observe results..
        pipeline.run().waitUntilFinish();
    }
}
