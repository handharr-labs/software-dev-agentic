---
name: detective-debug-add-logs
description: |
  Add strategic debug logging to trace execution flow or diagnose issues. Use when troubleshooting a bug or instrumenting RxSwift chains for visibility.
user-invocable: false
---

## Inputs (always provided by the caller)

- `Bug description` — what the issue is and when it occurs
- `Entry point` — the action, method, or screen where the failure begins
- `Target files` — comma-separated file paths or class names to instrument; if `unknown`, infer from the entry point using Grep before editing
- `Expected / Actual` — optional; used to decide which branches and state changes to prioritize logging

## Architecture Rule

**New code → V2 patterns always. Existing code → keep its current pattern. Never migrate unless explicitly asked.**

# Debug: Add Strategic Logs

Add strategic debug logs across files to troubleshoot issues and understand execution flow.

## When to Use

- Investigating a bug or unexpected behavior
- Tracing execution flow across multiple files
- Understanding state changes and data transformations
- Debugging network calls and async operations
- Tracking ViewModel event handling

## Prerequisites

Before using this skill, ensure:

- [ ] **Issue identified** - The problem or unexpected behavior is described
- [ ] **Files identified** - Relevant files/components involved in the issue are known
- [ ] **Build succeeds** - The project compiles (debug logs need to compile)

## Quick Start

Simply describe the issue:
- "Debug the login flow when user taps submit"
- "Add logs to trace why attendance submission fails"
- "Debug the ViewModel state changes in DashboardViewModel"

## Debug Log Format

All debug logs use the **`[DebugTest]`** prefix for easy filtering in console:

```swift
print("[DebugTest] Description of what's happening")
print("[DebugTest] MethodName - Variable: \(value)")
print("[DebugTest] Flow checkpoint: About to call API")
```

### Filtering in Xcode Console

```
# Filter for debug logs only
[DebugTest]

# Clear console before running
cmd + K
```

## Debugging Workflow

### 1. Analyze the Issue

**Gather Information**:
- Which file(s) are involved?
- What's the expected behavior?
- What's the actual behavior?
- When does the issue occur? (specific user action, condition)

**Trace the Flow**:
```
User Action
  → ViewController (UI event)
    → ViewModel (emitEvent)
      → Private method (business logic)
        → UseCase (execute)
          → Repository (API call)
            → DataSource (network)
```

### 2. Identify Strategic Log Points

Add logs at these critical points:

#### Entry Points
```swift
// ViewController - User Action
@objc private func submitButtonTapped() {
    print("[DebugTest] submitButtonTapped - Starting submission flow")
    viewModel.emitEvent(.submitButtonTapped)
}
```

#### ViewModel Events
```swift
override func emitEvent(_ event: LoginViewModelEvent) {
    print("[DebugTest] emitEvent - Received event: \(event)")

    switch event {
    case .submitButtonTapped:
        print("[DebugTest] emitEvent - Handling submitButtonTapped")
        handleSubmitButtonTapped()
    }
}
```

#### Private Methods
```swift
private func handleSubmitButtonTapped() {
    print("[DebugTest] handleSubmitButtonTapped - START")
    print("[DebugTest] handleSubmitButtonTapped - Email: \(email), Password length: \(password.count)")

    guard !email.isEmpty else {
        print("[DebugTest] handleSubmitButtonTapped - GUARD FAILED: Email is empty")
        return
    }

    print("[DebugTest] handleSubmitButtonTapped - Guards passed, calling validateCredentials")
    validateCredentials()
}
```

#### State Changes
```swift
private func updateLoginState(_ newState: LoginState) {
    print("[DebugTest] updateLoginState - BEFORE: \(currentState)")
    print("[DebugTest] updateLoginState - AFTER: \(newState)")

    updateDataStateWith { state in
        state?.loginState = newState
    }
}
```

