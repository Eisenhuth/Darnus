import Foundation

struct NaelQuotes: Codable, Equatable{
    var Quotes: [Quote]
}

struct Quote: Codable, Equatable{
    var ID: Int
    var Text: Text
}

struct Text: Codable, Equatable{
    var Text_de: String
    var Text_en: String
    var Text_fr: String
    var Text_ja: String
    var Text_chs: String?
}
