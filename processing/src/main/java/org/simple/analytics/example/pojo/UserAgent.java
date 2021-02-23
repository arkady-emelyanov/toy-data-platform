package org.simple.analytics.example.pojo;

import org.apache.beam.sdk.schemas.JavaBeanSchema;
import org.apache.beam.sdk.schemas.annotations.DefaultSchema;

import java.util.List;
import java.util.Objects;

@DefaultSchema(JavaBeanSchema.class)
public class UserAgent {
    public String pixelId;
    public String deviceClass;
    public String deviceName;
    public String operatingSystemName;

    public UserAgent() {
    }

    public static UserAgent fromList(List<String> fields) {
        UserAgent obj = new UserAgent();
        obj.setPixelId(fields.get(0));
        obj.setDeviceClass(fields.get(1));
        obj.setDeviceName(fields.get(2));
        obj.setOperatingSystemName(fields.get(3));
        return obj;
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

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        UserAgent userAgent = (UserAgent) o;
        return pixelId.equals(userAgent.pixelId)
                && deviceClass.equals(userAgent.deviceClass)
                && deviceName.equals(userAgent.deviceName)
                && operatingSystemName.equals(userAgent.operatingSystemName);
    }

    @Override
    public int hashCode() {
        return Objects.hash(pixelId, deviceClass, deviceName, operatingSystemName);
    }
}
