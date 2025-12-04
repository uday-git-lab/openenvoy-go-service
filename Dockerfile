# --- Builder Stage ---
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod ./
COPY . .

# BUG 1: This 'go fmt' command is WRONG.
# It prints the names of badly formatted files but does NOT
# return a non-zero exit code, so it will never fail the build.
# A candidate should fix this (e.g., `test -z $(go fmt ./...)`)
RUN go fmt ./...

# This build step will work fine.
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/server .

# --- Final Stage ---
FROM alpine:latest

WORKDIR /root/
COPY --from=builder /app/server .

# This EXPOSE directive is for port 8000.
# This is a classic mismatch that will cause failures.
EXPOSE 8000 

CMD ["./server"]
