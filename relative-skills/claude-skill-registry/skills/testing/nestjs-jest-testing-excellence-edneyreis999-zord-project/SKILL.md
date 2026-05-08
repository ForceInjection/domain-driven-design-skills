---
name: "NestJS + Jest Testing Excellence"
description: "Aplica padrões de excelência em testes com NestJS e Jest seguindo Clean Architecture, DDD e boas práticas de testabilidade. Use quando criar ou refatorar testes unitários, de integração ou E2E em projetos NestJS."
---

# NestJS + Jest Testing Excellence Skill

## Objetivo

Esta Skill orienta Claude Code a aplicar padrões de excelência em testes para projetos NestJS + Jest, seguindo princípios de Clean Architecture, Domain-Driven Design e testabilidade por design. Baseada em análise técnica de projeto de referência com cobertura obrigatória de 80%.

## Quando usar

Ative esta Skill quando:
- Criar novos testes unitários, de integração ou E2E em NestJS
- Refatorar testes existentes para melhorar qualidade e manutenibilidade
- Implementar padrões de test fixtures e builders
- Configurar ambiente de testes com Jest
- Criar custom matchers específicos do domínio
- Organizar arquitetura testável com separação de camadas
- Implementar repositórios in-memory para testes rápidos
- Definir estratégias de teste por camada (Domain, Application, Infrastructure)

## Entradas esperadas

- `arquivo_ou_modulo`: Código-fonte que precisa de testes ou testes existentes que precisam de melhoria
- `tipo_teste`: Especificar se é unit (.spec.ts), integration (.int-spec.ts) ou e2e (.e2e-spec.ts)
- `camada`: Informar qual camada está sendo testada (domain, application, infrastructure, nest-modules)
- `contexto_projeto`: Estrutura de diretórios e padrões já existentes no projeto (opcional)

## Saídas esperadas

- Código de teste seguindo padrões de excelência
- Implementação de test fixtures e builders quando apropriado
- Configuração de helpers de setup/teardown se necessário
- Explicação da estratégia de teste aplicada
- Recomendações de melhorias adicionais quando aplicável

## Princípios Fundamentais

### 1. Arquitetura Testável por Design

**SEMPRE aplique separação de camadas**:
```
src/
├── core/                          # Domain & Application (Business Logic)
│   ├── [modulo]/
│   │   ├── domain/                # Entidades, Value Objects, Repository Interfaces
│   │   ├── application/           # Use Cases (lógica de aplicação)
│   │   └── infra/                 # Implementações de infraestrutura
│   │       ├── db/sequelize/      # ORM para produção
│   │       └── db/in-memory/      # In-Memory para testes
│   └── shared/
│       ├── domain/                # Building blocks do domínio
│       ├── application/           # Serviços base
│       └── infra/                 # Infraestrutura compartilhada
│
└── nest-modules/                  # Infrastructure Layer (Framework)
    └── [modulo]-module/
        ├── [modulo].controller.ts
        ├── [modulo].providers.ts
        └── __tests__/
```

**Regras de ouro**:
- Domain layer: ZERO imports de `@nestjs/*` ou frameworks
- Defina interfaces de repositório na camada de domínio
- Implemente versões in-memory para testes unitários
- Use injeção de dependências para trocar implementações

### 2. Três Níveis de Teste

**Unit Tests (.spec.ts)**:
- Testam lógica de negócio isolada
- Usam repositórios in-memory
- Execução instantânea (sem I/O)
- Colocação: ao lado do código testado em `__tests__/`

**Integration Tests (.int-spec.ts)**:
- Testam integração com infraestrutura real (banco, ORM)
- Usam banco de dados de teste
- Validam mapeamento ORM e queries
- Colocação: em `infra/db/[orm]/__tests__/`

**E2E Tests (.e2e-spec.ts)**:
- Testam fluxos HTTP completos
- Usam aplicação NestJS inicializada
- Validam autenticação, autorização, contratos de API
- Colocação: diretório `test/` na raiz do projeto

