# -----------------------------------------------------------------------
# Stage 1: Build - installs deps and runs the Vite production build,
# producing static HTML/CSS/JS in /app/dist
# -----------------------------------------------------------------------
FROM node:20-alpine AS build

WORKDIR /app

# Copy package files first and install separately from source code -
# same Docker layer-caching benefit as the backend Dockerfile
COPY package.json ./
RUN npm install

COPY . .
RUN npm run build

# -----------------------------------------------------------------------
# Stage 2: Runtime - a plain nginx image serving the static build.
# The entire Node.js toolchain from Stage 1 is discarded - this final
# image is just static files + nginx, a few MB instead of hundreds.
# -----------------------------------------------------------------------
FROM nginx:1.27-alpine

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
