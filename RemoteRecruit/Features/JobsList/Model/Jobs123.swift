//
//  Jobs.swift
//  RemoteRecruit
//
//  Created by Shoeb Khan on 08/06/26.
//

import Foundation

struct Jobs123: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let companyName: String
    let location: String
    let salaryRange: String
    let description: String
    let companyInfo: String?
    let employmentType: String?
    let postedDate: String?
    let requirements: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case companyName = "company_name"
        case location
        case salaryRange = "salary_range"
        case description
        case companyInfo = "company_info"
        case employmentType = "employment_type"
        case postedDate = "posted_date"
        case requirements
    }
}

// MARK: - Sample Data
extension Jobs123 {
    static let sample = Jobs123(
        id: "1",
        title: "Senior iOS Developer",
        companyName: "TechCorp",
        location: "San Francisco, CA",
        salaryRange: "$130,000 - $180,000",
        description: "We are looking for a Senior iOS Developer to join our mobile team. You will be responsible for building and maintaining high-quality iOS applications using Swift and SwiftUI.",
        companyInfo: "TechCorp is a leading technology company specializing in mobile-first solutions. Founded in 2015, we have grown to serve over 2 million users worldwide.",
        employmentType: "Full-time",
        postedDate: "2026-05-28",
        requirements: ["5+ years iOS experience", "Swift, SwiftUI, Combine", "Experience with MVVM architecture", "Knowledge of Core Data"]
    )

    static let sampleList: [Jobs123] = [
        Jobs123(id: "1", title: "Senior iOS Developer", companyName: "TechCorp", location: "San Francisco, CA", salaryRange: "$130,000 - $180,000", description: "We are looking for a Senior iOS Developer to join our mobile team.", companyInfo: "TechCorp is a leading technology company.", employmentType: "Full-time", postedDate: "2026-05-28", requirements: nil),
        Jobs123(id: "2", title: "Junior iOS Developer", companyName: "StartupX", location: "New York, NY", salaryRange: "$70,000 - $95,000", description: "Join our fast-growing startup and help build the next generation of social apps.", companyInfo: "StartupX is a YC-backed company.", employmentType: "Full-time", postedDate: "2026-06-01", requirements: nil),
        Jobs123(id: "3", title: "iOS Team Lead", companyName: "FinTech Pro", location: "Austin, TX", salaryRange: "$160,000 - $220,000", description: "Lead our iOS team in building the most secure banking app.", companyInfo: "FinTech Pro is a leader in digital banking.", employmentType: "Full-time", postedDate: "2026-05-25", requirements: nil),
        Jobs123(id: "4", title: "React Native Engineer", companyName: "CrossPlatform Inc", location: "Remote", salaryRange: "$100,000 - $140,000", description: "Work on cross-platform mobile apps using React Native.", companyInfo: "CrossPlatform Inc specializes in hybrid mobile solutions.", employmentType: "Contract", postedDate: "2026-05-30", requirements: nil),
        Jobs123(id: "5", title: "Mobile QA Engineer", companyName: "QualityFirst", location: "Chicago, IL", salaryRange: "$85,000 - $110,000", description: "Ensure the quality of our mobile applications through manual and automated testing.", companyInfo: "QualityFirst is a QA consultancy.", employmentType: "Full-time", postedDate: "2026-06-02", requirements: nil),
        Jobs123(id: "6", title: "Android Developer", companyName: "TechCorp", location: "San Francisco, CA", salaryRange: "$120,000 - $170,000", description: "Build world-class Android applications.", companyInfo: "TechCorp is a leading technology company.", employmentType: "Full-time", postedDate: "2026-05-20", requirements: nil),
        Jobs123(id: "7", title: "Flutter Developer", companyName: "DesignStudio", location: "Los Angeles, CA", salaryRange: "$90,000 - $130,000", description: "Build beautiful cross-platform apps with Flutter.", companyInfo: "DesignStudio is a creative tech agency.", employmentType: "Full-time", postedDate: "2026-06-03", requirements: nil),
        Jobs123(id: "8", title: "iOS Engineer - SwiftUI", companyName: "AppleWorks", location: "Cupertino, CA", salaryRange: "$150,000 - $200,000", description: "Work on cutting-edge SwiftUI features for millions of users.", companyInfo: "AppleWorks is a premium iOS development company.", employmentType: "Full-time", postedDate: "2026-05-15", requirements: nil),
    ]
}
