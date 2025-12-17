FROM golang:1.25-alpine AS builder
RUN apk add --no-cache ca-certificates git
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags="-s -w" -o mongodb_exporter

FROM gcr.io/distroless/static-debian12
COPY --from=builder /app/mongodb_exporter /mongodb_exporter
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
EXPOSE 9216
ENTRYPOINT ["/mongodb_exporter"]
