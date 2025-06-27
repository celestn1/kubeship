# kubeship/nginx/Dockerfile

# ---- Build Stage ----
FROM node:20-alpine AS builder

ARG VITE_API_URL=/v1/auth
ENV VITE_API_URL=${VITE_API_URL}

WORKDIR /app

# 1. Copy package files & install deps
COPY microservices/frontend/package*.json ./
RUN npm ci

# 2. Copy shared code
COPY shared/ ./shared

# 3. Copy frontend code
COPY microservices/frontend/ ./

# 4. Build static site
RUN npm run build

# ---- Production Stage ----
FROM nginx:alpine

# 5. Remove any leftover default configs
#RUN rm -f /etc/nginx/conf.d/* /etc/nginx/nginx.conf

# 6. Optional: Custom nginx.conf for fallback routing [ConfigMap used in k8s]
# COPY nginx.conf /etc/nginx/nginx.conf

# 7. Copy built frontend into nginx’s html
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]