---
name: filament-testing
description: Generate Pest tests for FilamentPHP v4 resources, forms, tables, and authorization
---

# FilamentPHP Testing Skill

## Overview

This skill generates comprehensive Pest tests for FilamentPHP v4 components following official testing documentation patterns.

## Documentation Reference

**CRITICAL:** Before generating tests, read:
- `/home/mwguerra/projects/mwguerra/claude-code-plugins/filament-specialist/skills/filament-docs/references/general/10-testing/`

## Test Setup

### Base Test Configuration

```php
<?php

declare(strict_types=1);

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    use CreatesApplication;

    protected function setUp(): void
    {
        parent::setUp();

        // Login as admin for Filament tests
        $this->actingAs(\App\Models\User::factory()->create([
            'is_admin' => true,
        ]));
    }
}
```

### Pest Configuration

```php
// tests/Pest.php
uses(Tests\TestCase::class)
    ->in('Feature');

uses(Illuminate\Foundation\Testing\RefreshDatabase::class)
    ->in('Feature');
```

## Resource Tests

### List Page Tests

```php
<?php

declare(strict_types=1);

use App\Filament\Resources\PostResource;
use App\Filament\Resources\PostResource\Pages\ListPosts;
use App\Models\Post;
use App\Models\User;
use Filament\Actions\DeleteAction;
use Filament\Tables\Actions\DeleteBulkAction;

use function Pest\Livewire\livewire;

beforeEach(function () {
    $this->user = User::factory()->create(['is_admin' => true]);
    $this->actingAs($this->user);
});

it('can render the list page', function () {
    livewire(ListPosts::class)
        ->assertSuccessful();
});

it('can list posts', function () {
    $posts = Post::factory()->count(10)->create();

    livewire(ListPosts::class)
        ->assertCanSeeTableRecords($posts);
});

it('can render post title column', function () {
    Post::factory()->create(['title' => 'Test Post Title']);

    livewire(ListPosts::class)
        ->assertCanRenderTableColumn('title');
});

it('can search posts by title', function () {
    $post = Post::factory()->create(['title' => 'Unique Search Term']);
    $otherPost = Post::factory()->create(['title' => 'Other Post']);

    livewire(ListPosts::class)
        ->searchTable('Unique Search Term')
        ->assertCanSeeTableRecords([$post])
        ->assertCanNotSeeTableRecords([$otherPost]);
});

it('can sort posts by title', function () {
    $posts = Post::factory()->count(3)->create();

    livewire(ListPosts::class)
        ->sortTable('title')
        ->assertCanSeeTableRecords($posts->sortBy('title'), inOrder: true)
        ->sortTable('title', 'desc')
        ->assertCanSeeTableRecords($posts->sortByDesc('title'), inOrder: true);
});

it('can filter posts by status', function () {
    $publishedPost = Post::factory()->create(['status' => 'published']);
    $draftPost = Post::factory()->create(['status' => 'draft']);

    livewire(ListPosts::class)
        ->filterTable('status', 'published')
        ->assertCanSeeTableRecords([$publishedPost])
        ->assertCanNotSeeTableRecords([$draftPost]);
});

it('can bulk delete posts', function () {
    $posts = Post::factory()->count(3)->create();

    livewire(ListPosts::class)
        ->callTableBulkAction(DeleteBulkAction::class, $posts);

    foreach ($posts as $post) {
        $this->assertModelMissing($post);
    }
});
```

### Create Page Tests

