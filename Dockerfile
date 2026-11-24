
# Use Node.js 20
FROM node:20-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package files first
COPY package*.json ./

# Install application dependencies
RUN npm ci

# Copy the application files
COPY . .

# Application listens on port 3000
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
