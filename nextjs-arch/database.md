## 17. Database Layer (Full-Stack Mode)

Introduces a `db/` data source variant alongside the existing `remote/` data source. The domain layer — entities, repository interfaces, use cases — is **unchanged**. Only the DataSource implementation and its Repository wiring differ.

> **Frontend-only projects**: skip this section. The remote data source pattern already covers your data needs.

### 17.1 Core Principle — Swap the DataSource, Keep Everything Else

```
Frontend-only:                          Full-stack:
  RepositoryImpl                          DbRepositoryImpl
    → RemoteDataSourceImpl (Axios)          → DbDataSourceImpl (Prisma / Drizzle / etc.)
    → EmployeeMapperImpl                    → EmployeeDbMapperImpl
    → ErrorMapperImpl                       → DbErrorMapperImpl

Both implement the same:
  EmployeeRepository (domain interface)   ← never changes
```

The DI container is the only file that changes when switching modes. Business logic (use cases, domain services) is reused without modification.

### 17.2 DB Record Types

Analogous to DTOs, but represent the database row shape instead of the API response shape.

```typescript
// data/data-sources/db/records/EmployeeDbRecord.ts
export interface EmployeeDbRecord {
  id: string;
  full_name: string;
  email_address: string;
  department_id: string;
  department_name: string;
  joined_at: Date;           // DB returns Date, not string
  created_at: Date;
  updated_at: Date;
}

// data/data-sources/db/records/PaginatedDbResult.ts
export interface PaginatedDbResult<T> {
  records: T[];
  total: number;
  page: number;
  pageSize: number;
}
```

**Rules:**
- DB records use snake_case to match column names (convert to camelCase in DB mapper)
- DB records are plain interfaces — no ORM decorators, no class inheritance
- DB records never escape the data layer
- Nullable DB columns map to `T | null` (not `T | undefined`)

### 17.3 DB DataSource

```typescript
// data/data-sources/db/EmployeeDbDataSource.ts
import type { EmployeeDbRecord } from './records/EmployeeDbRecord';
import type { PaginatedDbResult } from './records/PaginatedDbResult';

export interface EmployeeDbDataSource {
  findById(id: string): Promise<EmployeeDbRecord>;
  findMany(params: {
    page: number;
    limit: number;
    departmentId?: string;
    searchQuery?: string;
  }): Promise<PaginatedDbResult<EmployeeDbRecord>>;
  update(id: string, data: Partial<EmployeeDbRecord>): Promise<EmployeeDbRecord>;
  delete(id: string): Promise<void>;
}
```

```typescript
// data/data-sources/db/EmployeeDbDataSourceImpl.ts
import type { EmployeeDbDataSource } from './EmployeeDbDataSource';
import type { EmployeeDbRecord } from './records/EmployeeDbRecord';
import type { PaginatedDbResult } from './records/PaginatedDbResult';

// ORM client type — replace with your ORM's client type when chosen:
// Prisma:  import { PrismaClient } from '@prisma/client';
// Drizzle: import { LibSQLDatabase } from 'drizzle-orm/libsql';
type DbClient = unknown; // TODO: replace with ORM client type

export class EmployeeDbDataSourceImpl implements EmployeeDbDataSource {
  constructor(private readonly db: DbClient) {}

  async findById(id: string): Promise<EmployeeDbRecord> {
    // Prisma example:
    // return this.db.employee.findUniqueOrThrow({ where: { id } });

    // Drizzle example:
    // const result = await this.db.select().from(employees).where(eq(employees.id, id));
    // if (!result[0]) throw new DbNotFoundError(`Employee ${id} not found`);
    // return result[0];

    throw new Error('Not implemented — add ORM query here');
  }

  async findMany(params: {
    page: number;
    limit: number;
    departmentId?: string;
    searchQuery?: string;
  }): Promise<PaginatedDbResult<EmployeeDbRecord>> {
    // TODO: implement with your ORM
    throw new Error('Not implemented — add ORM query here');
  }

  async update(id: string, data: Partial<EmployeeDbRecord>): Promise<EmployeeDbRecord> {
    // TODO: implement with your ORM
    throw new Error('Not implemented — add ORM query here');
  }

  async delete(id: string): Promise<void> {
    // TODO: implement with your ORM
    throw new Error('Not implemented — add ORM query here');
  }
}
```