#### UseCase Calls
```swift
loginUseCase.execute(param: loginParam)
    .observe(on: mainScheduler)
    .subscribe(onNext: { [weak self] result in
        print("[DebugTest] LoginUseCase - Received result")

        switch result {
        case .success(let user):
            print("[DebugTest] LoginUseCase - SUCCESS: User ID: \(user.id), Name: \(user.name)")
            self?.handleLoginSuccess(user)
        case .failure(let error):
            print("[DebugTest] LoginUseCase - FAILURE: \(error.message)")
            self?.handleLoginError(error)
        }
    })
    .disposed(by: disposeBag)
```

#### Repository/DataSource
```swift
func login(param: LoginParam?, completion: @escaping (Result<UserModel, BaseErrorModel>) -> Void) {
    print("[DebugTest] LoginRepository - START")
    print("[DebugTest] LoginRepository - Param: \(String(describing: param))")

    dataSource.postLogin(params: param?.toDictionary()) { [weak self] expected in
        print("[DebugTest] LoginRepository - DataSource response received")

        switch expected {
        case .success(let response):
            print("[DebugTest] LoginRepository - Response data: \(String(describing: response.data))")
            // ...
        case .failure(let error):
            print("[DebugTest] LoginRepository - Error: \(error)")
            // ...
        }
    }
}
```

#### Network Calls
```swift
func postLogin(params: [String: Any]?, expected: @escaping (Expected<TalentaBaseResponse<UserResponse>, TalentaBaseErrorModel>) -> Void) {
    print("[DebugTest] DataSource - postLogin START")
    print("[DebugTest] DataSource - Params: \(String(describing: params))")
    print("[DebugTest] DataSource - Endpoint: /api/v1/login")

    provider.request(.postLogin(params: params)) { result in
        print("[DebugTest] DataSource - Network response received")
        // ...
    }
}
```

### 3. Add Logs Strategically

**Key Principles**:
1. **Entry & Exit**: Log at start and end of methods
2. **Conditionals**: Log before `if`/`guard`, and inside each branch
3. **Transformations**: Log before/after data mapping
4. **Async Points**: Log before/after async operations
5. **State Changes**: Log state before/after updates

**Example - Complete Flow**:

```swift
// ViewController.swift
@objc private func loginButtonTapped() {
    print("[DebugTest] ViewController.loginButtonTapped - START")
    viewModel.emitEvent(.loginButtonTapped)
}

// LoginViewModel.swift
override func emitEvent(_ event: LoginViewModelEvent) {
    print("[DebugTest] LoginViewModel.emitEvent - Event: \(event)")

    switch event {
    case .loginButtonTapped:
        handleLoginButtonTapped()
    }
}

private func handleLoginButtonTapped() {
    print("[DebugTest] LoginViewModel.handleLoginButtonTapped - START")
    print("[DebugTest] LoginViewModel - Current state: \(currentState)")

    let email = currentState.email
    let password = currentState.password

    print("[DebugTest] LoginViewModel - Email: \(email), Password: [REDACTED - length: \(password.count)]")

    guard !email.isEmpty else {
        print("[DebugTest] LoginViewModel - GUARD FAILED: Email empty")
        emitCommonAction(.toast(ToastModel.createError(message: "Email required")))
        return
    }

    guard !password.isEmpty else {
        print("[DebugTest] LoginViewModel - GUARD FAILED: Password empty")
        emitCommonAction(.toast(ToastModel.createError(message: "Password required")))
        return
    }

    print("[DebugTest] LoginViewModel - Guards passed, calling performLogin")
    performLogin(email: email, password: password)
}

private func performLogin(email: String, password: String) {
    print("[DebugTest] LoginViewModel.performLogin - START")
    print("[DebugTest] LoginViewModel - Creating LoginParam")

    let param = LoginParam(email: email, password: password)

    print("[DebugTest] LoginViewModel - Emitting loading state")
    emitCommonAction(.loading(LoadingScreenModel(tag: 1, show: true)))

    print("[DebugTest] LoginViewModel - Calling loginUseCase.execute")
    loginUseCase.execute(param: param)
        .observe(on: mainScheduler)
        .subscribe(onNext: { [weak self] result in
            print("[DebugTest] LoginViewModel - UseCase response received")
            self?.emitCommonAction(.loading(LoadingScreenModel(tag: 1, show: false)))

            switch result {
            case .success(let user):
                print("[DebugTest] LoginViewModel - Login SUCCESS")
                print("[DebugTest] LoginViewModel - User: ID=\(user.id), Name=\(user.name)")
                self?.handleLoginSuccess(user)

            case .failure(let error):
                print("[DebugTest] LoginViewModel - Login FAILURE")
                print("[DebugTest] LoginViewModel - Error: \(error.message)")
                self?.handleLoginError(error)
            }
        })
        .disposed(by: disposeBag)
}

private func handleLoginSuccess(_ user: UserModel) {
    print("[DebugTest] LoginViewModel.handleLoginSuccess - START")
    print("[DebugTest] LoginViewModel - Updating state with user")

    updateDataStateWith { state in
        state?.user = user
        state?.isLoggedIn = true
    }

    print("[DebugTest] LoginViewModel - Navigating to dashboard")
    navigator?.showDashboard()
    print("[DebugTest] LoginViewModel.handleLoginSuccess - END")
}

private func handleLoginError(_ error: BaseErrorModel) {
    print("[DebugTest] LoginViewModel.handleLoginError - START")
    print("[DebugTest] LoginViewModel - Error: \(error.message)")

    emitCommonAction(.toast(ToastModel.createError(message: error.message)))
    print("[DebugTest] LoginViewModel.handleLoginError - END")
}
```

