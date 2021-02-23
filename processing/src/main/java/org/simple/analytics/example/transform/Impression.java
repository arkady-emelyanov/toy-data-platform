package org.simple.analytics.example.transform;

import org.apache.beam.sdk.transforms.PTransform;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.transforms.ToJson;
import org.apache.beam.sdk.values.PCollection;

import org.simple.analytics.example.fn.MapImpressionFn;

import java.util.List;

public class Impression extends PTransform<PCollection<List<String>>, PCollection<String>> {

    @Override
    public PCollection<String> expand(PCollection<List<String>> input) {
        return input
                .apply(ParDo.of(new MapImpressionFn()))
                .apply(ToJson.of());
    }
}
