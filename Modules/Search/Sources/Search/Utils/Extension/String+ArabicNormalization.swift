//
//  String+ArabicNormalization.swift
//  Mushaf
//

import Foundation

extension String {
    func normalizedArabic() -> String {
        let diacritics = CharacterSet(charactersIn:
            "\u{0610}\u{0611}\u{0612}\u{0613}\u{0614}\u{0615}\u{0616}\u{0617}\u{0618}\u{0619}\u{061A}" +
            "\u{064B}\u{064C}\u{064D}\u{064E}\u{064F}\u{0650}\u{0651}\u{0652}\u{0653}\u{0654}\u{0655}\u{0656}\u{0657}\u{0658}\u{0659}\u{065A}\u{065B}\u{065C}\u{065D}\u{065E}\u{065F}" +
            "\u{0670}" +
            "\u{06D6}\u{06D7}\u{06D8}\u{06D9}\u{06DA}\u{06DB}\u{06DC}" +
            "\u{06DF}\u{06E0}\u{06E1}\u{06E2}\u{06E3}\u{06E4}\u{06E5}\u{06E6}\u{06E7}\u{06E8}" +
            "\u{06EA}\u{06EB}\u{06EC}\u{06ED}" +
            "\u{0640}"
        )

        var result = self.unicodeScalars
            .filter { !diacritics.contains($0) }
            .map(Character.init)
            .reduce(into: "") { $0.append($1) }

        for alef in ["\u{0622}", "\u{0623}", "\u{0625}"] {
            result = result.replacingOccurrences(of: alef, with: "\u{0627}")
        }
        result = result.replacingOccurrences(of: "\u{0629}", with: "\u{0647}")
        result = result.replacingOccurrences(of: "\u{0649}", with: "\u{064A}")
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