## Padrões Obrigatórios

### Pattern 1: Mock de Validação em Testes de Construção

**Quando usar**: Testes de entidades de domínio

**Aplique sempre**:
```typescript
describe('Entity Without Validator Unit Tests', () => {
  beforeEach(() => {
    Entity.prototype.validate = jest
      .fn()
      .mockImplementation(Entity.prototype.validate);
  });

  test('constructor of entity', () => {
    let entity = new Entity({ name: 'Test' });
    expect(entity.id).toBeInstanceOf(EntityId);
    expect(entity.name).toBe('Test');
    expect(entity.created_at).toBeInstanceOf(Date);
  });
});
```

**Benefícios**:
- Separa testes de construção dos testes de validação
- Evita falhas em cascata quando validação muda
- Execução mais rápida

### Pattern 2: Spy em Métodos do Repositório

**Quando usar**: Testes de use cases

**Aplique sempre**:
```typescript
describe('CreateEntityUseCase Unit Tests', () => {
  let useCase: CreateEntityUseCase;
  let repository: EntityInMemoryRepository;

  beforeEach(() => {
    repository = new EntityInMemoryRepository();
    useCase = new CreateEntityUseCase(repository);
  });

  it('should create an entity', async () => {
    const spyInsert = jest.spyOn(repository, 'insert');

    let output = await useCase.execute({ name: 'test' });

    expect(spyInsert).toHaveBeenCalledTimes(1);
    expect(output).toStrictEqual({
      id: repository.items[0].id.id,
      name: 'test',
      created_at: repository.items[0].created_at,
    });
  });
});
```

**Benefícios**:
- Verifica comportamento interno sem quebrar encapsulamento
- Valida número de chamadas (previne duplicações)
- Permite verificar argumentos passados

### Pattern 3: test.each para Cobertura de Edge Cases

**Quando usar**: Validação de múltiplos cenários

**Aplique sempre**:
```typescript
test.each([
  { input: null, expected: 'default' },
  { input: undefined, expected: 'default' },
  { input: '', expected: 'default' },
  { input: 'valid', expected: 'valid' },
  { input: 0, expected: 'default' },
  { input: -1, expected: 'default' },
  { input: {}, expected: 'default' },
])('input %p should return %p', ({ input, expected }) => {
  expect(processInput(input as any)).toBe(expected);
});
```

**Benefícios**:
- Testa múltiplos casos com código mínimo
- Documentação clara de comportamento esperado
- Fácil adicionar novos casos

### Pattern 4: Fake Builder Pattern

**Quando usar**: Criação de dados de teste para entidades

**Implemente sempre**:
```typescript
export class EntityFakeBuilder<TBuild = any> {
  private _id: PropOrFactory<EntityId> | undefined = undefined;
  private _name: PropOrFactory<string> = (_index) => this.chance.word();
  private _description: PropOrFactory<string | null> = (_index) =>
    this.chance.paragraph();
  private _created_at: PropOrFactory<Date> | undefined = undefined;

  private countObjs: number;

  static anEntity() {
    return new EntityFakeBuilder<Entity>();
  }

  static theEntities(countObjs: number) {
    return new EntityFakeBuilder<Entity[]>(countObjs);
  }

  withName(valueOrFactory: PropOrFactory<string>) {
    this._name = valueOrFactory;
    return this;
  }

  withDescription(valueOrFactory: PropOrFactory<string | null>) {
    this._description = valueOrFactory;
    return this;
  }

  build(): TBuild {
    const entities = new Array(this.countObjs)
      .fill(undefined)
      .map((_, index) => {
        const entity = new Entity({
          id: !this._id ? undefined : this.callFactory(this._id, index),
          name: this.callFactory(this._name, index),
          description: this.callFactory(this._description, index),
          created_at: !this._created_at
            ? undefined
            : this.callFactory(this._created_at, index),
        });
        entity.validate();
        return entity;
      });

    return this.countObjs === 1
      ? (entities[0] as any)
      : (entities as any);
  }

  private callFactory(factoryOrValue: PropOrFactory<any>, index: number) {
    return typeof factoryOrValue === 'function'
      ? factoryOrValue(index)
      : factoryOrValue;
  }
}
```

