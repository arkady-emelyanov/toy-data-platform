package org.simple.analytics.example.fn;

import org.apache.beam.sdk.transforms.DoFn;

import org.simple.analytics.example.pojo.Impression;

import java.util.List;

public class MapImpression extends DoFn<List<String>, Impression> {

    @ProcessElement
    public void processElement(@Element List<String> src, OutputReceiver<Impression> dst) {
        Impression imp = new Impression(src.get(0), src.get(1), src.get(2));
        dst.output(imp);
    }
}
