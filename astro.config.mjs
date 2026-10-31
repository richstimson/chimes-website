// @ts-check
import sitemap from '@astrojs/sitemap';
import tailwindcss from '@tailwindcss/vite';
import { defineConfig } from 'astro/config';

import cloudflare from '@astrojs/cloudflare'
// https://astro.build/config
export default defineConfig({
  // Used for canonical URLs, the sitemap and the blog's RSS feed.
  site: 'https://chimesapp.com',
  output: "static",
  // /homepage/ is the draft of a new home page; keep it out of the sitemap.
  integrations: [sitemap({ filter: (page) => !page.endsWith('/homepage/') })],
  vite: {
    plugins: [tailwindcss()]
  }
});
