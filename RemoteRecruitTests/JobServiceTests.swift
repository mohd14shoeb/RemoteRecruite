import XCTest
@testable import RemoteRecruit

/// A mock implementation of `NetworkClientProtocol` that allows us to
/// inject predetermined responses or errors for unit testing.
final class MockNetworkClient: NetworkClientProtocol {
    var requestResult: Result<Any, Error> = .failure(NSError(domain: "", code: 0, userInfo: nil))

    func request<T>(_ endpoint: APIEndpoint) async throws -> T where T : Decodable {
        switch requestResult {
        case .success(let value):
            guard let decoded = value as? T else {
                throw NSError(domain: "Mock", code: 1, userInfo: [NSLocalizedDescriptionKey: "Type mismatch in mock response"])
            }
            return decoded
        case .failure(let error):
            throw error
        }
    }

    func requestData(_ endpoint: APIEndpoint) async throws -> Data {
        throw NSError(domain: "Mock", code: 2, userInfo: nil)
    }

    func setEnvironment(_ environment: APIEnvironment) {
        // No-op for mock
    }
}

final class JobServiceTests: XCTestCase {

    func testFetchJobsReturnsEmptyArrayWhenResponseIsNil() async throws {
        // Arrange
        let mockClient = MockNetworkClient()
        let json = "{\"jobs\":null}"
        let data = Data(json.utf8)
        let response = try JSONDecoder().decode(JobsResponse.self, from: data)
        mockClient.requestResult = .success(response)
        let service = JobService(networkClient: mockClient)

        // Act
        let result = try await service.fetchJobs()

        // Assert
        XCTAssertTrue(result.isEmpty)
    }

    func testFetchJobsThrowsWhenNetworkError() async {
        // Arrange
        let mockClient = MockNetworkClient()
        mockClient.requestResult = .failure(NSError(domain: "Network", code: -1009, userInfo: nil))
        let service = JobService(networkClient: mockClient)

        // Act & Assert
        do {
            _ = try await service.fetchJobs()
            XCTFail("Expected fetchJobs to throw, but it succeeded")
        } catch {
            XCTAssertTrue((error as NSError).domain.contains("Network"))
        }
    }
    
    func getSearchMockData() -> [Jobs] {
        return [
            Jobs(id: "1",
                 company_id: "c1",
                 title: "Dev",
                 slug: "dev",
                 description: "desc",
                 salary_min: 50,
                 salary_max: 100,
                 location: "X",
                 workplace: "Remote",
                 job_type: "FullTime",
                 experience_level: "Junior",
                 tags: ["Swift"],
                 apply_url: "http://apply",
                 is_featured: true,
                 is_sticky: false,
                 status: "open",
                 published_at: "2026-01-01",
                 expires_at: "2026-12-31",
                 created_at: "2026-01-01",
                 updated_at: "2026-01-02",
                 company_name: "A",
                 company_slug: "a",
                 company_logo_url: "http://logo",
                 quality_score: 5,
                 url: "http://job"),
            Jobs(id: "2",
                 company_id: "c2",
                 title: "Designer",
                 slug: "designer",
                 description: "desc",
                 salary_min: 60,
                 salary_max: 120,
                 location: "Y",
                 workplace: "Remote",
                 job_type: "FullTime",
                 experience_level: "Mid",
                 tags: ["UI"],
                 apply_url: "http://apply2",
                 is_featured: false,
                 is_sticky: false,
                 status: "open",
                 published_at: "2026-01-01",
                 expires_at: "2026-12-31",
                 created_at: "2026-01-01",
                 updated_at: "2026-01-02",
                 company_name: "B",
                 company_slug: "b",
                 company_logo_url: "http://logo2",
                 quality_score: 4,
                 url: "http://job2")
        ]
    }
}
