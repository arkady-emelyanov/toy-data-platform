package org.simple.analytics.example.fn;

import org.apache.beam.sdk.transforms.DoFn;

import org.simple.analytics.example.pojo.UserAgent;

import java.util.List;

public class MapUserAgent extends DoFn<List<String>, UserAgent> {

    @ProcessElement
    public void processElement(@Element List<String> src, OutputReceiver<UserAgent> dst) {
        UserAgent ua = new UserAgent(src.get(0), src.get(1), src.get(2), src.get(3));
        dst.output(ua);
    }
}