### 4. Run and Analyze Logs

**Steps**:
1. **Clear Console**: `Cmd + K` in Xcode
2. **Run App**: Trigger the issue
3. **Filter Logs**: Search for `[DebugTest]` in console
4. **Analyze Flow**: Follow the sequence of logs

**What to Look For**:
- Missing logs (method not called?)
- Unexpected values (wrong data?)
- Failed guards (condition not met?)
- Error messages (what failed?)
- State changes (when did it change?)
- Async timing (order of execution?)

### 5. Clean Up Debug Logs

**After fixing the issue**, remove all debug logs:

```bash
# Search for all debug logs in project
grep -r "\[DebugTest\]" Talenta/

# Or use Xcode Find in Project
# Search: print("[DebugTest]
# Scope: Talenta folder
```

Delete each `print("[DebugTest] ...)` line.

**IMPORTANT**: Never commit debug logs to the repository!

## Common Debugging Patterns

### Pattern 1: Guard Clause Debugging

```swift
guard let data = response.data else {
    print("[DebugTest] GUARD FAILED - response.data is nil")
    print("[DebugTest] Full response: \(response)")
    completion(.failure(BaseErrorModel.createEmptyDataError()))
    return
}
print("[DebugTest] Guard passed - data exists")
```

### Pattern 2: Optional Chaining Debugging

```swift
print("[DebugTest] Before optional chain:")
print("[DebugTest] - currentState: \(currentState)")
print("[DebugTest] - currentState.dataState: \(currentState.dataState)")
print("[DebugTest] - currentState.dataState.data: \(String(describing: currentState.dataState.data))")

let item = currentState.dataState.data?.selectedItem

print("[DebugTest] After optional chain - item: \(String(describing: item))")
```

### Pattern 3: RxSwift Chain Debugging

```swift
someObservable
    .do(onNext: { value in
        print("[DebugTest] RxChain - onNext: \(value)")
    })
    .map { value in
        print("[DebugTest] RxChain - map INPUT: \(value)")
        let transformed = transform(value)
        print("[DebugTest] RxChain - map OUTPUT: \(transformed)")
        return transformed
    }
    .filter { value in
        let passes = value > 0
        print("[DebugTest] RxChain - filter: \(value) passes: \(passes)")
        return passes
    }
    .subscribe(onNext: { value in
        print("[DebugTest] RxChain - subscribe: \(value)")
    })
    .disposed(by: disposeBag)
```

### Pattern 4: State Change Debugging

```swift
private func updateState(_ updates: (inout State) -> Void) {
    print("[DebugTest] updateState - BEFORE:")
    print("[DebugTest] - isLoading: \(currentState.isLoading)")
    print("[DebugTest] - data: \(String(describing: currentState.dataState.data))")

    updateStateWith { state in
        updates(&state!)
    }

    print("[DebugTest] updateState - AFTER:")
    print("[DebugTest] - isLoading: \(currentState.isLoading)")
    print("[DebugTest] - data: \(String(describing: currentState.dataState.data))")
}
```

