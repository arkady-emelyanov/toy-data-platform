package org.simple.analytics.example.fn;

import org.apache.beam.sdk.transforms.DoFn;

import org.simple.analytics.example.pojo.UserAgent;

import java.util.List;

public class MapUserAgentFn extends DoFn<List<String>, UserAgent> {

    @ProcessElement
    public void processElement(@Element List<String> src, OutputReceiver<UserAgent> dst) {
        UserAgent ua = UserAgent.fromList(src);
        dst.output(ua);
    }
}
