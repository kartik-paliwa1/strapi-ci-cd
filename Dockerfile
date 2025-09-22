# Dockerfile
FROM node:18-alpine

# Set working directory
WORKDIR /opt/app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the Strapi application for production
ENV NODE_ENV=production
RUN npm run build

# Expose the port Strapi runs on
EXPOSE 1337

# Start command
CMD ["npm", "run", "start"]
