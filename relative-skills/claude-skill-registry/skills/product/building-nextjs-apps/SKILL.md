---
name: building-nextjs-apps
description: Specialized skill for building Next.js 15 App Router applications with React Server Components, Server Actions, and production-ready patterns. Use when implementing Next.js features, components, or application structure.
---

# Building Next.js Apps

You are an expert in building production-ready Next.js 15 applications using the App Router with opinionated best practices.

## Enforced Patterns

### App Router Only
- NEVER use Pages Router
- Use App Router features: layouts, loading, error, not-found
- Leverage nested layouts for shared UI
- Use route groups for organization (no URL impact)

### Server Components First
Default to Server Components. Only use Client Components when you need:
- Interactivity (event handlers: onClick, onChange, etc.)
- Browser-only APIs (localStorage, window, document)
- React hooks (useState, useEffect, useReducer, etc.)
- Third-party libraries that require client-side rendering

### Data Fetching

**Server Components** (Preferred):
```typescript
// app/posts/page.tsx
import { getPosts } from '@/lib/data';

export default async function PostsPage() {
  const posts = await getPosts(); // Direct async call

  return (
    <div>
      {posts.map(post => (
        <article key={post.id}>
          <h2>{post.title}</h2>
          <p>{post.content}</p>
        </article>
      ))}
    </div>
  );
}
```

**Client Components** (When needed):
```typescript
// components/posts-list.tsx
'use client';

import { useEffect, useState } from 'react';

export function PostsList() {
  const [posts, setPosts] = useState([]);

  useEffect(() => {
    fetch('/api/posts')
      .then(res => res.json())
      .then(setPosts);
  }, []);

  return <div>{/* render posts */}</div>;
}
```

### Mutations with Server Actions

**Form Actions** (Preferred):
```typescript
// app/actions.ts
'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { z } from 'zod';

const CreatePostSchema = z.object({
  title: z.string().min(1, 'Title required'),
  content: z.string().min(1, 'Content required'),
});

export async function createPost(formData: FormData) {
  const validated = CreatePostSchema.parse({
    title: formData.get('title'),
    content: formData.get('content'),
  });

  // Write to database
  const postId = await db.createPost(validated);

  revalidatePath('/posts');
  redirect(`/posts/${postId}`);
}
```

```typescript
// app/posts/new/page.tsx
import { createPost } from '@/app/actions';

export default function NewPostPage() {
  return (
    <form action={createPost}>
      <input name="title" required />
      <textarea name="content" required />
      <button type="submit">Create Post</button>
    </form>
  );
}
```

**Programmatic Actions**:
```typescript
// components/delete-button.tsx
'use client';

import { deletePost } from '@/app/actions';

export function DeleteButton({ postId }: { postId: string }) {
  return (
    <button onClick={() => deletePost(postId)}>
      Delete
    </button>
  );
}
```

### Route Handlers

Use for external API integrations, webhooks, or when Server Actions don't fit:

```typescript
// app/api/webhook/route.ts
import { NextResponse } from 'next/server';
import { headers } from 'next/headers';

export async function POST(request: Request) {
  const headersList = headers();
  const signature = headersList.get('x-webhook-signature');

  // Verify signature
  if (!verifySignature(signature)) {
    return NextResponse.json({ error: 'Invalid signature' }, { status: 401 });
  }

  const body = await request.json();

  // Process webhook
  await processWebhook(body);

  return NextResponse.json({ success: true });
}
```

### File Structure

```
app/
├── (auth)/                     # Route group (no /auth in URL)
│   ├── login/
│   │   └── page.tsx
│   ├── register/
│   │   └── page.tsx
│   └── layout.tsx              # Shared auth layout
├── (dashboard)/                # Another route group
│   ├── posts/
│   │   ├── [id]/
│   │   │   ├── page.tsx        # /posts/[id]
│   │   │   └── edit/
│   │   │       └── page.tsx    # /posts/[id]/edit
│   │   ├── new/
│   │   │   └── page.tsx        # /posts/new
│   │   ├── page.tsx            # /posts
│   │   ├── loading.tsx         # Loading UI
│   │   └── error.tsx           # Error boundary
│   ├── settings/
│   │   └── page.tsx
│   └── layout.tsx              # Dashboard layout with nav
├── api/
│   ├── webhook/
│   │   └── route.ts
│   └── health/
│       └── route.ts
├── actions.ts                  # Server Actions
├── layout.tsx                  # Root layout
├── page.tsx                    # Home page
├── loading.tsx                 # Global loading
├── error.tsx                   # Global error
├── not-found.tsx               # 404 page
└── global.css                  # Tailwind imports

components/
├── ui/                         # Reusable UI components
│   ├── button.tsx
│   ├── card.tsx
│   └── input.tsx
└── features/                   # Feature-specific components
    ├── post-card.tsx
    └── post-form.tsx

lib/
├── db/                         # Database access
│   ├── dynamodb.ts
│   └── queries.ts
├── auth/                       # Auth utilities
│   └── config.ts
└── utils.ts                    # Shared utilities
```

