/**
 * ABOUTME: Documentation index page that redirects to the introduction.
 * Provides a redirect from /docs to /docs/getting-started/introduction.
 */

import { redirect } from 'next/navigation';

/**
 * Redirects the /docs root to the introduction page.
 */
export default function DocsIndexPage() {
  redirect('/docs/getting-started/introduction');
}
