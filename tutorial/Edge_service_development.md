# Edge service development

It's time for our first service: The Edge. What is the purpose of the Edge service? Well, let's take a look at following diagram:

[architecture diagram]

The purpose of the service is very simple: receive HTTP request, write it to Message Bus and respond with transparent pixel using `image/gif` Content-type response.

The full [sequence diagram](https://en.wikipedia.org/wiki/Sequence_diagram) is following:

[service sequence diagram]

Requirements and assumptions. (latency, stateless, [X-Forwared-For](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/x-forwarded-headers.html#x-forwarded-for) header)

## HTTP Server implementation

## Request writer implementation

## Observability integration