### 17.4 DB Mapper

Maps `DbRecord → Domain Entity`. Same interface + impl pattern as HTTP mappers.

```typescript
// data/mappers/db/EmployeeDbMapper.ts
import type { Employee } from '@/domain/entities/Employee';
import type { EmployeeDbRecord } from '../data-sources/db/records/EmployeeDbRecord';

export interface EmployeeDbMapper {
  toDomain(record: EmployeeDbRecord): Employee;
}

export class EmployeeDbMapperImpl implements EmployeeDbMapper {
  toDomain(record: EmployeeDbRecord): Employee {
    return {
      id: record.id,
      name: record.full_name,
      email: record.email_address,
      department: {
        id: record.department_id,
        name: record.department_name,
        headCount: 0, // load separately if needed
      },
      joinDate: record.joined_at, // already a Date from DB
    };
  }
}
```

### 17.5 DB Repository Implementation

A separate impl class that uses the DB data source. Implements the same domain interface as the remote repository.

```typescript
// data/repositories/EmployeeDbRepositoryImpl.ts
import type { EmployeeRepository } from '@/domain/repositories/EmployeeRepository';
import type { Employee } from '@/domain/entities/Employee';
import type { PaginatedResult } from '@/domain/entities/PaginatedResult';
import type { EmployeeDbDataSource } from '../data-sources/db/EmployeeDbDataSource';
import type { EmployeeDbMapper } from '../mappers/db/EmployeeDbMapper';
import type { DbErrorMapper } from '../mappers/db/DbErrorMapper';

export class EmployeeDbRepositoryImpl implements EmployeeRepository {
  constructor(
    private readonly dataSource: EmployeeDbDataSource,
    private readonly mapper: EmployeeDbMapper,
    private readonly errorMapper: DbErrorMapper,
  ) {}

  async getEmployee(id: string): Promise<Employee> {
    try {
      const record = await this.dataSource.findById(id);
      return this.mapper.toDomain(record);
    } catch (error) {
      throw this.errorMapper.toDomain(error);
    }
  }

  async getEmployees(params: {
    page: number;
    limit: number;
    departmentId?: string;
    searchQuery?: string;
  }): Promise<PaginatedResult<Employee>> {
    try {
      const result = await this.dataSource.findMany(params);
      return {
        items: result.records.map((r) => this.mapper.toDomain(r)),
        totalCount: result.total,
        currentPage: result.page,
        totalPages: Math.ceil(result.total / result.pageSize),
      };
    } catch (error) {
      throw this.errorMapper.toDomain(error);
    }
  }

  async updateEmployee(employee: Employee): Promise<Employee> {
    try {
      const record = await this.dataSource.update(employee.id, {
        full_name: employee.name,
        email_address: employee.email,
      });
      return this.mapper.toDomain(record);
    } catch (error) {
      throw this.errorMapper.toDomain(error);
    }
  }

  async deleteEmployee(id: string): Promise<void> {
    try {
      await this.dataSource.delete(id);
    } catch (error) {
      throw this.errorMapper.toDomain(error);
    }
  }
}
```

### 17.6 DB Error Mapper

Maps ORM-specific errors to `DomainError`. Pattern mirrors `ErrorMapperImpl` for HTTP errors.

```typescript
// data/mappers/db/DbErrorMapper.ts
import { DomainError } from '@/domain/errors/DomainError';

export interface DbErrorMapper {
  toDomain(error: unknown): DomainError;
}

export class DbErrorMapperImpl implements DbErrorMapper {
  toDomain(error: unknown): DomainError {
    // Prisma error codes:
    // P2025 → record not found
    // P2002 → unique constraint violation
    // P2003 → foreign key constraint violation

    // if (error instanceof Prisma.PrismaClientKnownRequestError) {
    //   if (error.code === 'P2025') return DomainError.notFound('Resource', '');
    //   if (error.code === 'P2002') return DomainError.conflict('Resource already exists');
    // }

    // Drizzle throws generic JS errors — check message or use a wrapper

    if (error instanceof DomainError) return error; // already mapped
    return new DomainError('unknown', { message: String(error) });
  }
}
```

