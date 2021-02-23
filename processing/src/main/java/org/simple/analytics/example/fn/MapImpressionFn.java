package org.simple.analytics.example.fn;

import org.apache.beam.sdk.transforms.DoFn;

import org.simple.analytics.example.pojo.Impression;

import java.util.List;

public class MapImpressionFn extends DoFn<List<String>, Impression> {

    @ProcessElement
    public void processElement(@Element List<String> src, OutputReceiver<Impression> dst) {
        Impression imp = Impression.fromList(src);
        dst.output(imp);
    }
}