### Pattern 5: Network Debugging

```swift
func postData(params: [String: Any]?) {
    print("[DebugTest] Network - Endpoint: \(endpoint)")
    print("[DebugTest] Network - Method: POST")
    print("[DebugTest] Network - Headers: \(headers)")
    print("[DebugTest] Network - Params: \(String(describing: params))")

    provider.request(.postData(params: params)) { result in
        switch result {
        case .success(let response):
            print("[DebugTest] Network - SUCCESS")
            print("[DebugTest] Network - Status: \(response.statusCode)")
            print("[DebugTest] Network - Data: \(String(data: response.data, encoding: .utf8) ?? "N/A")")

        case .failure(let error):
            print("[DebugTest] Network - FAILURE")
            print("[DebugTest] Network - Error: \(error.localizedDescription)")
        }
    }
}
```

## Best Practices

### DO ✅

- Use `[DebugTest]` prefix consistently
- Log method entry/exit points
- Log all conditional branches
- Log state before/after changes
- Log parameters and return values
- Use descriptive messages
- Redact sensitive data (passwords, tokens)
- Remove logs after fixing the issue

### DON'T ❌

- Log passwords or sensitive data in plain text
- Commit debug logs to repository
- Add logs without understanding the flow
- Use `print()` without `[DebugTest]` prefix
- Leave debug logs in production code
- Over-log trivial operations
- Log in tight loops (performance impact)

## Security Considerations

**NEVER log**:
- Passwords (use `[REDACTED]` or password length)
- API tokens
- Auth tokens
- Personal data (emails, names) in production
- Credit card info
- Any PII (Personally Identifiable Information)

**Safe Logging**:
```swift
// ❌ DON'T
print("[DebugTest] Password: \(password)")
print("[DebugTest] Token: \(authToken)")

// ✅ DO
print("[DebugTest] Password length: \(password.count)")
print("[DebugTest] Token exists: \(authToken != nil)")
print("[DebugTest] Email domain: \(email.split(separator: "@").last ?? "N/A")")
```

## Example: Complete Debugging Session

**Issue**: "Login button tapped but nothing happens"

**Debug Strategy**:
1. Add logs in ViewController button action
2. Add logs in ViewModel emitEvent
3. Add logs in private method handlers
4. Add logs in UseCase execute
5. Add logs in Repository
6. Run and filter for `[DebugTest]`

**Expected Log Output**:
```
[DebugTest] ViewController.loginButtonTapped - START
[DebugTest] LoginViewModel.emitEvent - Event: loginButtonTapped
[DebugTest] LoginViewModel.handleLoginButtonTapped - START
[DebugTest] LoginViewModel - Email: test@example.com, Password: [REDACTED - length: 8]
[DebugTest] LoginViewModel - Guards passed, calling performLogin
[DebugTest] LoginViewModel.performLogin - START
[DebugTest] LoginViewModel - Calling loginUseCase.execute
[DebugTest] LoginUseCase.execute - START
[DebugTest] LoginRepository - START
[DebugTest] DataSource - postLogin START
[DebugTest] DataSource - Network response received
[DebugTest] LoginRepository - DataSource response received
[DebugTest] LoginUseCase - Received result
[DebugTest] LoginViewModel - Login SUCCESS
[DebugTest] LoginViewModel - User: ID=123, Name=John Doe
[DebugTest] LoginViewModel - Navigating to dashboard
```

**Finding**: If logs stop at a certain point, that's where the issue is!

## Cleanup Checklist

Before committing code:

- [ ] Search project for `[DebugTest]`
- [ ] Remove all debug print statements
- [ ] Verify no sensitive data was logged
- [ ] Test that app still works without logs
- [ ] Run `git diff` to ensure only intended changes
- [ ] Clear console output before final test

## Related Guidelines

- [CLAUDE.md](../../CLAUDE.md) - Project overview and architecture

