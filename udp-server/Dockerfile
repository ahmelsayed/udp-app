FROM golang:1.21

WORKDIR /src

COPY main.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -o /udp-server main.go

CMD ["/udp-server"]
