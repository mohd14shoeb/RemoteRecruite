//
//  JobDetailView.swift
//  RemoteRecruit
//
//  Created by Shoeb Khan on 08/06/26.
//

import SwiftUI

struct JobDetailView: View {
    let job: Jobs

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(job.titleJob)
                    .font(.title)
                    .fontWeight(.bold)
                Text(job.company)
                    .font(.headline)
                    .foregroundColor(.secondary)
                HStack {
                    Label(job.company_location, systemImage: "mappin.circle")
                    Spacer()
                    Label(String(job.salaryRange), systemImage: "dollarsign.circle")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                Divider()
                Text("Job Description")
                    .font(.headline)
                Text(job.descriptionJob)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle(job.company)
        .navigationBarTitleDisplayMode(.inline)
    }
}
