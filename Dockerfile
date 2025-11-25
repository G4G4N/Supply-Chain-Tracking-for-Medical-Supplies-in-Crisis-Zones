# Multi-stage build for React dApp
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY supply-chain-dapp/package*.json ./

# Install dependencies
RUN npm ci --only=production=false

# Copy source code
COPY supply-chain-dapp/ ./

# Build arguments for environment variables
ARG REACT_APP_CONTRACT_ADDRESS
ARG REACT_APP_NETWORK
ARG REACT_APP_ENABLE_ANALYTICS
ARG REACT_APP_ENABLE_ERROR_TRACKING
ARG REACT_APP_SENTRY_DSN

# Set environment variables
ENV REACT_APP_CONTRACT_ADDRESS=$REACT_APP_CONTRACT_ADDRESS
ENV REACT_APP_NETWORK=$REACT_APP_NETWORK
ENV REACT_APP_ENABLE_ANALYTICS=$REACT_APP_ENABLE_ANALYTICS
ENV REACT_APP_ENABLE_ERROR_TRACKING=$REACT_APP_ENABLE_ERROR_TRACKING
ENV REACT_APP_SENTRY_DSN=$REACT_APP_SENTRY_DSN

# Build application
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built application
COPY --from=builder /app/build /usr/share/nginx/html

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Use non-root user
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d

USER nginx

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

