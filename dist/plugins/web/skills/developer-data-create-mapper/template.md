# DTO + Mapper Templates

## DTO
```typescript
// src/data/dtos/[Name]DTO.ts
export interface [Name]DTO {
  id: string;
  [api_field_name]: [type];   // snake_case if API returns it
  [nullable_field]: [type] | null;
}
```

## Mapper
```typescript
// src/data/mappers/[Name]Mapper.ts
import type { [Name] } from '@/domain/entities/[Name]';
import type { [Name]DTO } from '@/data/dtos/[Name]DTO';

export interface [Name]Mapper {
  toEntity(dto: [Name]DTO): [Name];
}

export class [Name]MapperImpl implements [Name]Mapper {
  toEntity(dto: [Name]DTO): [Name] {
    return {
      id: dto.id,
      [domainField]: dto.[api_field_name],
      [optionalField]: dto.[nullable_field] ?? null,
    };
  }
}
```
