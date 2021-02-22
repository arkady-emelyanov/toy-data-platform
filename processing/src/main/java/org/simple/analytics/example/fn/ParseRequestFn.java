package org.simple.analytics.example.fn;

import org.apache.beam.sdk.transforms.DoFn;

import org.apache.beam.sdk.values.TupleTag;
import org.apache.hc.core5.http.ClassicHttpRequest;
import org.apache.hc.core5.http.Header;
import org.apache.hc.core5.http.HttpException;
import org.apache.hc.core5.http.ProtocolException;
import org.apache.hc.core5.http.impl.io.DefaultHttpRequestParser;
import org.apache.hc.core5.http.impl.io.SessionInputBufferImpl;
import org.apache.hc.core5.http.io.SessionInputBuffer;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

/**
 * The raw request parser.
 */
public class ParseRequestFn extends DoFn<byte[], List<String>> {

    private final TupleTag<List<String>> parsedTag;
    private final TupleTag<byte[]> brokenTag;

    public ParseRequestFn(TupleTag<List<String>> parsedTag, TupleTag<byte[]> brokenTag) {
        this.parsedTag = parsedTag;
        this.brokenTag = brokenTag;
    }

    private String getHeaderValue(ClassicHttpRequest req, String name) {
        try {
            Header hdr = req.getHeader(name);
            if (hdr != null) {
                String val = hdr.getValue();
                if (val != null) {
                    return val;
                }
            }
        } catch (ProtocolException e) {
            // nothing to-do, skip to default
        }
        return "-";
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
                    getHeaderValue(req, "host"),
                    getHeaderValue(req, "x-forwarded-for"),
                    getHeaderValue(req, "referer"),
                    getHeaderValue(req, "user-agent")
            );
            out.get(parsedTag).output(respond);

        } catch (IOException | HttpException e) {
            // That should not be the case when Beacon is behind the ALB/NGINX Load Balancer.
            // Still, exception could happen if one of the required headers is missing.
            out.get(brokenTag).output(in);
        }
    }
}
