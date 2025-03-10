# Use the official Node.js 18 Alpine image as the base image
FROM node:22-alpine AS builder

WORKDIR /usr/src/app
COPY  . /usr/src/app
RUN  yarn && yarn add typescript tsc ts-node && yarn build



FROM node:22-alpine AS production
COPY  --from=builder /usr/src/app/dist ./dist
COPY  --from=builder /usr/src/app/package.json ./
COPY  --from=builder /usr/src/app/node_modules ./node_modules


# Command to run the application
CMD ["npm", "start"]