```php
<?php

declare(strict_types=1);

use App\Filament\Resources\PostResource;
use App\Filament\Resources\PostResource\Pages\CreatePost;
use App\Models\Category;
use App\Models\Post;
use App\Models\User;

use function Pest\Livewire\livewire;

beforeEach(function () {
    $this->user = User::factory()->create(['is_admin' => true]);
    $this->actingAs($this->user);
});

it('can render the create page', function () {
    livewire(CreatePost::class)
        ->assertSuccessful();
});

it('can create a post', function () {
    $category = Category::factory()->create();

    $newData = [
        'title' => 'New Post Title',
        'slug' => 'new-post-title',
        'content' => 'This is the post content.',
        'status' => 'draft',
        'category_id' => $category->id,
    ];

    livewire(CreatePost::class)
        ->fillForm($newData)
        ->call('create')
        ->assertHasNoFormErrors();

    $this->assertDatabaseHas(Post::class, [
        'title' => 'New Post Title',
        'slug' => 'new-post-title',
    ]);
});

it('validates required fields', function () {
    livewire(CreatePost::class)
        ->fillForm([
            'title' => '',
            'content' => '',
        ])
        ->call('create')
        ->assertHasFormErrors([
            'title' => 'required',
            'content' => 'required',
        ]);
});

it('validates title max length', function () {
    livewire(CreatePost::class)
        ->fillForm([
            'title' => str_repeat('a', 256),
        ])
        ->call('create')
        ->assertHasFormErrors(['title' => 'max']);
});

it('validates unique slug', function () {
    Post::factory()->create(['slug' => 'existing-slug']);

    livewire(CreatePost::class)
        ->fillForm([
            'title' => 'New Post',
            'slug' => 'existing-slug',
            'content' => 'Content',
        ])
        ->call('create')
        ->assertHasFormErrors(['slug' => 'unique']);
});
```

### Edit Page Tests

```php
<?php

declare(strict_types=1);

use App\Filament\Resources\PostResource;
use App\Filament\Resources\PostResource\Pages\EditPost;
use App\Models\Post;
use App\Models\User;
use Filament\Actions\DeleteAction;

use function Pest\Livewire\livewire;

beforeEach(function () {
    $this->user = User::factory()->create(['is_admin' => true]);
    $this->actingAs($this->user);
});

it('can render the edit page', function () {
    $post = Post::factory()->create();

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->assertSuccessful();
});

it('can retrieve data', function () {
    $post = Post::factory()->create();

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->assertFormSet([
            'title' => $post->title,
            'slug' => $post->slug,
            'content' => $post->content,
            'status' => $post->status,
        ]);
});

it('can update a post', function () {
    $post = Post::factory()->create();

    $newData = [
        'title' => 'Updated Title',
        'slug' => 'updated-title',
        'content' => 'Updated content.',
        'status' => 'published',
    ];

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->fillForm($newData)
        ->call('save')
        ->assertHasNoFormErrors();

    expect($post->refresh())
        ->title->toBe('Updated Title')
        ->slug->toBe('updated-title')
        ->status->toBe('published');
});

it('can delete a post', function () {
    $post = Post::factory()->create();

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->callAction(DeleteAction::class);

    $this->assertModelMissing($post);
});

it('validates unique slug excluding current record', function () {
    $post = Post::factory()->create(['slug' => 'my-slug']);
    $otherPost = Post::factory()->create(['slug' => 'other-slug']);

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->fillForm(['slug' => 'other-slug'])
        ->call('save')
        ->assertHasFormErrors(['slug' => 'unique']);
});
```

### View Page Tests

```php
<?php

declare(strict_types=1);

use App\Filament\Resources\PostResource\Pages\ViewPost;
use App\Models\Post;
use App\Models\User;

use function Pest\Livewire\livewire;

beforeEach(function () {
    $this->user = User::factory()->create(['is_admin' => true]);
    $this->actingAs($this->user);
});

it('can render the view page', function () {
    $post = Post::factory()->create();

    livewire(ViewPost::class, ['record' => $post->getRouteKey()])
        ->assertSuccessful();
});

it('can retrieve post data in infolist', function () {
    $post = Post::factory()->create([
        'title' => 'Test Post',
        'status' => 'published',
    ]);

    livewire(ViewPost::class, ['record' => $post->getRouteKey()])
        ->assertSee('Test Post')
        ->assertSee('published');
});
```

## Form Tests

