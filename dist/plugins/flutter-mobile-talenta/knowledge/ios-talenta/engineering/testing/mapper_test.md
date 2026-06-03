---
platform: ios
project: ios-talenta
discipline: engineering
topic: testing
pattern: mapper_test
---

## Theory

Mapper tests are pure input → output assertions — the simplest tests to write:

- Provide a fully-populated DTO → assert every field maps to the correct entity field
- Provide a DTO with missing/null optional fields → assert safe defaults or null handling
- No mocks needed — mappers have no dependencies

---

## Mapper Tests

Test that Response DTOs are correctly converted to Domain Models.

```swift
// TalentaTests/Mock/Module/[Feature]/Data/Mapper/[Feature]ModelMapperTests.swift
class EmployeeModelMapperTests: XCTestCase {
    var sut: EmployeeModelMapper!

    override func setUp() {
        super.setUp()
        sut = EmployeeModelMapper()
    }

    func test_fromResponseToModel_mapsAllFields() {
        let response = EmployeeResponse(id: 1, name: "John Doe", isActive: true)

        let model = sut.fromResponseToModel(from: response)

        XCTAssertEqual(model.id, 1)
        XCTAssertEqual(model.name, "John Doe")
        XCTAssertTrue(model.isActive)
    }

    func test_fromResponseToModel_handlesNilFields() {
        let response = EmployeeResponse(id: nil, name: nil, isActive: nil)

        let model = sut.fromResponseToModel(from: response)

        XCTAssertEqual(model.id, 0)    // .orZero()
        XCTAssertEqual(model.name, "") // .orEmpty()
        XCTAssertFalse(model.isActive) // .orFalse()
    }
}
```

**Rules:**
- One test for the happy path (all fields present)
- One test for nil handling — verify `.orZero()`, `.orEmpty()`, `.orFalse()` defaults
- Every Entity field must appear in at least one assertion

## Mock vs Real

| Use a mock/stub when… | Use a real implementation when… |
|---|---|
| The dependency has I/O (network, HTTP, DB) | The dependency is pure (Mapper, Domain Service) |
| The test must control exact return values | The test verifies the full integration path |
| Unit test speed matters | Correctness of full wiring matters — integration test |

**Never mock Mappers or Domain Services** — they are pure functions. Test them with real inputs and outputs (see Mapper Tests above).

**Mock creation:** Use the Mock Pattern above — a concrete class implementing the protocol, with `callCount`, `paramsReceived`, and `resultToReturn` properties.
