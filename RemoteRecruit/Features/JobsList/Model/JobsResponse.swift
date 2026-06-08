
import Foundation

struct JobsResponse : Codable {
	let has_next : Bool?
	let jobs : [Jobs]?
	let page : Int?
	let per_page : Int?
	let total : Int?
	let total_pages : Int?

	enum CodingKeys: String, CodingKey {

		case has_next = "has_next"
		case jobs = "jobs"
		case page = "page"
		case per_page = "per_page"
		case total = "total"
		case total_pages = "total_pages"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		has_next = try values.decodeIfPresent(Bool.self, forKey: .has_next)
		jobs = try values.decodeIfPresent([Jobs].self, forKey: .jobs)
		page = try values.decodeIfPresent(Int.self, forKey: .page)
		per_page = try values.decodeIfPresent(Int.self, forKey: .per_page)
		total = try values.decodeIfPresent(Int.self, forKey: .total)
		total_pages = try values.decodeIfPresent(Int.self, forKey: .total_pages)
	}

}

extension JobsResponse {

    init(jobs: [Jobs]?) {
        self.has_next = nil
        self.jobs = jobs
        self.page = nil
        self.per_page = nil
        self.total = nil
        self.total_pages = nil
    }
}

