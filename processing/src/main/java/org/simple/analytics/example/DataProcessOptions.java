package org.simple.analytics.example;

import org.apache.beam.sdk.options.Default;
import org.apache.beam.sdk.options.Description;
import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.Validation;

public interface DataProcessOptions extends PipelineOptions {
    @Description("Broker endpoint URL")
    @Validation.Required
    String getBrokerUrl();

    void setBrokerUrl(String brokerUrl);

    @Description("Consumer group.id")
    @Default.String("stream-hits")
    String getGroupId();

    void setGroupId(String groupId);

    @Description("Auto reset offsets config")
    @Default.String("earliest")
    String getAutoResetOffsets();

    void setAutoResetOffsets(String autoResetOffsets);

    @Description("Topic for reading raw requests")
    @Default.String("v1.raw")
    String getSourceTopic();

    void setSourceTopic(String rawTopic);

    @Description("Topic for writing impressions")
    @Default.String("v1.hits")
    String getHitsTopic();

    void setHitsTopic(String impressionsTopic);

    @Description("Topic for writing broken raw requests")
    @Default.String("v1.dlq")
    String getDeadLetterQueueTopic();

    void setDeadLetterQueueTopic(String deadLetterQueueTopic);
}
