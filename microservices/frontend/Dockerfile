# kubeship/microservices/frontend/Dockerfile
# Added to test docker image push 8
FROM node:20-alpine

WORKDIR /app

# 1) Copy just the package files and install deps
COPY microservices/frontend/package*.json ./
RUN npm ci

# 2) Bring in your shared code from shared directory
COPY shared/ ./shared

# 3) Copy the rest of the frontend
COPY microservices/frontend/ ./

# 4) Build
RUN npm run build

EXPOSE 3000
CMD ["npm", "run", "preview"]
