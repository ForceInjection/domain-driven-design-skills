---
name: testing-deployment-implementation
description: Write unit tests for components and services, implement E2E tests with Cypress, set up test mocks, optimize production builds, configure CI/CD pipelines, and deploy to production platforms.
sasmp_version: "1.3.0"
bonded_agent: 07-testing-deployment
bond_type: PRIMARY_BOND
---

# Testing & Deployment Implementation Skill

## Unit Testing Basics

### TestBed Setup
```typescript
import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';

describe('UserService', () => {
  let service: UserService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [UserService]
    });

    service = TestBed.inject(UserService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpMock.verify();
  });
});
```

### Component Testing
```typescript
describe('UserListComponent', () => {
  let component: UserListComponent;
  let fixture: ComponentFixture<UserListComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [UserListComponent],
      imports: [CommonModule, HttpClientTestingModule],
      providers: [UserService]
    }).compileComponents();

    fixture = TestBed.createComponent(UserListComponent);
    component = fixture.componentInstance;
  });

  it('should display users', () => {
    const mockUsers: User[] = [
      { id: 1, name: 'John' },
      { id: 2, name: 'Jane' }
    ];

    component.users = mockUsers;
    fixture.detectChanges();

    const compiled = fixture.nativeElement as HTMLElement;
    const userElements = compiled.querySelectorAll('.user-item');
    expect(userElements.length).toBe(2);
  });

  it('should call service on init', () => {
    const userService = TestBed.inject(UserService);
    spyOn(userService, 'getUsers').and.returnValue(of([]));

    component.ngOnInit();

    expect(userService.getUsers).toHaveBeenCalled();
  });
});
```

### Testing Async Operations
```typescript
// Using fakeAsync and tick
it('should load users after delay', fakeAsync(() => {
  const userService = TestBed.inject(UserService);
  spyOn(userService, 'getUsers').and.returnValue(
    of([{ id: 1, name: 'John' }]).pipe(delay(1000))
  );

  component.ngOnInit();
  expect(component.users.length).toBe(0);

  tick(1000);
  expect(component.users.length).toBe(1);
}));

// Using waitForAsync
it('should handle async operations', waitForAsync(() => {
  const userService = TestBed.inject(UserService);
  spyOn(userService, 'getUsers').and.returnValue(
    of([{ id: 1, name: 'John' }])
  );

  component.ngOnInit();
  fixture.whenStable().then(() => {
    expect(component.users.length).toBe(1);
  });
}));
```

## Mocking Services

### HTTP Mocking
```typescript
it('should fetch users from API', () => {
  const mockUsers: User[] = [{ id: 1, name: 'John' }];

  service.getUsers().subscribe(users => {
    expect(users.length).toBe(1);
    expect(users[0].name).toBe('John');
  });

  const req = httpMock.expectOne('/api/users');
  expect(req.request.method).toBe('GET');
  req.flush(mockUsers);
});

// POST with error handling
it('should handle errors', () => {
  service.createUser({ name: 'Jane' }).subscribe(
    () => fail('should not succeed'),
    (error) => expect(error.status).toBe(400)
  );

  const req = httpMock.expectOne('/api/users');
  req.flush('Invalid user', { status: 400, statusText: 'Bad Request' });
});
```

### Service Mocking
```typescript
class MockUserService {
  getUsers() {
    return of([
      { id: 1, name: 'John' },
      { id: 2, name: 'Jane' }
    ]);
  }
}

@Component({
  selector: 'app-test',
  template: '<div>{{ (users$ | async)?.length }}</div>'
})
class TestComponent {
  users$ = this.userService.getUsers();
  constructor(private userService: UserService) {}
}

describe('TestComponent with Mock', () => {
  let component: TestComponent;
  let fixture: ComponentFixture<TestComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [TestComponent],
      providers: [
        { provide: UserService, useClass: MockUserService }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(TestComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should render users', () => {
    const div = fixture.nativeElement.querySelector('div');
    expect(div.textContent).toContain('2');
  });
});
```

## E2E Testing with Cypress

### Basic E2E Test
```typescript
describe('User List Page', () => {
  beforeEach(() => {
    cy.visit('/users');
  });

  it('should display user list', () => {
    cy.get('[data-testid="user-item"]')
      .should('have.length', 10);
  });

  it('should filter users by name', () => {
    cy.get('[data-testid="search-input"]')
      .type('John');

    cy.get('[data-testid="user-item"]')
      .should('have.length', 1)
      .should('contain', 'John');
  });

  it('should navigate to user detail', () => {
    cy.get('[data-testid="user-item"]').first().click();
    cy.location('pathname').should('include', '/users/');
    cy.get('[data-testid="user-detail"]').should('be.visible');
  });
});
```

