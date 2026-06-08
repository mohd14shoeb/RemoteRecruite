//
//  JobService.swift
//  RemoteRecruit
//
//  Created by Shoeb Khan on 08/06/26.
//

import Foundation


protocol JobServiceProtocol {
    func fetchJobs() async throws -> [Jobs]
}

/// Production service that fetches jobs from a remote API.
    
final class JobService: JobServiceProtocol {
    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }

    func fetchJobs() async throws -> [Jobs] {

        let response: JobsResponse = try await networkClient.request(.jobs)
        return response.jobs ?? []
    }
}
