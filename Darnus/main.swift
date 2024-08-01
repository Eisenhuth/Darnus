import Foundation
import YASU
import xivapi_swift

let quoteIds = [
    6492,
    6493,
    6494,
    6495,
    6496,
    6497,
    6500,
    6501,
    6502,
    6503,
    6504,
    6505,
    6506,
    6507
]
let cnApi = "https://cafemaker.wakingsands.com/NpcYell/"
let referenceUrl = URL(string: "https://raw.githubusercontent.com/Eisenhuth/dalamud-nael/master/nael/nael/NaelQuotes.json")

var generatedQuotesArray = [Quote]()

print("-- generating quotes --")

for quoteId in quoteIds{
    
    let chsApiUrl = URL(string: cnApi+String(quoteId))!
    
    if let xivQuote = await xivapiClient().getNpcYell(quoteId, languages: [.en, .ja, .de, .fr]){
        
        let chsQuote:ApiQuote? = await YASU.loadData(chsApiUrl)
        
        //fixing french, I guess?
        var frenchText = xivQuote.Text_fr
        frenchText = frenchText?.replacingOccurrences(of: "!", with: " !")
        frenchText = frenchText?.replacingOccurrences(of: "  ", with: " ")
        
        let quoteText = Text(Text_de: xivQuote.Text_de!, Text_en: xivQuote.Text, Text_fr: frenchText!, Text_ja: xivQuote.Text_ja!, Text_chs: chsQuote?.Text_chs ?? "")
        let quote = Quote(ID: quoteId, Text: quoteText)
        
        
        generatedQuotesArray.append(quote)
        
        print("generated quote \(quoteId) - DE \(!quote.Text.Text_de.isEmpty) - EN \(!quote.Text.Text_en.isEmpty) - FR \(!quote.Text.Text_fr.isEmpty) - JP \(!quote.Text.Text_ja.isEmpty) - CN \(!((quote.Text.Text_chs?.isEmpty) == nil))")
        
    } else {
        print("error adding \(quoteId)")
    }
}

let generatedQuotes = NaelQuotes(Quotes: generatedQuotesArray)

print("-- generated quotes: \(generatedQuotes.Quotes.count) --")
print(" ")
print("-- comparing against reference quotes in github.com/Eisenhuth/dalamud-nael --")
if let referenceQuotes: NaelQuotes = await YASU.loadData(referenceUrl!) {
    print("comparing generated quotes against reference quotes\n")
    
    for quoteId in quoteIds {
        let genQuote = generatedQuotes.Quotes.first { $0.ID == quoteId }
        let refQuote = referenceQuotes.Quotes.first { $0.ID == quoteId }
        let same = genQuote?.Text == refQuote?.Text
        print("quote \(quoteId) \(same ? "matches" : "doesn't match")")
    }
    
    print("all quotes match: \(generatedQuotes == referenceQuotes)")
} else {
    print("failed to load reference quotes")
}

let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
if let url = urls.first {
    var fileURL = url.appendingPathComponent("NaelQuotes")
    fileURL = fileURL.appendingPathExtension("json")
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    try encoder.encode(generatedQuotes).write(to: fileURL, options: [.atomic])
    print("saved quotes at \(fileURL)")
}
