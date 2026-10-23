import { glob } from 'astro/loaders';
import { defineCollection, z } from 'astro:content';

// Blog posts are written in the app repo (locapp-23, docs/marketing/blog/posts/)
// and copied here by ./sync-blog.sh. Never edit src/content/blog/ by hand:
// edit the post in locapp-23 and re-sync. Fields match the post format in
// docs/marketing/blog/README.md there.
const blog = defineCollection({
  // One folder per post: <slug>/index.md with its images beside it. The folder
  // name is the URL: /blog/<slug>/.
  loader: glob({
    pattern: '*/index.md',
    base: './src/content/blog',
    generateId: ({ entry }) => entry.replace(/\/index\.md$/, ''),
  }),
  schema: ({ image }) =>
    z.object({
      title: z.string(),
      description: z.string(),
      pubDate: z.coerce.date(),
      updatedDate: z.coerce.date().optional(),
      // Every post has a photo (owner, 2026-10-23); the build fails if it is missing.
      cover: image(),
      coverAlt: z.string().min(1),
      tags: z.array(z.string()).default([]),
      draft: z.boolean().default(false),
    }),
});

export const collections = { blog };
