package org.simple.analytics.example.fn;

import org.apache.beam.sdk.transforms.DoFn;

import java.util.ArrayList;
import java.util.List;

/**
 * Normalize request uri representation
 */
public class NormalizeHostFn extends DoFn<List<String>, List<String>> {

    @ProcessElement
    public void processElement(@Element List<String> src, OutputReceiver<List<String>> dst) {
        List<String> out = new ArrayList<>();
        out.add(src.get(0));

        // 127.0.0.1:8080 -> 127.0.0.1
        // example.com:443 -> example.com
        String s0 = src.get(1);
        int portIndex = s0.indexOf(":");
        if (portIndex > 1) {
            String s1 = s0.substring(0, portIndex);
            out.add(s1);
        } else {
            out.add(s0);
        }

        out.addAll(src.subList(2, src.size()));
        dst.output(out);
    }
}
