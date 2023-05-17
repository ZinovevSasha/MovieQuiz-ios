import Foundation

/*
struct MostPopularMoviesResult: Codable {
    let items: [OneMovieResult?]
    let errorMessage: String?
    struct OneMovieResult: Codable {
        let title: String?
        let image: URL?
        let imDbRating: String?
    }
}
*/

struct MostPopularMoviesResult: Codable {
    let items: [OneMovieResult?]
    let errorMessage: String?
    struct OneMovieResult: Codable {
        let title: String?
        let image: URL?
        let imDbRating: String?

        enum CodingKeys: String, CodingKey {
            case title = "Title"
            case image = "Images"
            case imDbRating
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            title = try values.decodeIfPresent(String.self, forKey: .title)
            imDbRating = try values.decodeIfPresent(String.self, forKey: .imDbRating)
            if let images = try values.decodeIfPresent([String].self, forKey: .image),
                let firstImage = images.first,
                let url = URL(string: firstImage) {
                image = url
            } else {
                image = nil
            }
        }
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.singleValueContainer()
        items = try values.decode([OneMovieResult?].self)
        errorMessage = nil
    }
}
