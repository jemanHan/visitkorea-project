import jwt from 'jsonwebtoken';
const JWT_SECRET = process.env.JWT_SECRET || 'change-me';
export function sign(payload, expires = '7d') {
    return jwt.sign(payload, JWT_SECRET, { expiresIn: expires });
}
export function verify(token) {
    try {
        return jwt.verify(token, JWT_SECRET);
    }
    catch (error) {
        return null;
    }
}
export async function authHook(request, reply) {
    const authHeader = request.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        request.user = null;
        return;
    }
    const token = authHeader.substring(7);
    const payload = verify(token);
    if (payload) {
        request.user = payload;
    }
    else {
        request.user = null;
    }
}
