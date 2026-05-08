---
name: query-patterns
description: Implement TanStack Query (React Query) patterns for data fetching, caching, mutations, and optimistic updates. Use when setting up API integration or data fetching strategies.
allowed-tools: Read, Write, Grep
---

You are a TanStack Query (React Query) patterns expert. You help implement efficient, scalable data fetching patterns with proper TypeScript types and caching strategies.

## React Query Pattern Implementations

### 1. Organized Query Structure

Separate concerns: API calls, query keys, and query hooks.

```typescript
// services/api/users.ts - API Layer
import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add auth token interceptor
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const usersApi = {
  getAll: async (params?: GetUsersParams) => {
    const { data } = await api.get<User[]>('/users', { params });
    return data;
  },

  getById: async (id: string) => {
    const { data } = await api.get<User>(`/users/${id}`);
    return data;
  },

  create: async (user: CreateUserInput) => {
    const { data } = await api.post<User>('/users', user);
    return data;
  },

  update: async (id: string, updates: Partial<User>) => {
    const { data} = await api.patch<User>(`/users/${id}`, updates);
    return data;
  },

  delete: async (id: string) => {
    await api.delete(`/users/${id}`);
  },
};

// services/queries/queryKeys.ts - Query Key Factory
export const userKeys = {
  all: ['users'] as const,
  lists: () => [...userKeys.all, 'list'] as const,
  list: (params?: GetUsersParams) => [...userKeys.lists(), params] as const,
  details: () => [...userKeys.all, 'detail'] as const,
  detail: (id: string) => [...userKeys.details(), id] as const,
};

// services/queries/useUsers.ts - Query Hooks
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { usersApi } from '../api/users';
import { userKeys } from './queryKeys';

export function useUsers(params?: GetUsersParams) {
  return useQuery({
    queryKey: userKeys.list(params),
    queryFn: () => usersApi.getAll(params),
    staleTime: 5 * 60 * 1000, // Fresh for 5 minutes
  });
}

export function useUser(id: string) {
  return useQuery({
    queryKey: userKeys.detail(id),
    queryFn: () => usersApi.getById(id),
    enabled: !!id,
  });
}

export function useCreateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: usersApi.create,
    onSuccess: (newUser) => {
      // Invalidate and refetch
      queryClient.invalidateQueries({ queryKey: userKeys.lists() });

      // Or optimistically add to cache
      queryClient.setQueryData<User[]>(
        userKeys.list(),
        (old) => old ? [...old, newUser] : [newUser]
      );
    },
  });
}

export function useUpdateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, updates }: { id: string; updates: Partial<User> }) =>
      usersApi.update(id, updates),

    // Optimistic update
    onMutate: async ({ id, updates }) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries({ queryKey: userKeys.detail(id) });

      // Snapshot previous value
      const previousUser = queryClient.getQueryData<User>(userKeys.detail(id));

      // Optimistically update
      queryClient.setQueryData<User>(userKeys.detail(id), (old) => {
        if (!old) return old;
        return { ...old, ...updates };
      });

      return { previousUser };
    },

    // Rollback on error
    onError: (err, { id }, context) => {
      if (context?.previousUser) {
        queryClient.setQueryData(userKeys.detail(id), context.previousUser);
      }
    },

    // Refetch after mutation
    onSettled: (data, error, { id }) => {
      queryClient.invalidateQueries({ queryKey: userKeys.detail(id) });
      queryClient.invalidateQueries({ queryKey: userKeys.lists() });
    },
  });
}

export function useDeleteUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: usersApi.delete,
    onSuccess: (_, deletedId) => {
      // Remove from cache
      queryClient.removeQueries({ queryKey: userKeys.detail(deletedId) });

      // Update lists
      queryClient.setQueriesData<User[]>(
        { queryKey: userKeys.lists() },
        (old) => old?.filter((user) => user.id !== deletedId)
      );
    },
  });
}
```

### 2. Infinite Query Pattern (Pagination)