```php
<?php

declare(strict_types=1);

use App\Filament\Resources\PostResource\Pages\CreatePost;
use App\Models\Category;
use App\Models\Tag;

use function Pest\Livewire\livewire;

it('can fill form fields', function () {
    $category = Category::factory()->create();

    livewire(CreatePost::class)
        ->fillForm([
            'title' => 'Test Title',
            'category_id' => $category->id,
        ])
        ->assertFormSet([
            'title' => 'Test Title',
            'category_id' => $category->id,
        ]);
});

it('has required form fields', function () {
    livewire(CreatePost::class)
        ->assertFormFieldExists('title')
        ->assertFormFieldExists('slug')
        ->assertFormFieldExists('content')
        ->assertFormFieldExists('status')
        ->assertFormFieldExists('category_id');
});

it('renders select options', function () {
    $categories = Category::factory()->count(3)->create();

    livewire(CreatePost::class)
        ->assertFormFieldExists('category_id', function ($field) use ($categories) {
            return $field->getOptions() === $categories->pluck('name', 'id')->toArray();
        });
});

it('can handle repeater fields', function () {
    livewire(CreatePost::class)
        ->fillForm([
            'meta' => [
                ['key' => 'og:title', 'value' => 'Open Graph Title'],
                ['key' => 'og:description', 'value' => 'Open Graph Description'],
            ],
        ])
        ->call('create')
        ->assertHasNoFormErrors();
});
```

## Table Tests

```php
<?php

declare(strict_types=1);

use App\Filament\Resources\PostResource\Pages\ListPosts;
use App\Models\Post;

use function Pest\Livewire\livewire;

it('displays correct columns', function () {
    Post::factory()->create([
        'title' => 'Test Post',
        'status' => 'published',
    ]);

    livewire(ListPosts::class)
        ->assertCanRenderTableColumn('title')
        ->assertCanRenderTableColumn('status')
        ->assertCanRenderTableColumn('author.name')
        ->assertCanRenderTableColumn('created_at');
});

it('can filter by date range', function () {
    $oldPost = Post::factory()->create([
        'created_at' => now()->subMonths(2),
    ]);
    $recentPost = Post::factory()->create([
        'created_at' => now(),
    ]);

    livewire(ListPosts::class)
        ->filterTable('created_at', [
            'created_from' => now()->subWeek()->format('Y-m-d'),
            'created_until' => now()->format('Y-m-d'),
        ])
        ->assertCanSeeTableRecords([$recentPost])
        ->assertCanNotSeeTableRecords([$oldPost]);
});

it('displays table empty state', function () {
    livewire(ListPosts::class)
        ->assertSee('No posts yet');
});
```

## Action Tests

```php
<?php

declare(strict_types=1);

use App\Filament\Resources\PostResource\Pages\EditPost;
use App\Filament\Resources\PostResource\Pages\ListPosts;
use App\Models\Post;
use Filament\Tables\Actions\DeleteAction;

use function Pest\Livewire\livewire;

it('can call publish action', function () {
    $post = Post::factory()->create(['status' => 'draft']);

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->callAction('publish');

    expect($post->refresh()->status)->toBe('published');
});

it('shows publish action only for drafts', function () {
    $draftPost = Post::factory()->create(['status' => 'draft']);
    $publishedPost = Post::factory()->create(['status' => 'published']);

    livewire(EditPost::class, ['record' => $draftPost->getRouteKey()])
        ->assertActionVisible('publish');

    livewire(EditPost::class, ['record' => $publishedPost->getRouteKey()])
        ->assertActionHidden('publish');
});

it('can call table row action', function () {
    $post = Post::factory()->create();

    livewire(ListPosts::class)
        ->callTableAction(DeleteAction::class, $post);

    $this->assertModelMissing($post);
});

it('can call action with form data', function () {
    $post = Post::factory()->create();

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->callAction('send_notification', [
            'subject' => 'Test Subject',
            'message' => 'Test Message',
        ])
        ->assertHasNoActionErrors();
});

it('validates action form', function () {
    $post = Post::factory()->create();

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->callAction('send_notification', [
            'subject' => '',
            'message' => '',
        ])
        ->assertHasActionErrors([
            'subject' => 'required',
            'message' => 'required',
        ]);
});
```

