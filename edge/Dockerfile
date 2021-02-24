FROM golang:1.15.8-alpine AS build
RUN apk --update add git

WORKDIR /src
ADD go.mod .
ADD go.sum .
RUN go mod download

ENV GO111MODULE=on \
    CGO_ENABLED=0

COPY . .
RUN go build -o app ./main.go

FROM alpine:3.13.2
COPY --from=build /src/app /
CMD ["/app", "-listen=0.0.0.0:8080", "-metric-listen=0.0.0.0:9100", "-stdout=true"]
