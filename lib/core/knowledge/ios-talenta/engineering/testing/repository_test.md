---
platform: ios
project: ios-talenta
discipline: engineering
topic: testing
pattern: repository_test
---

## Theory

Repository implementation tests verify the bridge between DataSource and Domain:

- Use a test double (mock/stub) for the DataSource — not a real network or DB
- Assert that the repository maps DataSource output to the correct domain entity
- Assert that DataSource errors are caught and mapped to the correct domain error type
- One test per operation (get, create, update, delete)

---

## Repository Tests

Test that RepositoryImpl correctly bridges DataSource results to Domain completions.

```swift
// TalentaTests/Mock/Module/[Feature]/Data/Repository/[Feature]RepositoryImplTests.swift
class EmployeeRepositoryImplTests: XCTestCase {
    var sut: EmployeeRepositoryImpl!
    var dataSourceMock: EmployeeDataSourceMock!
    var mapperMock: EmployeeModelMapperMock!

    override func setUp() {
        super.setUp()
        dataSourceMock = EmployeeDataSourceMock()
        mapperMock = EmployeeModelMapperMock()
        sut = EmployeeRepositoryImpl(dataSource: dataSourceMock, mapper: mapperMock)
    }

    func test_getEmployee_success_callsCompletion_withMappedModel() {
        let response = EmployeeResponse(id: 1, name: "John")
        let expectedModel = EmployeeModel(id: 1, name: "John")
        dataSourceMock.resultToReturn = .success(response)
        mapperMock.modelToReturn = expectedModel

        var receivedResult: Result<EmployeeModel, BaseErrorModel>?
        sut.getEmployee(params: .init(id: "1")) { receivedResult = $0 }

        XCTAssertEqual(try? receivedResult?.get().id, 1)
        XCTAssertEqual(mapperMock.fromResponseCallCount, 1)
    }

    func test_getEmployee_failure_propagatesError() {
        let error = BaseErrorModel(message: "Not found")
        dataSourceMock.resultToReturn = .failure(error)

        var receivedResult: Result<EmployeeModel, BaseErrorModel>?
        sut.getEmployee(params: .init(id: "99")) { receivedResult = $0 }

        if case .failure(let e) = receivedResult {
            XCTAssertEqual(e.message, "Not found")
        } else {
            XCTFail("Expected failure")
        }
    }
}
```

**Rules:**
- Mock both DataSource and Mapper — test RepositoryImpl in isolation
- One success test, one failure test per method
- Verify mapper is called on success; verify error is passed through unchanged on failure