```typescript
// services/queries/useInfiniteUsers.ts
import { useInfiniteQuery } from '@tanstack/react-query';

interface PageResponse<T> {
  data: T[];
  nextCursor?: string;
  hasMore: boolean;
}

export function useInfiniteUsers(params?: GetUsersParams) {
  return useInfiniteQuery({
    queryKey: userKeys.list(params),
    queryFn: ({ pageParam }) =>
      usersApi.getAll({ ...params, cursor: pageParam }),
    getNextPageParam: (lastPage: PageResponse<User>) => {
      return lastPage.hasMore ? lastPage.nextCursor : undefined;
    },
    initialPageParam: undefined,
  });
}

// Component usage
function UserList() {
  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isLoading,
    error,
  } = useInfiniteUsers();

  const users = data?.pages.flatMap((page) => page.data) ?? [];

  const observerTarget = useRef<HTMLDivElement>(null);

  // Infinite scroll
  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && hasNextPage && !isFetchingNextPage) {
          fetchNextPage();
        }
      },
      { threshold: 1.0 }
    );

    if (observerTarget.current) {
      observer.observe(observerTarget.current);
    }

    return () => observer.disconnect();
  }, [fetchNextPage, hasNextPage, isFetchingNextPage]);

  if (isLoading) return <LoadingSpinner />;
  if (error) return <ErrorMessage error={error} />;

  return (
    <div>
      {users.map((user) => (
        <UserCard key={user.id} user={user} />
      ))}
      <div ref={observerTarget} />
      {isFetchingNextPage && <LoadingSpinner />}
    </div>
  );
}
```

### 3. Dependent Queries

```typescript
// Query that depends on another query
function UserPosts({ userId }: { userId: string }) {
  // First query
  const {
    data: user,
    isLoading: userLoading,
    error: userError,
  } = useUser(userId);

  // Second query depends on first
  const {
    data: posts,
    isLoading: postsLoading,
  } = useQuery({
    queryKey: ['posts', user?.id],
    queryFn: () => postsApi.getByUserId(user!.id),
    enabled: !!user, // Only run when user is loaded
  });

  if (userLoading) return <div>Loading user...</div>;
  if (userError) return <div>Error loading user</div>;
  if (!user) return <div>User not found</div>;
  if (postsLoading) return <div>Loading posts...</div>;

  return (
    <div>
      <h2>{user.name}'s Posts</h2>
      {posts?.map((post) => <PostCard key={post.id} post={post} />)}
    </div>
  );
}
```

### 4. Prefetching Pattern

```typescript
// Prefetch on hover
function UserListItem({ user }: { user: User }) {
  const queryClient = useQueryClient();

  const prefetchUser = () => {
    queryClient.prefetchQuery({
      queryKey: userKeys.detail(user.id),
      queryFn: () => usersApi.getById(user.id),
      staleTime: 60 * 1000, // Fresh for 1 minute
    });
  };

  return (
    <Link
      to={`/users/${user.id}`}
      onMouseEnter={prefetchUser}
      onFocus={prefetchUser}
    >
      {user.name}
    </Link>
  );
}

// Prefetch next page
function PaginatedList({ page }: { page: number }) {
  const queryClient = useQueryClient();
  const { data } = useUsers({ page });

  useEffect(() => {
    // Prefetch next page
    if (data?.hasMore) {
      queryClient.prefetchQuery({
        queryKey: userKeys.list({ page: page + 1 }),
        queryFn: () => usersApi.getAll({ page: page + 1 }),
      });
    }
  }, [page, data, queryClient]);

  return <div>{/* Render users */}</div>;
}
```

### 5. Optimistic Updates with Rollback

```typescript
// Like/Unlike with optimistic UI
export function useToggleLike(postId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (liked: boolean) => postsApi.toggleLike(postId, liked),

    onMutate: async (liked) => {
      // Cancel ongoing queries
      await queryClient.cancelQueries({ queryKey: postKeys.detail(postId) });

      // Snapshot
      const previousPost = queryClient.getQueryData<Post>(
        postKeys.detail(postId)
      );

      // Optimistic update
      queryClient.setQueryData<Post>(postKeys.detail(postId), (old) => {
        if (!old) return old;
        return {
          ...old,
          liked,
          likeCount: old.likeCount + (liked ? 1 : -1),
        };
      });

      return { previousPost };
    },

    onError: (err, variables, context) => {
      // Rollback
      if (context?.previousPost) {
        queryClient.setQueryData(
          postKeys.detail(postId),
          context.previousPost
        );
      }
      toast.error('Failed to update like');
    },

    onSettled: () => {
      // Refetch
      queryClient.invalidateQueries({ queryKey: postKeys.detail(postId) });
    },
  });
}
```

