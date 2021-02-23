package org.simple.analytics.example.pojo;

import org.apache.beam.sdk.schemas.JavaBeanSchema;
import org.apache.beam.sdk.schemas.annotations.DefaultSchema;

@DefaultSchema(JavaBeanSchema.class)
public class UserAgent {
    public String pixelId;
    public String deviceClass;
    public String deviceName;
    public String operatingSystemName;

    public UserAgent() {
    }

    public UserAgent(String pixelId, String dc, String dn, String os) {
        this.pixelId = pixelId;
        this.deviceClass = dc;
        this.deviceName = dn;
        this.operatingSystemName = os;
    }

    public String getPixelId() {
        return pixelId;
    }

    public void setPixelId(String pixelId) {
        this.pixelId = pixelId;
    }

    public String getDeviceClass() {
        return deviceClass;
    }

    public void setDeviceClass(String deviceClass) {
        this.deviceClass = deviceClass;
    }

    public String getDeviceName() {
        return deviceName;
    }

    public void setDeviceName(String deviceName) {
        this.deviceName = deviceName;
    }

    public String getOperatingSystemName() {
        return operatingSystemName;
    }

    public void setOperatingSystemName(String operatingSystemName) {
        this.operatingSystemName = operatingSystemName;
    }
}
