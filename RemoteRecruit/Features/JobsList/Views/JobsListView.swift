//
//  JobListView.swift
//  RemoteRecruit
//
//  Created by Shoeb Khan on 08/06/26.
//


import SwiftUI

struct JobsListView: View {

    @StateObject private var viewModel: JobListViewModel

    init(viewModel: JobListViewModel = JobListViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                // Search field
                HStack {
                    TextField("Search by title or company", text: $viewModel.searchText)
                        .textFieldStyle(.roundedBorder)
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                // Content based on state
                switch viewModel.state {
                case .loading:
                    loadingView
                case .empty:
                    emptyView
                case .loaded(let jobs):
                    jobList(jobs)
                case .error(let error):
                    errorView(error)
                }
            }
            .navigationTitle("Remote Jobs")
            .navigationBarTitleDisplayMode(.inline)
            // Remove searchable modifier; use custom TextField below title
            .task {
                await viewModel.fetchJobs()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading jobs...")
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "briefcase.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text(viewModel.searchText.isEmpty ? "No Jobs Available" : "No Results Found")
                .font(.title2)
                .fontWeight(.semibold)

            Text(viewModel.searchText.isEmpty
                 ? "Check back later for new opportunities."
                 : "Try adjusting your search terms.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Jobs List
    private func jobList(_ jobs: [Jobs]) -> some View {
        List(jobs) { jobs in
                NavigationLink(destination: JobDetailView(job: jobs)) {
                JobsRowView(jobs: jobs)
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Error View
    private func errorView(_ error: AppError) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("Something Went Wrong")
                .font(.title2)
                .fontWeight(.semibold)

            Text(error.errorDescription ?? "An unexpected error occurred.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                Task { await viewModel.fetchJobs() }
            } label: {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Jobs Row View
struct JobsRowView: View {
    let jobs: Jobs

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(jobs.titleJob)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(nil) // allow multiline
                .fixedSize(horizontal: false, vertical: true)

            Text(jobs.company)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Label(jobs.company_location, systemImage: "mappin.circle")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Label(String(jobs.salaryRange), systemImage: "dollarsign.circle")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
//#Preview {
//    JobListView(viewModel: .preview)
//}
