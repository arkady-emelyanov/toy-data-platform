package org.simple.analytics.example.fn;

import nl.basjes.parse.useragent.UserAgent;
import nl.basjes.parse.useragent.UserAgentAnalyzer;
import org.apache.beam.sdk.transforms.DoFn;

import java.util.Arrays;
import java.util.List;

public class CollectAgentsFn extends DoFn<List<String>, List<String>> {

    private final UserAgentAnalyzer userAgentAnalyzer;

    public CollectAgentsFn() {
        userAgentAnalyzer = UserAgentAnalyzer.
                newBuilder().
                hideMatcherLoadStats().
                withCache(2048).
                build();
    }

    @ProcessElement
    public void processElement(@Element List<String> src, OutputReceiver<List<String>> dst) {
        String userAgent = src.get(4);
        UserAgent ua = userAgentAnalyzer.parse(userAgent);
        List<String> out = Arrays.asList(
                ua.getValue("DeviceClass"),
                ua.getValue("DeviceName"),
                ua.getValue("OperatingSystemName")
        );
        dst.output(out);
    }
}
