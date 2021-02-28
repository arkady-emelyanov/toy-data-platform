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

ENTRYPOINT ["/app"]
CMD ["-target=http://127.0.0.1:8080", "-rate=5"]
