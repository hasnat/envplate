ARG CACHE_TAG
FROM golang:1.9 as builder

WORKDIR /go/src/github.com/kreuzwerker/envplate

RUN go get \
    github.com/tools/godep \
    github.com/mitchellh/gox

COPY Godeps/Godeps.json ./Godeps/Godeps.json
RUN godep restore
COPY . .
RUN go get -d -v
RUN go test -v ./...

RUN gox -output='bin/{{.OS}}-{{.Arch}}/ep' ./bin


FROM alpine:3.6 AS envplate-binaries
COPY --from=builder /go/src/github.com/kreuzwerker/envplate/bin /ep/bin


FROM alpine:3.6 AS envplate-latest
COPY --from=builder /go/src/github.com/kreuzwerker/envplate/bin/linux-arm/ep /usr/local/bin/ep
ENTRYPOINT ["ep"]

FROM envplate-${CACHE_TAG}