## Authorization Tests

```php
<?php

declare(strict_types=1);

use App\Filament\Resources\PostResource\Pages\CreatePost;
use App\Filament\Resources\PostResource\Pages\EditPost;
use App\Filament\Resources\PostResource\Pages\ListPosts;
use App\Models\Post;
use App\Models\User;

use function Pest\Livewire\livewire;

it('prevents unauthorized users from viewing list', function () {
    $user = User::factory()->create(['is_admin' => false]);
    $this->actingAs($user);

    livewire(ListPosts::class)
        ->assertForbidden();
});

it('prevents unauthorized users from creating posts', function () {
    $user = User::factory()->create(['is_admin' => false]);
    $this->actingAs($user);

    livewire(CreatePost::class)
        ->assertForbidden();
});

it('prevents unauthorized users from editing others posts', function () {
    $author = User::factory()->create();
    $otherUser = User::factory()->create();
    $post = Post::factory()->create(['author_id' => $author->id]);

    $this->actingAs($otherUser);

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->assertForbidden();
});

it('allows authors to edit their own posts', function () {
    $author = User::factory()->create();
    $post = Post::factory()->create(['author_id' => $author->id]);

    $this->actingAs($author);

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->assertSuccessful();
});
```

## Widget Tests

```php
<?php

declare(strict_types=1);

use App\Filament\Widgets\StatsOverview;
use App\Filament\Widgets\LatestPosts;
use App\Models\Post;
use App\Models\User;

use function Pest\Livewire\livewire;

it('can render stats overview widget', function () {
    livewire(StatsOverview::class)
        ->assertSuccessful();
});

it('displays correct stats', function () {
    Post::factory()->count(5)->create(['status' => 'published']);
    Post::factory()->count(3)->create(['status' => 'draft']);

    livewire(StatsOverview::class)
        ->assertSee('8')  // Total posts
        ->assertSee('5'); // Published posts
});

it('can render table widget', function () {
    $posts = Post::factory()->count(5)->create();

    livewire(LatestPosts::class)
        ->assertSuccessful()
        ->assertCanSeeTableRecords($posts);
});
```

## Relation Manager Tests

```php
<?php

declare(strict_types=1);

use App\Filament\Resources\PostResource\RelationManagers\CommentsRelationManager;
use App\Models\Comment;
use App\Models\Post;

use function Pest\Livewire\livewire;

it('can render relation manager', function () {
    $post = Post::factory()->create();

    livewire(CommentsRelationManager::class, [
        'ownerRecord' => $post,
        'pageClass' => \App\Filament\Resources\PostResource\Pages\EditPost::class,
    ])
        ->assertSuccessful();
});

it('can list related comments', function () {
    $post = Post::factory()->create();
    $comments = Comment::factory()->count(3)->create(['post_id' => $post->id]);

    livewire(CommentsRelationManager::class, [
        'ownerRecord' => $post,
        'pageClass' => \App\Filament\Resources\PostResource\Pages\EditPost::class,
    ])
        ->assertCanSeeTableRecords($comments);
});

it('can create related comment', function () {
    $post = Post::factory()->create();

    livewire(CommentsRelationManager::class, [
        'ownerRecord' => $post,
        'pageClass' => \App\Filament\Resources\PostResource\Pages\EditPost::class,
    ])
        ->callTableAction('create', data: [
            'content' => 'New comment content',
        ]);

    expect($post->comments)->toHaveCount(1);
});
```

## Output

Generated tests include:
1. Page rendering tests
2. CRUD operation tests
3. Form validation tests
4. Table feature tests (search, sort, filter)
5. Action tests
6. Authorization tests
7. Widget tests
8. Relation manager tests