### Layouts

**Root Layout** (Required):
```typescript
// app/layout.tsx
import './global.css';
import { Inter } from 'next/font/google';

const inter = Inter({ subsets: ['latin'] });

export const metadata = {
  title: 'My App',
  description: 'App description',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        {children}
      </body>
    </html>
  );
}
```

**Nested Layouts**:
```typescript
// app/(dashboard)/layout.tsx
import { Navigation } from '@/components/navigation';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex h-screen">
      <Navigation />
      <main className="flex-1 overflow-y-auto p-8">
        {children}
      </main>
    </div>
  );
}
```

### Loading States

**Streaming with Suspense**:
```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react';
import { PostsList } from '@/components/posts-list';
import { StatsSkeleton } from '@/components/skeletons';

export default function DashboardPage() {
  return (
    <div>
      <h1>Dashboard</h1>
      <Suspense fallback={<StatsSkeleton />}>
        <PostsList />
      </Suspense>
    </div>
  );
}
```

**Loading.tsx**:
```typescript
// app/dashboard/loading.tsx
export default function Loading() {
  return (
    <div className="flex items-center justify-center h-full">
      <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-gray-900" />
    </div>
  );
}
```

### Error Handling

**Error Boundaries**:
```typescript
// app/dashboard/error.tsx
'use client';

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div className="flex flex-col items-center justify-center h-full">
      <h2 className="text-2xl font-bold mb-4">Something went wrong!</h2>
      <p className="text-gray-600 mb-4">{error.message}</p>
      <button
        onClick={reset}
        className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
      >
        Try again
      </button>
    </div>
  );
}
```

**Not Found**:
```typescript
// app/posts/[id]/not-found.tsx
import Link from 'next/link';

export default function NotFound() {
  return (
    <div>
      <h2>Post Not Found</h2>
      <p>Could not find the requested post.</p>
      <Link href="/posts">View all posts</Link>
    </div>
  );
}
```

### Metadata

**Static Metadata**:
```typescript
// app/posts/page.tsx
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Posts',
  description: 'Browse all posts',
};

export default function PostsPage() {
  // ...
}
```

**Dynamic Metadata**:
```typescript
// app/posts/[id]/page.tsx
import type { Metadata } from 'next';
import { notFound } from 'next/navigation';

export async function generateMetadata({
  params,
}: {
  params: { id: string };
}): Promise<Metadata> {
  const post = await getPost(params.id);

  if (!post) {
    return {
      title: 'Post Not Found',
    };
  }

  return {
    title: post.title,
    description: post.excerpt,
    openGraph: {
      title: post.title,
      description: post.excerpt,
      images: [post.coverImage],
    },
  };
}

export default async function PostPage({
  params,
}: {
  params: { id: string };
}) {
  const post = await getPost(params.id);

  if (!post) {
    notFound();
  }

  return <article>{/* render post */}</article>;
}
```

### Caching and Revalidation

**Revalidate Paths**:
```typescript
// app/actions.ts
'use server';

import { revalidatePath } from 'next/cache';

export async function createPost(data: FormData) {
  await db.createPost(/* ... */);

  revalidatePath('/posts');           // Revalidate specific path
  revalidatePath('/posts/[id]', 'page'); // Revalidate dynamic route
  revalidatePath('/', 'layout');      // Revalidate layout (all nested pages)
}
```

**Revalidate Tags**:
```typescript
// Fetch with tag
export async function getPosts() {
  const res = await fetch('https://api.example.com/posts', {
    next: { tags: ['posts'] },
  });
  return res.json();
}

// Revalidate by tag
import { revalidateTag } from 'next/cache';

export async function createPost(data: FormData) {
  await db.createPost(/* ... */);

  revalidateTag('posts'); // Revalidates all fetches with 'posts' tag
}
```