### 6. Parallel Queries

```typescript
// Run multiple queries in parallel
function Dashboard() {
  const userQuery = useUser('current');
  const postsQuery = usePosts({ userId: 'current' });
  const notificationsQuery = useNotifications();

  // Check all loading states
  if (userQuery.isLoading || postsQuery.isLoading || notificationsQuery.isLoading) {
    return <LoadingSpinner />;
  }

  // Check for errors
  const error = userQuery.error || postsQuery.error || notificationsQuery.error;
  if (error) {
    return <ErrorMessage error={error} />;
  }

  return (
    <div>
      <UserProfile user={userQuery.data} />
      <PostList posts={postsQuery.data} />
      <NotificationList notifications={notificationsQuery.data} />
    </div>
  );
}

// Or use useQueries for dynamic parallel queries
function MultiUserView({ userIds }: { userIds: string[] }) {
  const userQueries = useQueries({
    queries: userIds.map((id) => ({
      queryKey: userKeys.detail(id),
      queryFn: () => usersApi.getById(id),
    })),
  });

  const isLoading = userQueries.some((q) => q.isLoading);
  const users = userQueries.map((q) => q.data).filter(Boolean);

  if (isLoading) return <div>Loading...</div>;

  return (
    <div>
      {users.map((user) => (
        <UserCard key={user.id} user={user} />
      ))}
    </div>
  );
}
```

### 7. Mutation with Multiple Cache Updates

```typescript
// Update multiple cache locations
export function useUpdateProfile() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (updates: Partial<User>) =>
      usersApi.update('current', updates),

    onSuccess: (updatedUser) => {
      // Update current user query
      queryClient.setQueryData(userKeys.detail('current'), updatedUser);

      // Update any user lists that might contain this user
      queryClient.setQueriesData<User[]>(
        { queryKey: userKeys.lists() },
        (old) => {
          if (!old) return old;
          return old.map((user) =>
            user.id === updatedUser.id ? updatedUser : user
          );
        }
      );

      // Update any posts by this user to reflect name change
      queryClient.setQueriesData<Post[]>(
        { queryKey: ['posts'] },
        (old) => {
          if (!old) return old;
          return old.map((post) =>
            post.authorId === updatedUser.id
              ? { ...post, authorName: updatedUser.name }
              : post
          );
        }
      );
    },
  });
}
```

## Best Practices

1. **Query Keys**:
   - Use factory pattern for consistency
   - Include all variables affecting the query
   - Hierarchical structure for easy invalidation

2. **Caching Strategy**:
   - Set appropriate `staleTime` (how long data is fresh)
   - Set appropriate `gcTime` (how long unused data is cached)
   - Use prefetching for better UX

3. **Error Handling**:
   - Always handle errors in UI
   - Use error boundaries for critical failures
   - Configure retry logic appropriately

4. **Performance**:
   - Use `enabled` option to prevent unnecessary requests
   - Leverage `select` to transform data
   - Implement optimistic updates for better UX

5. **Type Safety**:
   - Define proper TypeScript interfaces
   - Type query responses
   - Type mutation variables

## Common Patterns Summary

| Pattern | Use Case |
|---------|----------|
| Basic Query | Fetching data |
| Mutation | Creating/updating/deleting data |
| Infinite Query | Pagination/infinite scroll |
| Dependent Queries | Data that depends on other data |
| Prefetching | Improve perceived performance |
| Optimistic Updates | Instant UI feedback |
| Parallel Queries | Fetch multiple resources simultaneously |

This skill helps you implement efficient, scalable data fetching patterns with TanStack Query.
