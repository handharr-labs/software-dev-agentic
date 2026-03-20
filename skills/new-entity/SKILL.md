---
name: new-entity
description: Create a domain entity and its corresponding DTO. Use when defining a new business object.
allowed-tools: Read, Write, Glob
---

Create a new domain entity and its DTO for this Next.js Clean Architecture project.

Ask me:
1. Entity name (PascalCase, e.g. `LeaveRequest`)
2. Fields: name, TypeScript type, required or optional, and what each represents
3. Does the API use different field names (e.g. `snake_case` from the server)?

Then generate:

**`src/domain/entities/[Name].ts`**
- `readonly` properties on every field
- Plain TypeScript interface — no class, no decorators, no framework imports
- Properties represent business concepts (not API field names)

**`src/data/dtos/[Name]DTO.ts`**
- Mirrors the raw API response shape exactly (snake_case if that's what the API returns)
- All fields non-readonly (DTOs are just data containers)
- No domain logic

**`src/data/mappers/[Name]Mapper.ts`**
- Interface: `[Name]Mapper` with `toEntity(dto: [Name]DTO): [Name]` method
- Implementation: `[Name]MapperImpl implements [Name]Mapper`
- Handle null/undefined optional fields explicitly
- Map API field names to domain field names

After creating, remind me to:
- Register the mapper in `src/di/container.server.ts` and `container.client.ts`
- Create a mock: `__tests__/mocks/Mock[Name]Mapper.ts`
- Add test: `__tests__/data/mappers/[Name]Mapper.test.ts`