Fill in the ORM-specific error codes when the ORM is chosen. The interface never changes.

### 17.7 Wiring in the Container

```typescript
// di/container.server.ts (full-stack mode)
import 'server-only';

// --- Replace remote data sources with DB data sources ---
import { db } from '@/lib/db';   // your ORM client singleton (Prisma / Drizzle)
import { EmployeeDbDataSourceImpl } from '@/data/data-sources/db/EmployeeDbDataSourceImpl';
import { EmployeeDbRepositoryImpl } from '@/data/repositories/EmployeeDbRepositoryImpl';
import { EmployeeDbMapperImpl } from '@/data/mappers/db/EmployeeDbMapper';
import { DbErrorMapperImpl } from '@/data/mappers/db/DbErrorMapper';
import { GetEmployeesUseCaseImpl } from '@/domain/use-cases/employee/GetEmployeesUseCase';

const dbErrorMapper = new DbErrorMapperImpl();

const employeeDataSource = new EmployeeDbDataSourceImpl(db);
const employeeMapper = new EmployeeDbMapperImpl();
const employeeRepository = new EmployeeDbRepositoryImpl(
  employeeDataSource,
  employeeMapper,
  dbErrorMapper
);

// Use case factories — same as before, repository interface is unchanged
export const getEmployeesUseCase = () => new GetEmployeesUseCaseImpl(employeeRepository);
export const getEmployeeUseCase = () => new GetEmployeeUseCaseImpl(employeeRepository);
```

```typescript
// lib/db.ts — ORM client singleton (add when ORM is chosen)
// Prisma example:
// import { PrismaClient } from '@prisma/client';
// const globalForPrisma = global as unknown as { prisma: PrismaClient };
// export const db = globalForPrisma.prisma || new PrismaClient();
// if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = db;

// Drizzle example:
// import { drizzle } from 'drizzle-orm/libsql';
// import { createClient } from '@libsql/client';
// const client = createClient({ url: process.env.DATABASE_URL! });
// export const db = drizzle(client);

export const db = null; // TODO: replace with ORM client
```

### 17.8 Full-Stack Project Structure Addition

```
src/
├── lib/
│   └── db.ts                              ← ORM client singleton (new)
├── data/
│   ├── data-sources/
│   │   ├── remote/                        ← untouched (frontend mode)
│   │   └── db/                            ← new (full-stack mode)
│   │       ├── records/
│   │       │   ├── EmployeeDbRecord.ts
│   │       │   └── PaginatedDbResult.ts
│   │       ├── EmployeeDbDataSource.ts    ← interface
│   │       └── EmployeeDbDataSourceImpl.ts← ORM stub
│   ├── mappers/
│   │   ├── db/                            ← new
│   │   │   ├── EmployeeDbMapper.ts
│   │   │   └── DbErrorMapper.ts
│   │   └── ...                            ← existing HTTP mappers untouched
│   └── repositories/
│       ├── EmployeeRepositoryImpl.ts      ← untouched (remote mode)
│       └── EmployeeDbRepositoryImpl.ts    ← new (DB mode)
```

### 17.9 Decision Rule — Remote vs DB

```
Is this project consuming an external API you don't control?
  └── YES → use RemoteDataSource (Axios) + RepositoryImpl

Is this project the backend (Next.js owns the database)?
  └── YES → use DbDataSource + DbRepositoryImpl

Does the project need BOTH (e.g., call external APIs AND write to own DB)?
  └── YES → both can coexist in container.server.ts
             one feature can use RemoteDataSource
             another feature can use DbDataSource
             domain + use cases never know the difference
```

---