**Uso**:
```typescript
// Criar uma entidade com valores padrão
const entity = Entity.fake().anEntity().build();

// Criar 16 entidades com nome específico
const entities = Entity.fake()
  .theEntities(16)
  .withName('Test')
  .withDescription(null)
  .build();

// Criar com factory function dinâmica
const entities = Entity.fake()
  .theEntities(16)
  .withName((index) => `Test ${index}`)
  .withCreatedAt((index) => new Date(baseDate.getTime() + index))
  .build();
```

**Benefícios**:
- API fluente e expressiva
- Valores padrão razoáveis (usando Chance.js)
- Suporte para criação em massa
- Suporte para factory functions (valores dinâmicos)

### Pattern 5: Helper setupSequelize para Lifecycle

**Quando usar**: Testes de integração com banco de dados

**Implemente sempre**:
```typescript
// src/core/shared/infra/testing/helpers.ts
export function setupSequelize(options: SequelizeOptions = {}) {
  let _sequelize: Sequelize;

  beforeAll(async () => {
    _sequelize = new Sequelize({
      ...Config.db(),
      ...options,
    });
  });

  beforeEach(async () => await _sequelize.sync({ force: true }));

  afterAll(async () => await _sequelize.close());

  return {
    get sequelize() {
      return _sequelize;
    },
  };
}
```

**Uso**:
```typescript
describe('EntitySequelizeRepository Integration Test', () => {
  let repository: EntitySequelizeRepository;
  setupSequelize({ models: [EntityModel] });

  beforeEach(async () => {
    repository = new EntitySequelizeRepository(EntityModel);
  });

  it('should insert a new entity', async () => {
    const entity = Entity.fake().anEntity().build();
    await repository.insert(entity);
    const entityCreated = await repository.findById(entity.id);
    expect(entityCreated!.toJSON()).toStrictEqual(entity.toJSON());
  });
});
```

**Benefícios**:
- Encapsula setup/teardown complexo
- Garante banco limpo a cada teste (force: true)
- Reutilizável em todos os testes de integração
- Previne vazamento de estado entre testes

### Pattern 6: Helper startApp para E2E

**Quando usar**: Testes E2E

**Implemente sempre**:
```typescript
// src/nest-modules/shared-module/testing/helpers.ts
export function startApp() {
  let _app: INestApplication;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider('UnitOfWork')
      .useFactory({
        factory: (sequelize: Sequelize) => {
          return new UnitOfWorkSequelize(sequelize as any);
        },
        inject: [getConnectionToken()],
      })
      .compile();

    const sequelize = moduleFixture.get<Sequelize>(getConnectionToken());
    await sequelize.sync({ force: true });

    _app = moduleFixture.createNestApplication();
    applyGlobalConfig(_app);
    await _app.init();
  });

  afterEach(async () => {
    await _app?.close();
  });

  return {
    get app() {
      return _app;
    },
  };
}
```

**Benefícios**:
- Aplicação completa inicializada a cada teste
- Banco de dados limpo
- Configuração global aplicada
- Isolamento total entre testes

### Pattern 7: Extensão do Supertest para Autenticação

**Quando usar**: Testes E2E com autenticação

**Implemente sempre**:
```typescript
// src/nest-modules/shared-module/testing/supertest-extend.ts
import { INestApplication } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Test } from 'supertest';

Test.prototype.authenticate = function (
  app: INestApplication,
  forceAdmin = true,
) {
  const jwtService = app.get(JwtService);
  const token = jwtService.sign(
    forceAdmin
      ? {
          realm_access: {
            roles: ['admin-catalog'],
          },
        }
      : {},
  );
  return this.set('Authorization', `Bearer ${token}`);
};
```