### Page Object Model
```typescript
// user.po.ts
export class UserPage {
  navigateTo(path: string = '/users') {
    cy.visit(path);
    return this;
  }

  getUsers() {
    return cy.get('[data-testid="user-item"]');
  }

  getUserByName(name: string) {
    return cy.get('[data-testid="user-item"]').contains(name);
  }

  clickUser(index: number) {
    this.getUsers().eq(index).click();
    return this;
  }

  searchUser(query: string) {
    cy.get('[data-testid="search-input"]').type(query);
    return this;
  }
}

// Test using PO
describe('User Page', () => {
  const page = new UserPage();

  beforeEach(() => {
    page.navigateTo();
  });

  it('should find user by name', () => {
    page.searchUser('John');
    page.getUsers().should('have.length', 1);
  });
});
```

## Build Optimization

### AOT Compilation
```typescript
// angular.json
{
  "projects": {
    "app": {
      "architect": {
        "build": {
          "options": {
            "aot": true,
            "outputHashing": "all",
            "sourceMap": false,
            "optimization": true,
            "buildOptimizer": true,
            "namedChunks": false
          }
        }
      }
    }
  }
}
```

### Bundle Analysis
```bash
# Install webpack-bundle-analyzer
npm install --save-dev webpack-bundle-analyzer

# Run analysis
ng build --stats-json
webpack-bundle-analyzer dist/app/stats.json
```

### Code Splitting
```typescript
// app-routing.module.ts
const routes: Routes = [
  { path: '', component: HomeComponent },
  {
    path: 'admin',
    loadChildren: () =>
      import('./admin/admin.module').then(m => m.AdminModule)
  },
  {
    path: 'users',
    loadChildren: () =>
      import('./users/users.module').then(m => m.UsersModule)
  }
];
```

## Deployment

### Production Build
```bash
# Build for production
ng build --configuration production

# Output directory
dist/app/

# Serve locally
npx http-server dist/app/
```

### Deployment Targets

**Firebase:**
```bash
npm install -g firebase-tools
firebase login
firebase init hosting
firebase deploy
```

**Netlify:**
```bash
npm run build
# Drag and drop dist/ folder to Netlify
# Or use CLI:
npm install -g netlify-cli
netlify deploy --prod --dir=dist/app
```

**GitHub Pages:**
```bash
ng build --output-path docs --base-href /repo-name/
git add docs/
git commit -m "Deploy to GitHub Pages"
git push
# Enable in repository settings
```

**Docker:**
```dockerfile
# Build stage
FROM node:18 as build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Serve stage
FROM nginx:alpine
COPY --from=build /app/dist/app /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## CI/CD Pipelines

### GitHub Actions
```yaml
name: CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Lint
        run: npm run lint

      - name: Build
        run: npm run build

      - name: Test
        run: npm run test -- --watch=false --code-coverage

      - name: E2E Test
        run: npm run e2e

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info

      - name: Deploy
        if: github.ref == 'refs/heads/main'
        run: npm run deploy
```

## Performance Monitoring

### Core Web Vitals
```typescript
// Using web-vitals library
import { getCLS, getFID, getFCP, getLCP, getTTFB } from 'web-vitals';

getCLS(console.log);
getFID(console.log);
getFCP(console.log);
getLCP(console.log);
getTTFB(console.log);
```

### Error Tracking (Sentry)
```typescript
import * as Sentry from "@sentry/angular";

Sentry.init({
  dsn: "https://examplePublicKey@o0.ingest.sentry.io/0",
  integrations: [
    new Sentry.BrowserTracing(),
    new Sentry.Replay(),
  ],
  tracesSampleRate: 1.0,
  replaysSessionSampleRate: 0.1,
  replaysOnErrorSampleRate: 1.0,
});

@NgModule({
  providers: [
    {
      provide: ErrorHandler,
      useValue: Sentry.createErrorHandler(),
    },
  ],
})
export class AppModule {}
```

## Testing Best Practices

1. **Arrange-Act-Assert**: Clear test structure
2. **One Assertion per Test**: Keep tests focused
3. **Test Behavior**: Not implementation details
4. **Use Page Objects**: For E2E tests
5. **Mock External Dependencies**: Services, HTTP
6. **Test Error Cases**: Invalid input, failures
7. **Aim for 80% Coverage**: Don't obsess over 100%

## Coverage Report
```bash
# Generate coverage report
ng test --code-coverage

# View report
open coverage/index.html
```

## Resources

- [Jasmine Documentation](https://jasmine.github.io/)
- [Angular Testing Guide](https://angular.io/guide/testing)
- [Cypress Documentation](https://docs.cypress.io/)
- [Testing Best Practices](https://angular.io/guide/testing-best-practices)
