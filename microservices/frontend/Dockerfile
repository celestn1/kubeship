FROM node:20-alpine

WORKDIR /app
COPY . .
# Then copy shared module (relative to Docker build context)
COPY ../../shared ./shared


RUN npm install
RUN npm run build

EXPOSE 3000

CMD ["npm", "run", "preview"]