**Uso**:
```typescript
test('should return 401 when not authenticated', () => {
  return request(app.app.getHttpServer())
    .post('/entities')
    .send({})
    .expect(401);
});

test('should return 403 when not admin', () => {
  return request(app.app.getHttpServer())
    .post('/entities')
    .authenticate(app.app, false)
    .send({})
    .expect(403);
});

test('should create successfully', async () => {
  const res = await request(app.app.getHttpServer())
    .post('/entities')
    .authenticate(app.app)
    .send({ name: 'test' })
    .expect(201);
});
```

**Benefícios**:
- API fluente para autenticação
- Centraliza lógica de tokens
- Facilita testar diferentes permissões

### Pattern 8: Test Fixtures para Cenários E2E

**Quando usar**: Testes E2E com múltiplos cenários

**Implemente sempre**:
```typescript
// src/nest-modules/[modulo]-module/testing/[entity]-fixture.ts
export class CreateEntityFixture {
  static arrangeForCreate() {
    const faker = Entity.fake()
      .anEntity()
      .withName('Test')
      .withDescription('description test');

    return [
      {
        send_data: {
          name: faker.name,
        },
        expected: {
          name: faker.name,
          description: null,
          is_active: true,
        },
      },
      {
        send_data: {
          name: faker.name,
          description: faker.description,
          is_active: false,
        },
        expected: {
          name: faker.name,
          description: faker.description,
          is_active: false,
        },
      },
    ];
  }

  static arrangeInvalidRequest() {
    return {
      EMPTY: {
        send_data: {},
        expected: {
          message: ['name should not be empty', 'name must be a string'],
          statusCode: 422,
          error: 'Unprocessable Entity',
        },
      },
      NAME_NULL: {
        send_data: { name: null },
        expected: {
          message: ['name should not be empty', 'name must be a string'],
          statusCode: 422,
          error: 'Unprocessable Entity',
        },
      },
    };
  }

  static arrangeForEntityValidationError() {
    const faker = Entity.fake().anEntity();

    return {
      NAME_TOO_LONG: {
        send_data: {
          name: faker.withName('a'.repeat(256)).name,
        },
        expected: {
          statusCode: 422,
          error: 'Unprocessable Entity',
          message: ['name must be shorter than or equal to 255 characters'],
        },
      },
    };
  }

  static keysInResponse = ['id', 'name', 'description', 'is_active', 'created_at'];
}
```

**Uso**:
```typescript
describe('should return validation error', () => {
  const invalidRequest = CreateEntityFixture.arrangeInvalidRequest();
  const arrange = Object.keys(invalidRequest).map((key) => ({
    label: key,
    value: invalidRequest[key],
  }));

  test.each(arrange)('when body is $label', ({ value }) => {
    return request(app.app.getHttpServer())
      .post('/entities')
      .authenticate(app.app)
      .send(value.send_data)
      .expect(422)
      .expect(value.expected);
  });
});
```

**Benefícios**:
- Centraliza definição de cenários
- Reutilizável entre testes
- Documentação clara de casos
- Fácil adicionar novos cenários

## Configuração de Ambiente

### Jest Configuration (jest.config.ts)

**Aplique sempre**:
```typescript
import type { Config } from 'jest';

const config: Config = {
  moduleFileExtensions: ['js', 'json', 'ts'],
  rootDir: 'src',
  testRegex: '.*\\..*spec\\.ts$',
  transform: {
    '^.+\\.(t|j)s$': '@swc/jest',
  },
  collectCoverageFrom: ['**/*.(t|j)s'],
  coverageDirectory: '../coverage',
  coveragePathIgnorePatterns: [
    '/node_modules/',
    '.interface.ts',
    '-interface.ts',
    'shared/testing',
    'shared-module/testing',
    'validator-rules.ts',
    '-fixture.ts',
    '.input.ts',
    '.d.ts',
  ],
  coverageThreshold: {
    global: {
      statements: 80,
      branches: 80,
      functions: 80,
      lines: 80,
    },
  },
  testEnvironment: 'node',
  setupFilesAfterEnv: ['./core/shared/infra/testing/expect-helpers.ts'],
  coverageProvider: 'v8',
  clearMocks: true,
};

export default config;
```

