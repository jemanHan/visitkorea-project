import bcrypt from 'bcrypt';
import { prisma } from '@db/client';
import { sign } from '../auth/jwt.js';
export async function authRoutes(fastify) {
    fastify.post('/v1/auth/signup', async (request, reply) => {
        try {
            const { email, password, displayName } = request.body;
            // Validation
            if (!email || !password) {
                return reply.code(400).send({ error: 'Email and password are required' });
            }
            if (password.length < 6) {
                return reply.code(400).send({ error: 'Password must be at least 6 characters' });
            }
            // Check if user already exists
            const existingUser = await prisma.user.findUnique({
                where: { email }
            });
            if (existingUser) {
                return reply.code(409).send({ error: 'User already exists' });
            }
            // Hash password
            const passwordHash = await bcrypt.hash(password, 10);
            // Create user
            const user = await prisma.user.create({
                data: {
                    email,
                    passwordHash,
                    displayName: displayName || email.split('@')[0]
                }
            });
            // Generate JWT
            const token = sign({
                userId: user.id,
                email: user.email,
                displayName: user.displayName || undefined
            });
            return reply.send({
                token,
                user: {
                    id: user.id,
                    email: user.email,
                    displayName: user.displayName
                }
            });
        }
        catch (error) {
            console.error('Signup error:', error);
            return reply.code(500).send({ error: 'Internal server error' });
        }
    });
    fastify.post('/v1/auth/login', async (request, reply) => {
        try {
            const { email, password } = request.body;
            // Validation
            if (!email || !password) {
                return reply.code(400).send({ error: 'Email and password are required' });
            }
            // Find user
            const user = await prisma.user.findUnique({
                where: { email }
            });
            if (!user) {
                return reply.code(401).send({ error: 'Invalid credentials' });
            }
            // Verify password
            const isValidPassword = await bcrypt.compare(password, user.passwordHash);
            if (!isValidPassword) {
                return reply.code(401).send({ error: 'Invalid credentials' });
            }
            // Generate JWT
            const token = sign({
                userId: user.id,
                email: user.email,
                displayName: user.displayName || undefined
            });
            return reply.send({
                token,
                user: {
                    id: user.id,
                    email: user.email,
                    displayName: user.displayName
                }
            });
        }
        catch (error) {
            console.error('Login error:', error);
            return reply.code(500).send({ error: 'Internal server error' });
        }
    });
}
