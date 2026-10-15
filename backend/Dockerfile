FROM node:20-alpine

WORKDIR /app

# Install app dependencies
COPY package*.json ./
RUN npm ci --omit=dev || npm install --omit=dev

# Bundle app source
COPY . .

# Expose port (default 3000, Railway will override via PORT environment variable)
EXPOSE 3000

ENV NODE_ENV=production

CMD ["npm", "start"]