**Pontos-chave**:
- **SWC transformer**: 10x mais rápido que ts-jest
- **Coverage threshold**: 80% mínimo obrigatório
- **Coverage ignore patterns**: Exclui interfaces, fixtures, testing utilities
- **clearMocks**: Previne vazamento entre testes
- **v8 coverage**: Mais rápido e preciso

### E2E Configuration (test/jest-e2e.config.ts)

**Aplique sempre**:
```typescript
import { Config } from 'jest';

const config: Config = {
  clearMocks: true,
  moduleFileExtensions: ['js', 'json', 'ts'],
  rootDir: '.',
  testEnvironment: 'node',
  coverageProvider: 'v8',
  testRegex: '.e2e-spec.ts$',
  transform: {
    '^.+\\.(t|j)s$': '@swc/jest',
  },
  setupFilesAfterEnv: ['./jest-setup.ts'],
};

export default config;
```

**Setup E2E (test/jest-setup.ts)**:
```typescript
import '../src/nest-modules/shared-module/testing/supertest-extend';

process.env.NODE_ENV = 'e2e';
```

### Custom Jest Matchers

**Implemente sempre que necessário**:
```typescript
// src/core/shared/infra/testing/expect-helpers.ts
import { Notification } from '../../domain/validators/notification';
import { ValueObject } from '../../domain/value-object';

expect.extend({
  notificationContainsErrorMessages(
    expected: Notification,
    received: Array<string | { [key: string]: string[] }>,
  ) {
    const every = received.every((error) => {
      if (typeof error === 'string') {
        return expected.errors.has(error);
      } else {
        return Object.entries(error).every(([field, messages]) => {
          const fieldMessages = expected.errors.get(field) as string[];
          return (
            fieldMessages &&
            fieldMessages.length &&
            fieldMessages.every((message) => messages.includes(message))
          );
        });
      }
    });

    return every
      ? { pass: true, message: () => '' }
      : {
          pass: false,
          message: () =>
            `The validation errors not contains ${JSON.stringify(
              received,
            )}. Current: ${JSON.stringify(expected.toJSON())}`,
        };
  },

  toBeValueObject(expected: ValueObject, received: ValueObject) {
    return expected.equals(received)
      ? { pass: true, message: () => '' }
      : {
          pass: false,
          message: () =>
            `The values object are not equal. Expected: ${JSON.stringify(
              expected,
            )} | Received: ${JSON.stringify(received)}`,
        };
  },
});
```

**Uso**:
```typescript
// Validar notificações de erro
expect(entity.notification).notificationContainsErrorMessages([
  {
    name: ['name should not be empty', 'name must be a string'],
  },
]);

// Comparar value objects
expect(id1).toBeValueObject(id2);
```

## Estratégia de Teste por Camada

### Domain Layer (core/[modulo]/domain/)

**O que testar**:
- Criação de entidades e agregados
- Métodos de negócio (changeName, activate, etc.)
- Validações de domínio
- Value Objects
- Invariantes de negócio

**Como testar**:
- Testes unitários (.spec.ts)
- Mock de validação em testes de construção
- test.each para edge cases
- Fake builders para criação de dados

**Exemplo**:
```typescript
describe('Entity Unit Tests', () => {
  describe('create command', () => {
    test('should create with default values', () => {
      const entity = Entity.create({ name: 'Test' });
      expect(entity.id).toBeInstanceOf(EntityId);
      expect(entity.name).toBe('Test');
      expect(entity.notification.hasErrors()).toBe(false);
    });
  });

  describe('changeName method', () => {
    test('should change name', () => {
      const entity = Entity.create({ name: 'Test' });
      entity.changeName('Updated');
      expect(entity.name).toBe('Updated');
    });

    test('should add validation error when invalid', () => {
      const entity = Entity.create({ name: 'Test' });
      entity.changeName('a'.repeat(256));
      expect(entity.notification).notificationContainsErrorMessages([
        { name: ['name must be shorter than or equal to 255 characters'] },
      ]);
    });
  });
});
```

