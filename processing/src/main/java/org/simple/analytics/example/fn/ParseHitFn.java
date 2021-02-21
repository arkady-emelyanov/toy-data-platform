package org.simple.analytics.example.fn;

import org.apache.beam.sdk.transforms.DoFn;

import org.apache.beam.sdk.values.TupleTag;
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

    private final TupleTag<List<String>> parsedTag;
    private final TupleTag<byte[]> brokenTag;

    public ParseHitFn(TupleTag<List<String>> parsedTag, TupleTag<byte[]> brokenTag) {
        this.parsedTag = parsedTag;
        this.brokenTag = brokenTag;
    }

    @ProcessElement
    public void processElement(@Element byte[] in, MultiOutputReceiver out) {
        ByteArrayInputStream inputStream = new ByteArrayInputStream(in);
        SessionInputBuffer inputBuffer = new SessionInputBufferImpl(4096);
        DefaultHttpRequestParser parser = new DefaultHttpRequestParser();

        try {
            ClassicHttpRequest req = parser.parse(inputBuffer, inputStream);
            List<String> respond = Arrays.asList(
                    req.getRequestUri(),
                    req.getHeader("x-forwarded-for").getValue(),
                    req.getHeader("referer").getValue(),
                    req.getHeader("user-agent").getValue()
            );
            out.get(parsedTag).output(respond);

        } catch (NullPointerException | IOException | HttpException e) {
            out.get(brokenTag).output(in);
        }
    }
}
