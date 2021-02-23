package org.simple.analytics.example.transform;

import org.apache.beam.sdk.transforms.PTransform;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.values.PCollection;

import org.simple.analytics.example.fn.NormalizeUriFn;

import java.util.List;

public class Normalize extends PTransform<PCollection<List<String>>, PCollection<List<String>>> {

    @Override
    public PCollection<List<String>> expand(PCollection<List<String>> input) {
        return input.apply(ParDo.of(new NormalizeUriFn()));
    }
}