### Application Layer (core/[modulo]/application/)

**O que testar**:
- Use cases com repositório in-memory
- Lógica de orquestração
- Transformação de input para output
- Tratamento de erros de negócio

**Como testar**:
- Testes unitários (.spec.ts)
- Spy em métodos do repositório
- Fake builders para dados
- Repositório in-memory

**Exemplo**:
```typescript
describe('CreateEntityUseCase Unit Tests', () => {
  let useCase: CreateEntityUseCase;
  let repository: EntityInMemoryRepository;

  beforeEach(() => {
    repository = new EntityInMemoryRepository();
    useCase = new CreateEntityUseCase(repository);
  });

  it('should throw error when invalid', async () => {
    const input = { name: 't'.repeat(256) };
    await expect(() => useCase.execute(input)).rejects.toThrowError(
      'Entity Validation Error',
    );
  });

  it('should create entity', async () => {
    const spyInsert = jest.spyOn(repository, 'insert');
    const output = await useCase.execute({ name: 'test' });

    expect(spyInsert).toHaveBeenCalledTimes(1);
    expect(output).toStrictEqual({
      id: repository.items[0].id.id,
      name: 'test',
      created_at: repository.items[0].created_at,
    });
  });
});
```

### Infrastructure Layer - Repositories (core/[modulo]/infra/)

**O que testar**:
- Operações CRUD com banco real
- Mapeamento ORM
- Queries e filtros
- Tratamento de erros (NotFound, etc.)

**Como testar**:
- Testes de integração (.int-spec.ts)
- setupSequelize helper
- Fake builders para dados
- Banco de dados de teste

**Exemplo**:
```typescript
describe('EntitySequelizeRepository Integration Test', () => {
  let repository: EntitySequelizeRepository;
  setupSequelize({ models: [EntityModel] });

  beforeEach(async () => {
    repository = new EntitySequelizeRepository(EntityModel);
  });

  it('should insert new entity', async () => {
    const entity = Entity.fake().anEntity().build();
    await repository.insert(entity);
    const found = await repository.findById(entity.id);
    expect(found!.toJSON()).toStrictEqual(entity.toJSON());
  });

  it('should throw error when not found', async () => {
    const entity = Entity.fake().anEntity().build();
    await expect(repository.update(entity)).rejects.toThrow(
      new NotFoundError(entity.id.id, Entity),
    );
  });
});
```

### Infrastructure Layer - Controllers (nest-modules/)

**O que testar**:
- Injeção de dependências
- Wiring de módulos
- Controllers com TestingModule

**Como testar**:
- Testes de integração (.int-spec.ts)
- TestingModule do NestJS
- Test fixtures

**Exemplo**:
```typescript
describe('EntitiesController Integration Tests', () => {
  let controller: EntitiesController;
  let repository: IEntityRepository;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [
        ConfigModule.forRoot(),
        DatabaseModule,
        AuthModule,
        EntitiesModule,
      ],
    }).compile();

    controller = module.get<EntitiesController>(EntitiesController);
    repository = module.get<IEntityRepository>(
      ENTITY_PROVIDERS.REPOSITORIES.ENTITY_REPOSITORY.provide,
    );
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
    expect(controller['createUseCase']).toBeInstanceOf(CreateEntityUseCase);
  });

  describe('create', () => {
    const arrange = CreateEntityFixture.arrangeForCreate();

    test.each(arrange)('when body is $send_data', async ({ send_data, expected }) => {
      const presenter = await controller.create(send_data);
      const entity = await repository.findById(new EntityId(presenter.id));

      expect(entity!.toJSON()).toStrictEqual({
        id: presenter.id,
        created_at: presenter.created_at,
        ...expected,
      });
    });
  });
});
```

