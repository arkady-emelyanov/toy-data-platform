package org.simple.analytics.example.pojo;

import org.apache.beam.sdk.schemas.JavaBeanSchema;
import org.apache.beam.sdk.schemas.annotations.DefaultSchema;

import java.util.Objects;

@DefaultSchema(JavaBeanSchema.class)
public class Impression {
    public String pixelId;
    public String remoteAddress;
    public String userAgent;

    public Impression() {
    }

    public Impression(String pixelId, String remoteAddress, String userAgent) {
        this.pixelId = pixelId;
        this.remoteAddress = remoteAddress;
        this.userAgent = userAgent;
    }

    public String getPixelId() {
        return pixelId;
    }

    public String getRemoteAddress() {
        return remoteAddress;
    }

    public String getUserAgent() {
        return userAgent;
    }

    public void setPixelId(String pixelId) {
        this.pixelId = pixelId;
    }

    public void setRemoteAddress(String remoteAddress) {
        this.remoteAddress = remoteAddress;
    }

    public void setUserAgent(String userAgent) {
        this.userAgent = userAgent;
    }
}
