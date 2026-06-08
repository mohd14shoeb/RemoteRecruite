
import Foundation

struct Jobs : Identifiable, Codable, Equatable {
	let id : String?
	let company_id : String?
	let title : String?
	let slug : String?
	let description : String?
	let salary_min : Int?
	let salary_max : Int?
	let location : String?
	let workplace : String?
	let job_type : String?
	let experience_level : String?
	let tags : [String]?
	let apply_url : String?
	let is_featured : Bool?
	let is_sticky : Bool?
	let status : String?
	let published_at : String?
	let expires_at : String?
	let created_at : String?
	let updated_at : String?
	let company_name : String?
	let company_slug : String?
	let company_logo_url : String?
	let quality_score : Int?
	let url : String?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case company_id = "company_id"
		case title = "title"
		case slug = "slug"
		case description = "description"
		case salary_min = "salary_min"
		case salary_max = "salary_max"
		case location = "location"
		case workplace = "workplace"
		case job_type = "job_type"
		case experience_level = "experience_level"
		case tags = "tags"
		case apply_url = "apply_url"
		case is_featured = "is_featured"
		case is_sticky = "is_sticky"
		case status = "status"
		case published_at = "published_at"
		case expires_at = "expires_at"
		case created_at = "created_at"
		case updated_at = "updated_at"
		case company_name = "company_name"
		case company_slug = "company_slug"
		case company_logo_url = "company_logo_url"
		case quality_score = "quality_score"
		case url = "url"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		company_id = try values.decodeIfPresent(String.self, forKey: .company_id)
		title = try values.decodeIfPresent(String.self, forKey: .title)
		slug = try values.decodeIfPresent(String.self, forKey: .slug)
		description = try values.decodeIfPresent(String.self, forKey: .description)
		salary_min = try values.decodeIfPresent(Int.self, forKey: .salary_min)
		salary_max = try values.decodeIfPresent(Int.self, forKey: .salary_max)
		location = try values.decodeIfPresent(String.self, forKey: .location)
		workplace = try values.decodeIfPresent(String.self, forKey: .workplace)
		job_type = try values.decodeIfPresent(String.self, forKey: .job_type)
		experience_level = try values.decodeIfPresent(String.self, forKey: .experience_level)
		tags = try values.decodeIfPresent([String].self, forKey: .tags)
		apply_url = try values.decodeIfPresent(String.self, forKey: .apply_url)
		is_featured = try values.decodeIfPresent(Bool.self, forKey: .is_featured)
		is_sticky = try values.decodeIfPresent(Bool.self, forKey: .is_sticky)
		status = try values.decodeIfPresent(String.self, forKey: .status)
		published_at = try values.decodeIfPresent(String.self, forKey: .published_at)
		expires_at = try values.decodeIfPresent(String.self, forKey: .expires_at)
		created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
		updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
		company_name = try values.decodeIfPresent(String.self, forKey: .company_name)
		company_slug = try values.decodeIfPresent(String.self, forKey: .company_slug)
		company_logo_url = try values.decodeIfPresent(String.self, forKey: .company_logo_url)
		quality_score = try values.decodeIfPresent(Int.self, forKey: .quality_score)
		url = try values.decodeIfPresent(String.self, forKey: .url)
	}
    
    var titleJob : String {
        return self.title ?? ""
    }
    var company : String {
        return self.company_name ?? ""
    }
    var company_location : String {
        return self.location ?? ""
    }
    var salaryRange : Int {
        return self.salary_max ?? 0
    }
    var descriptionJob : String {
        return self.description ?? ""
    }
    
}

// MARK: - Test Convenience Initializer
extension Jobs {
    init(id: String?,
         company_id: String?,
         title: String?,
         slug: String?,
         description: String?,
         salary_min: Int?,
         salary_max: Int?,
         location: String?,
         workplace: String?,
         job_type: String?,
         experience_level: String?,
         tags: [String]?,
         apply_url: String?,
         is_featured: Bool?,
         is_sticky: Bool?,
         status: String?,
         published_at: String?,
         expires_at: String?,
         created_at: String?,
         updated_at: String?,
         company_name: String?,
         company_slug: String?,
         company_logo_url: String?,
         quality_score: Int?,
         url: String?) {
        self.id = id
        self.company_id = company_id
        self.title = title
        self.slug = slug
        self.description = description
        self.salary_min = salary_min
        self.salary_max = salary_max
        self.location = location
        self.workplace = workplace
        self.job_type = job_type
        self.experience_level = experience_level
        self.tags = tags
        self.apply_url = apply_url
        self.is_featured = is_featured
        self.is_sticky = is_sticky
        self.status = status
        self.published_at = published_at
        self.expires_at = expires_at
        self.created_at = created_at
        self.updated_at = updated_at
        self.company_name = company_name
        self.company_slug = company_slug
        self.company_logo_url = company_logo_url
        self.quality_score = quality_score
        self.url = url
    }
}