### API Layer - E2E (test/)

**O que testar**:
- Fluxos HTTP completos
- Autenticação e autorização
- Validação de requests
- Contratos de API
- Persistência no banco

**Como testar**:
- Testes E2E (.e2e-spec.ts)
- startApp helper
- Extensão do supertest
- Test fixtures
- Validação completa de response

**Exemplo**:
```typescript
describe('EntitiesController (e2e)', () => {
  const appHelper = startApp();
  let entityRepo: IEntityRepository;

  beforeEach(async () => {
    entityRepo = appHelper.app.get<IEntityRepository>(
      ENTITY_PROVIDERS.REPOSITORIES.ENTITY_REPOSITORY.provide,
    );
  });

  describe('/entities (POST)', () => {
    describe('authentication', () => {
      test('should return 401 when not authenticated', () => {
        return request(appHelper.app.getHttpServer())
          .post('/entities')
          .send({})
          .expect(401);
      });

      test('should return 403 when not admin', () => {
        return request(appHelper.app.getHttpServer())
          .post('/entities')
          .authenticate(appHelper.app, false)
          .send({})
          .expect(403);
      });
    });

    describe('validation errors', () => {
      const invalidRequest = CreateEntityFixture.arrangeInvalidRequest();
      const arrange = Object.keys(invalidRequest).map((key) => ({
        label: key,
        value: invalidRequest[key],
      }));

      test.each(arrange)('when body is $label', ({ value }) => {
        return request(appHelper.app.getHttpServer())
          .post('/entities')
          .authenticate(appHelper.app)
          .send(value.send_data)
          .expect(422)
          .expect(value.expected);
      });
    });

    describe('successful creation', () => {
      const arrange = CreateEntityFixture.arrangeForCreate();

      test.each(arrange)('when body is $send_data', async ({ send_data, expected }) => {
        const res = await request(appHelper.app.getHttpServer())
          .post('/entities')
          .authenticate(appHelper.app)
          .send(send_data)
          .expect(201);

        expect(Object.keys(res.body)).toStrictEqual(['data']);
        expect(Object.keys(res.body.data)).toStrictEqual(
          CreateEntityFixture.keysInResponse,
        );

        const id = res.body.data.id;
        const entity = await entityRepo.findById(new Uuid(id));

        const presenter = EntitiesController.serialize(
          EntityOutputMapper.toOutput(entity!),
        );
        const serialized = instanceToPlain(presenter);

        expect(res.body.data).toStrictEqual({
          id: serialized.id,
          created_at: serialized.created_at,
          ...expected,
        });
      });
    });
  });
});
```

## Checklist de Implementação

Ao criar ou refatorar testes, verifique:

### Arquitetura
- [ ] Camadas separadas (domain, application, infra, nest-modules)
- [ ] Interfaces de repositório na camada de domínio
- [ ] Implementação in-memory para testes
- [ ] Zero dependências de framework no domain

### Configuração
- [ ] Coverage threshold configurado (80% mínimo)
- [ ] Configurações separadas para unit e E2E
- [ ] Custom matchers implementados quando necessário
- [ ] SWC configurado como transformer

### Padrões de Teste
- [ ] Fake Builder implementado para entidades principais
- [ ] Test fixtures criados para cenários E2E
- [ ] test.each usado para edge cases
- [ ] Helpers de setup/teardown implementados

### Organização
- [ ] Testes ao lado do código (__tests__/)
- [ ] Nomenclatura correta (.spec.ts, .int-spec.ts, .e2e-spec.ts)
- [ ] Fixtures organizados por módulo
- [ ] Scripts NPM configurados (test, test:watch, test:cov, test:e2e)

### Qualidade
- [ ] Mock de validação em testes de construção
- [ ] Spy em métodos importantes de repositório
- [ ] Validação completa de responses em E2E
- [ ] Testes independentes (sem vazamento de estado)

