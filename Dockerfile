# --- Builder Stage ---
    FROM golang:1.21-alpine AS builder

    WORKDIR /app
    
    # Copy module file first for better caching
    COPY go.mod ./
    COPY . .
    
    # BUG 1: Original 'go fmt ./...' never failed build on bad formatting.
    # Fix: fail the build if go fmt had to reformat anything.
    RUN set -eux; \
        CHANGED=$(go fmt ./...); \
        if [ -n "$CHANGED" ]; then \
          echo "Go source was not properly formatted. Files updated:"; \
          echo "$CHANGED"; \
          exit 1; \
        fi
    
    # Build static binary
    RUN CGO_ENABLED=0 GOOS=linux go build -o /app/server .
    
    # --- Final Stage ---
    FROM alpine:latest
    
    WORKDIR /root/
    COPY --from=builder /app/server .
    
    # BUG 2: EXPOSE 8000 but app listens on 8080 -> mismatch.
    # Fix: expose 8080, same as main.go
    EXPOSE 8080
    
    CMD ["./server"]    