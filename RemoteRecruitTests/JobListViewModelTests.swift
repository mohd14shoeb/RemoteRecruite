import XCTest
@testable import RemoteRecruit

// Mock service that returns predefined jobs
class MockJobService: JobServiceProtocol {
    
    
    var jobs: [Jobs] = []
    var shouldFail = false
    func fetchJobs() async throws -> [Jobs] { if shouldFail { throw AppError.unknown("error") } else { return jobs } }
    func searchJobs(query: String) async throws -> [Jobs] { return jobs.filter { $0.titleJob.contains(query) || $0.company.contains(query) } }
}

final class JobListViewModelTests: XCTestCase {
    var viewModel: JobListViewModel!
    var mockService: MockJobService!

    override func setUp() {
        super.setUp()
        mockService = MockJobService()
        viewModel = JobListViewModel(jobService: mockService)
    }
    
    override func tearDown() {
        mockService.jobs = []
        super.tearDown()
    }

    
    @MainActor
    func testFetchJobsEmpty() async {
        mockService.jobs = []
        await viewModel.fetchJobs()
        XCTAssertEqual(viewModel.state, .empty)
    }
    
    @MainActor
    func testFetchJobsSuccess() async {
        mockService.jobs = getFetchAPIMockData()
        await viewModel.fetchJobs()
        XCTAssertEqual(viewModel.state, .loaded(mockService.jobs))
    }

    @MainActor
    func testSearchResults() async {
        mockService.jobs = getSearchMockData()
        viewModel.searchText = "Dev"
    
        try? await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertEqual(viewModel.state, .loaded([mockService.jobs[0]]))
    }
    
    func getFetchAPIMockData() -> [Jobs] {
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
                 url: "http://job")
        ]
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
