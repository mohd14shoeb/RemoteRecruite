
//
//  JobListViewModel.swift
//  RemoteRecruit
//
//  Created by Shoeb Khan on 08/06/26.
//

import Foundation
import Combine

// Represents the possible states of the Jobs list screen.
enum JobListViewState: Equatable {
    case loading
    case empty
    case loaded([Jobs])
    case error(AppError)
}

// ViewModel for the Jobs listing screen.

final class JobListViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published private(set) var state: JobListViewState = .loading
    @Published var searchText: String = "" {
        didSet {
            searchTask?.cancel()
            searchTask = Task { [weak self] in
                try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
                await self?.performSearch()
            }
        }
    }
    
    // MARK: - Private Properties
    private let jobService: JobServiceProtocol
    private var allJobs: [Jobs] = []
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Initialization

    init(jobService: JobServiceProtocol = DependencyContainer.shared.jobService) {
        self.jobService = jobService
    }
    
    deinit {
        searchTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// Fetches the initial list of jobs.
    func fetchJobs() async {
        state = .loading
        do {
            let jobs = try await jobService.fetchJobs()
            allJobs = jobs
            if jobs.isEmpty {
                state = .empty
            } else {
                state = .loaded(jobs)
            }
        } catch {
            state = .error(.unknown(error.localizedDescription))
        }
    }
    
    /// Refreshes the Jobs list (pull-to-refresh).
    func refresh() async {
        await fetchJobs()
    }
    
    // MARK: - Private Methods

        private func performSearch() async {
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

            if query.isEmpty {
                state = allJobs.isEmpty ? .empty : .loaded(allJobs)
                return
            }

            state = .loading
            do {
            // Perform local search on cached jobs
            let results = allJobs.filter { job in
                job.titleJob.localizedCaseInsensitiveContains(query) ||
                job.company.localizedCaseInsensitiveContains(query)
            }
            state = results.isEmpty ? .empty : .loaded(results)
            } catch {
                state = .error(.unknown(error.localizedDescription))
            }
        }
    
}

