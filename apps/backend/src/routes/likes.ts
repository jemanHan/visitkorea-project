import { FastifyInstance } from 'fastify';
import { prisma } from '@db/client';
import { normalizeTags } from '../utils/tags.js';

interface LikeBody {
  placeId: string;
  name?: string;
  address?: string;
  rating?: number;
  tags?: string[];
}

export async function likesRoutes(fastify: FastifyInstance) {
  // 좋아요 상태 확인
  fastify.get('/v1/likes/:placeId', async (request, reply) => {
    try {
      const user = (request as any).user;
      
      if (!user) {
        return reply.code(401).send({ error: 'Authentication required' });
      }

      const { placeId } = request.params as { placeId: string };

      if (!placeId) {
        return reply.code(400).send({ error: 'placeId is required' });
      }

      // Check if user has liked this place
      const like = await prisma.userLike.findUnique({
        where: {
          userId_placeId: {
            userId: user.userId,
            placeId
          }
        }
      });

      return reply.send({
        liked: !!like,
        like: like ? {
          id: like.id,
          placeId: like.placeId,
          name: like.name,
          address: like.address,
          rating: like.rating,
          tags: like.tags,
          createdAt: like.createdAt,
          updatedAt: like.updatedAt
        } : null
      });
    } catch (error) {
      console.error('Check like status error:', error);
      return reply.code(500).send({ error: 'Internal server error' });
    }
  });

  // 좋아요 추가/업데이트
  fastify.post('/v1/likes', async (request, reply) => {
    try {
      const user = (request as any).user;
      
      if (!user) {
        return reply.code(401).send({ error: 'Authentication required' });
      }

      const { placeId, name, address, rating, tags = [] } = request.body as LikeBody;

      if (!placeId) {
        return reply.code(400).send({ error: 'placeId is required' });
      }

      // Normalize tags
      const normalizedTags = normalizeTags(tags);

      // Upsert like
      const like = await prisma.userLike.upsert({
        where: {
          userId_placeId: {
            userId: user.userId,
            placeId
          }
        },
        update: {
          name,
          address,
          rating,
          tags: normalizedTags,
          updatedAt: new Date()
        },
        create: {
          userId: user.userId,
          placeId,
          name,
          address,
          rating,
          tags: normalizedTags
        }
      });

      return reply.send({
        success: true,
        like: {
          id: like.id,
          placeId: like.placeId,
          name: like.name,
          address: like.address,
          rating: like.rating,
          tags: like.tags,
          createdAt: like.createdAt,
          updatedAt: like.updatedAt
        }
      });
    } catch (error) {
      console.error('Like error:', error);
      return reply.code(500).send({ error: 'Internal server error' });
    }
  });

  // 좋아요 취소
  fastify.delete('/v1/likes/:placeId', async (request, reply) => {
    try {
      const user = (request as any).user;
      
      if (!user) {
        return reply.code(401).send({ error: 'Authentication required' });
      }

      const { placeId } = request.params as { placeId: string };

      if (!placeId) {
        return reply.code(400).send({ error: 'placeId is required' });
      }

      // Delete like
      await prisma.userLike.delete({
        where: {
          userId_placeId: {
            userId: user.userId,
            placeId
          }
        }
      });

      return reply.send({
        success: true,
        message: 'Like removed successfully'
      });
    } catch (error) {
      console.error('Unlike error:', error);
      return reply.code(500).send({ error: 'Internal server error' });
    }
  });
}


