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

import org.simple.analytics.example.fn.NormalizeUriFn;

import java.util.Arrays;
import java.util.List;

@RunWith(JUnit4.class)
public class NormalizeUriFnTest {

    @Rule
    public final transient TestPipeline pipeline = TestPipeline.create();

    @Test
    public void normalizeUriFn() {
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
}
