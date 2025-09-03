import awsLambdaFastify from '@fastify/aws-lambda';
import { createApp } from './app.js';

const server = createApp();
export const handler = awsLambdaFastify(server);


