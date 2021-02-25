package org.simple.analytics.example.pardo;

import nl.basjes.parse.useragent.UserAgent;
import nl.basjes.parse.useragent.UserAgentAnalyzer;
import org.apache.beam.sdk.io.kafka.KafkaRecord;
import org.apache.beam.sdk.metrics.Counter;
import org.apache.beam.sdk.metrics.Metrics;
import org.apache.beam.sdk.schemas.Schema;
import org.apache.beam.sdk.transforms.DoFn;

import org.apache.beam.sdk.values.Row;
import org.apache.beam.sdk.values.TupleTag;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.hc.core5.http.ClassicHttpRequest;
import org.apache.hc.core5.http.Header;
import org.apache.hc.core5.http.HttpException;
import org.apache.hc.core5.http.ProtocolException;
import org.apache.hc.core5.http.impl.io.DefaultHttpRequestParser;
import org.apache.hc.core5.http.impl.io.SessionInputBufferImpl;
import org.apache.hc.core5.http.io.SessionInputBuffer;

import java.io.ByteArrayInputStream;
import java.io.IOException;

/**
 * The raw request parser.
 */
public class ProcessRequestDo extends DoFn<KafkaRecord<byte[], byte[]>, Row> {

    private final Counter parsedCounter = Metrics.counter("parse", "parsed");
    private final Counter brokenCounter = Metrics.counter("parse", "broken");

    private final TupleTag<Row> parsedTag;
    private final TupleTag<byte[]> brokenTag;
    private final Schema rowSchema;
    private final UserAgentAnalyzer userAgentAnalyzer;

    public ProcessRequestDo(TupleTag<Row> parsedTag, TupleTag<byte[]> brokenTag, Schema rowSchema) {
        this.parsedTag = parsedTag;
        this.brokenTag = brokenTag;
        this.rowSchema = rowSchema;
        this.userAgentAnalyzer = UserAgentAnalyzer.
                newBuilder().
                hideMatcherLoadStats().
                withCache(2048).
                build();
    }

    private String getHeaderValue(ClassicHttpRequest req, String name) {
        try {
            Header hdr = req.getHeader(name);
            if (hdr == null) {
                return null;
            }
            String val = hdr.getValue();
            if (val != null) {
                return val;
            }
        } catch (ProtocolException e) {
            // nothing to-do, skip to default
        }
        return null;
    }

    @ProcessElement
    public void processElement(@Element KafkaRecord<byte[], byte[]> src, MultiOutputReceiver dst) {
        byte[] srcValue = src.getKV().getValue();
        if (srcValue == null) {
            brokenCounter.inc();
            return;
        }

        ByteArrayInputStream inputStream = new ByteArrayInputStream(srcValue);
        SessionInputBuffer inputBuffer = new SessionInputBufferImpl(4096);
        DefaultHttpRequestParser parser = new DefaultHttpRequestParser();

        try {
            ClassicHttpRequest req = parser.parse(inputBuffer, inputStream);
            String requestUri = req.getRequestUri();
            requestUri = StringUtils.stripStart(requestUri, "/");
            requestUri = FilenameUtils.removeExtension(requestUri);

            String remoteAddr = getHeaderValue(req, "x-forwarded-for");
            if (remoteAddr == null) {
                throw new HttpException("Empty 'X-Forwarded-For' header");
            }

            String userAgent = getHeaderValue(req, "user-agent");
            UserAgent ua = userAgentAnalyzer.parse(userAgent);

            // construct Row
            Row request = Row.withSchema(rowSchema)
                    .addValues(
                            src.getTimestamp(),
                            requestUri,
                            remoteAddr,
                            ua.getValue("DeviceClass"),
                            ua.getValue("DeviceName"),
                            ua.getValue("OperatingSystemName")
                    )
                    .build();

            parsedCounter.inc();
            dst.get(parsedTag).output(request);

        } catch (IOException | HttpException e) {
            // That should not be the case when Beacon is behind the ALB/NGINX Load Balancer.
            // Still, exception could happen if one of the required headers is missing.
            brokenCounter.inc();
            dst.get(brokenTag).output(srcValue);
        }
    }
}
