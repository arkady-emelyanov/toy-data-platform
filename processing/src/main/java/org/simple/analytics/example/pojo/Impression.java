package org.simple.analytics.example.pojo;

import org.apache.beam.sdk.schemas.JavaBeanSchema;
import org.apache.beam.sdk.schemas.annotations.DefaultSchema;

import java.util.List;
import java.util.Objects;

@DefaultSchema(JavaBeanSchema.class)
public class Impression {
    public String pixelId;
    public String remoteAddress;
    public String userAgent;

    public Impression() {
    }

    public static Impression fromList(List<String> fields) {
        Impression obj = new Impression();
        obj.setPixelId(fields.get(0));
        obj.setRemoteAddress(fields.get(1));
        obj.setUserAgent(fields.get(2));
        return obj;
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

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        Impression that = (Impression) o;
        return pixelId.equals(that.pixelId)
                && remoteAddress.equals(that.remoteAddress)
                && userAgent.equals(that.userAgent);
    }

    @Override
    public int hashCode() {
        return Objects.hash(pixelId, remoteAddress, userAgent);
    }
}
