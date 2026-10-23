import rss from '@astrojs/rss';
import type { APIContext } from 'astro';
import { getPublishedPosts } from '../../lib/blog';

export async function GET(context: APIContext) {
  const posts = await getPublishedPosts();
  return rss({
    title: 'Chimes! blog',
    description: 'News, new features, and stories from the ice cream vans and mobile vendors on Chimes.',
    site: context.site ?? 'https://chimesapp.com',
    items: posts.map((post) => ({
      title: post.data.title,
      description: post.data.description,
      pubDate: post.data.pubDate,
      link: `/blog/${post.id}/`,
      categories: post.data.tags,
    })),
    customData: '<language>en-gb</language>',
  });
}