## Métricas de Qualidade

### Cobertura
- **Mínimo obrigatório**: 80% (statements, branches, functions, lines)
- **Ideal para domain layer**: >90%

### Performance
- **Unit tests**: <5s para suite completa
- **Integration tests**: <30s
- **E2E tests**: <2min

### Manutenibilidade
- Evitar testes duplicados
- Máximo 1 assertion complexa por test case
- Testes devem ser independentes
- Nomes descritivos e auto-explicativos

## Scripts NPM

Configure sempre:
```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:cov": "jest --coverage",
    "test:debug": "node --inspect-brk -r tsconfig-paths/register -r ts-node/register node_modules/.bin/jest --runInBand",
    "test:e2e": "jest --config ./test/jest-e2e.config.ts",
    "test:e2e:watch": "jest --config ./test/jest-e2e.config.ts --watch"
  }
}
```

## Dependências Necessárias

```json
{
  "devDependencies": {
    "@nestjs/testing": "^10.0.0",
    "@swc/jest": "^0.2.29",
    "@types/jest": "^29.5.0",
    "@types/supertest": "^2.0.12",
    "chance": "^1.1.11",
    "jest": "^29.5.0",
    "sequelize": "^6.32.0",
    "supertest": "^6.3.3"
  }
}
```

## Passo a Passo do Fluxo

1. **Analisar o código** que precisa de testes
2. **Identificar a camada** (domain, application, infra, nest-modules)
3. **Escolher o tipo de teste** (unit, integration, e2e)
4. **Aplicar o padrão correto** para aquela camada
5. **Implementar test fixtures/builders** se necessário
6. **Configurar helpers** de setup/teardown
7. **Escrever os testes** seguindo os patterns
8. **Validar cobertura** (mínimo 80%)
9. **Executar e verificar** que todos passam
10. **Refatorar** se necessário para melhorar clareza

## Restrições e Limites

- **NÃO misture** estratégias de teste (use unit OU integration, não ambos no mesmo arquivo)
- **NÃO coloque** lógica complexa dentro de testes (mantenha setup simples)
- **NÃO compartilhe** estado entre testes (cada teste deve ser independente)
- **NÃO teste** detalhes de implementação (teste comportamento)
- **NÃO ignore** falhas de cobertura (investigue e corrija)

## Exemplos de Uso

### Exemplo 1: Criar testes para nova entidade

**Entrada do usuário**: "Preciso criar testes para a entidade Book que acabei de implementar"

**Ações esperadas**:
1. Analisar estrutura da entidade Book
2. Implementar BookFakeBuilder
3. Criar testes unitários de domain (.spec.ts)
4. Criar testes de use cases com repositório in-memory
5. Configurar helpers se necessário

### Exemplo 2: Refatorar testes existentes

**Entrada do usuário**: "Os testes do OrderService estão muito complexos e difíceis de manter"

**Ações esperadas**:
1. Analisar testes atuais
2. Identificar padrões que podem ser aplicados
3. Implementar OrderFakeBuilder se não existe
4. Criar fixtures reutilizáveis
5. Aplicar test.each para cenários repetitivos
6. Separar testes por responsabilidade

### Exemplo 3: Configurar testes E2E para novo módulo

**Entrada do usuário**: "Preciso adicionar testes E2E para o módulo de Products"

**Ações esperadas**:
1. Criar ProductFixture com cenários de teste
2. Configurar autenticação se necessário
3. Implementar testes de validação de request
4. Implementar testes de sucesso
5. Validar response completa e persistência no banco
6. Verificar autenticação e autorização

## Versão

**Versão**: 1.0.0
**Data**: 2025-01-18
**Baseado em**: Análise técnica do projeto Video Catalog Administration Backend

## Changelog

### 1.0.0 (2025-01-18)
- Versão inicial da skill
- 8 padrões obrigatórios documentados
- Estratégias de teste por camada definidas
- Checklist de implementação completo
- Exemplos práticos para cada pattern
