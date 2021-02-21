package org.simple.analytics.example.fn;

import org.apache.beam.sdk.transforms.DoFn;

import org.apache.hc.core5.http.ClassicHttpRequest;
import org.apache.hc.core5.http.HttpException;
import org.apache.hc.core5.http.impl.io.DefaultHttpRequestParser;
import org.apache.hc.core5.http.impl.io.SessionInputBufferImpl;
import org.apache.hc.core5.http.io.SessionInputBuffer;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

public class ParseHitFn extends DoFn<byte[], List<String>> {

    @ProcessElement
    public void processElement(@Element byte[] in, OutputReceiver<List<String>> out) {
        ByteArrayInputStream inputStream = new ByteArrayInputStream(in);
        SessionInputBuffer inputBuffer = new SessionInputBufferImpl(4096);
        DefaultHttpRequestParser parser = new DefaultHttpRequestParser();

        try {
            ClassicHttpRequest parsed = parser.parse(inputBuffer, inputStream);
            List<String> respond = Arrays.asList(
                    parsed.getRequestUri(),
                    parsed.getHeader("x-forwarded-for").getValue(),
                    parsed.getHeader("referer").getValue(),
                    parsed.getHeader("user-agent").getValue()
            );
            out.output(respond);

        } catch (NullPointerException | IOException | HttpException e) {
            // TODO: log exception here..
        }
    }
}
