package org.simple.analytics.example.fn;

import org.apache.beam.sdk.transforms.DoFn;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.StringUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * Normalize request uri representation
 */
public class NormalizeUriFn extends DoFn<List<String>, List<String>> {

    @ProcessElement
    public void processElement(@Element List<String> src, OutputReceiver<List<String>> dst) {
        // transform: /some-url.jpg -> some-url
        String s0 = src.get(0);
        String s1 = StringUtils.stripStart(s0, "/");
        String s2 = FilenameUtils.removeExtension(s1);

        List<String> out = new ArrayList<>();
        out.add(s2);
        out.addAll(src.subList(1, src.size()));
        dst.output(out);
    }
}
