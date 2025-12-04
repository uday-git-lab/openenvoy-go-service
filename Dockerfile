# --- Builder Stage ---
    FROM golang:1.21-alpine AS builder

    WORKDIR /app
    
    # Copy module file first for caching
    COPY go.mod ./
    COPY . .
    
    # Enforce formatting: fail if go fmt outputs any files
    RUN test -z "$(go fmt ./...)"
    
    # Build static binary
    RUN CGO_ENABLED=0 GOOS=linux go build -o /app/server .
    
    # --- Final Stage ---
    FROM alpine:latest
    
    WORKDIR /root/
    COPY --from=builder /app/server .
    
    # App listens on 8080 in main.go
    EXPOSE 8080
    
    CMD ["./server"]    