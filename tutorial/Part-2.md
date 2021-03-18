# Toolchain setup

Install `brew` package manager, installation instructions published
on the official website: https://brew.sh/

Install Docker Desktop for Mac, the installer is available on
the official website: https://hub.docker.com/editions/community/docker-ce-desktop-mac

## Golang

Setting up Golang:

```
$ brew install go
$ mkdir -p /Users/arkady/Projects/tools/go
```

Add following environment variables to `.bash_profile`:

```
export GOPATH="/Users/arkady/Projects/tools/go"
export PATH="${PATH}:${GOPATH}/bin"
```

* `GOPATH` is where Go packages will be installed 
  (when using `go get` as packet manager) 
* `${GOPATH}/bin` is where package command line utilities will 
  be installed: to be able to run them from any directory, expose `bin`
  to the system path.

Validate `go` is installed:

```
$ go version
go version go1.16 darwin/amd64
```

## JDK 11

```
$ brew tap AdoptOpenJDK/openjdk
$ brew install --cask adoptopenjdk11 
```

Add following environment variables to `.bash_profile`:

```
export JAVA_HOME="/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home"
```

Validate `java` is installed:

```
$ java -version
openjdk version "11.0.10" 2021-01-19
OpenJDK Runtime Environment AdoptOpenJDK (build 11.0.10+9)
OpenJDK 64-Bit Server VM AdoptOpenJDK (build 11.0.10+9, mixed mode)
```

## Apache Maven

```
$ brew install maven
```

Validate `mvn` is installed:

```
$ mvn --version
Apache Maven 3.6.3 (cecedd343002696d0abb50b32b541b8a6ba2883f)
Maven home: /usr/local/Cellar/maven/3.6.3_1/libexec
Java version: 11.0.10, vendor: AdoptOpenJDK, runtime: /Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home
Default locale: en_GB, platform encoding: UTF-8
OS name: "mac os x", version: "10.15.7", arch: "x86_64", family: "mac"
```

## Hadoop

## Spark

## Flink

## Kafka

## Minikube

## Terraform

## Helm

