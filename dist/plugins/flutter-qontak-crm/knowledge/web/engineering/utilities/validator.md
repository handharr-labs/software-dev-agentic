---
platform: web
project: web
discipline: engineering
topic: utilities
pattern: validator
---

## Validator

Input validation for common form fields.

```typescript
// core/validation/Validator.ts
export type ValidationError =
  | 'empty'
  | 'invalidEmail'
  | 'invalidPhone'
  | 'tooShort'
  | 'tooLong'
  | 'invalidFormat';

export interface ValidationResult {
  valid: boolean;
  error?: ValidationError;
  message?: string;
}

export interface Validator {
  validate(value: string): ValidationResult;
}

export class EmailValidator implements Validator {
  validate(value: string): ValidationResult {
    if (!value.trim()) return { valid: false, error: 'empty', message: 'Email is required' };
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(value)) {
      return { valid: false, error: 'invalidEmail', message: 'Enter a valid email address' };
    }
    return { valid: true };
  }
}

export class LengthValidator implements Validator {
  constructor(private readonly min: number, private readonly max = Infinity) {}

  validate(value: string): ValidationResult {
    if (!value.trim()) return { valid: false, error: 'empty', message: 'This field is required' };
    if (value.length < this.min) {
      return { valid: false, error: 'tooShort', message: `Minimum ${this.min} characters` };
    }
    if (value.length > this.max) {
      return { valid: false, error: 'tooLong', message: `Maximum ${this.max} characters` };
    }
    return { valid: true };
  }
}

// React hook for form field validation
export function useFormField(validator: Validator) {
  const [value, setValue] = useState('');
  const [touched, setTouched] = useState(false);

  const result = touched ? validator.validate(value) : { valid: true };

  return {
    value,
    error: result.valid ? null : result.message ?? null,
    isValid: result.valid,
    onChange: (v: string) => { setValue(v); setTouched(true); },
    onBlur: () => setTouched(true),
  };
}
```
