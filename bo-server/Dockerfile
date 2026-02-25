# Base image
FROM node:18

# Increase heap max size
ENV NODE_OPTIONS=--max_old_space_size=8192

# Create app directory
WORKDIR /usr/src/app

# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY bo-server/package*.json ./

# Install app dependencies
RUN npm install

# Bundle app source
COPY bo-server/. .

# Creates a "dist" folder with the production build
RUN npm run build

# Expose the port the app runs in
EXPOSE 3000

# Start the server using the production build
CMD [ "node", "dist/main.js" ]