**Time-based Revalidation**:
```typescript
// Revalidate every hour
export async function getPosts() {
  const res = await fetch('https://api.example.com/posts', {
    next: { revalidate: 3600 },
  });
  return res.json();
}
```

### Authentication with NextAuth.js

**Configuration**:
```typescript
// lib/auth/config.ts
import NextAuth from 'next-auth';
import Google from 'next-auth/providers/google';
import { DynamoDBAdapter } from '@auth/dynamodb-adapter';
import { DynamoDB } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocument } from '@aws-sdk/lib-dynamodb';

const client = DynamoDBDocument.from(new DynamoDB({}), {
  marshallOptions: {
    convertEmptyValues: true,
    removeUndefinedValues: true,
    convertClassInstanceToMap: true,
  },
});

export const { handlers, auth, signIn, signOut } = NextAuth({
  adapter: DynamoDBAdapter(client),
  providers: [
    Google({
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    }),
  ],
  session: {
    strategy: 'jwt',
  },
});
```

**API Route**:
```typescript
// app/api/auth/[...nextauth]/route.ts
import { handlers } from '@/lib/auth/config';

export const { GET, POST } = handlers;
```

**Middleware** (Protect routes):
```typescript
// middleware.ts
import { auth } from '@/lib/auth/config';

export default auth((req) => {
  if (!req.auth && req.nextUrl.pathname.startsWith('/dashboard')) {
    return Response.redirect(new URL('/login', req.url));
  }
});

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
};
```

**Get Session** (Server Component):
```typescript
import { auth } from '@/lib/auth/config';

export default async function DashboardPage() {
  const session = await auth();

  if (!session?.user) {
    redirect('/login');
  }

  return <div>Welcome, {session.user.name}</div>;
}
```

**Get Session** (Client Component):
```typescript
'use client';

import { useSession } from 'next-auth/react';

export function UserProfile() {
  const { data: session, status } = useSession();

  if (status === 'loading') {
    return <div>Loading...</div>;
  }

  if (status === 'unauthenticated') {
    return <div>Not signed in</div>;
  }

  return <div>Signed in as {session?.user?.name}</div>;
}
```

### Environment Variables

**Validation**:
```typescript
// lib/env.ts
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']),
  DYNAMODB_TABLE_NAME: z.string().min(1),
  AWS_REGION: z.string().min(1),
  GOOGLE_CLIENT_ID: z.string().min(1),
  GOOGLE_CLIENT_SECRET: z.string().min(1),
  NEXTAUTH_URL: z.string().url(),
  NEXTAUTH_SECRET: z.string().min(32),
});

export const env = envSchema.parse(process.env);
```

**.env.example**:
```bash
# Database
DYNAMODB_TABLE_NAME=my-app-table
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key

# Auth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-nextauth-secret-min-32-chars
```

### Testing

**Unit Tests** (Vitest):
```typescript
// lib/utils.test.ts
import { describe, it, expect } from 'vitest';
import { formatDate } from './utils';

describe('formatDate', () => {
  it('formats date correctly', () => {
    const date = new Date('2024-01-01');
    expect(formatDate(date)).toBe('January 1, 2024');
  });
});
```

**E2E Tests** (Playwright):
```typescript
// tests/e2e/posts.spec.ts
import { test, expect } from '@playwright/test';

test('create new post', async ({ page }) => {
  await page.goto('/posts/new');

  await page.fill('input[name="title"]', 'Test Post');
  await page.fill('textarea[name="content"]', 'Test content');
  await page.click('button[type="submit"]');

  await expect(page).toHaveURL(/\/posts\/\w+/);
  await expect(page.locator('h1')).toContainText('Test Post');
});
```

## Best Practices Summary

1. **Server Components by default** - Use 'use client' sparingly
2. **Server Actions for mutations** - Forms and programmatic actions
3. **Async Server Components** - Fetch data directly in components
4. **Nested layouts** - Share UI across routes
5. **Loading and error states** - Use loading.tsx, error.tsx, Suspense
6. **Metadata API** - Static and dynamic SEO
7. **Route groups** - Organize without affecting URLs
8. **Streaming** - Progressive rendering with Suspense
9. **Revalidation** - Keep data fresh with revalidatePath/revalidateTag
10. **Type-safe environment variables** - Validate with Zod

You build with these patterns every time. No exceptions.
