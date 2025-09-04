import { FastifyRequest, FastifyReply } from 'fastify';
export interface JWTPayload {
    userId: string;
    email: string;
    displayName?: string;
}
export declare function sign(payload: JWTPayload, expires?: string): string;
export declare function verify(token: string): JWTPayload | null;
export declare function authHook(request: FastifyRequest, reply: FastifyReply): Promise<void>;
//# sourceMappingURL=jwt.d.ts.map