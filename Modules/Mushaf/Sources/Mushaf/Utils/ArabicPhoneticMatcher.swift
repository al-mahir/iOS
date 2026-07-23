//
//  ArabicPhoneticMatcher.swift
//  Mushaf
//
//  Created by Alaa Ayman on 22/07/2026.
//

import Foundation

class ArabicPhoneticMatcher {
    
    // MARK: - Arabic Character Normalization
    private static let normalizationMap: [String: String] = [
        // Hamza variations
        "إ": "ا", "أ": "ا", "آ": "ا", "ء": "",
        // Taa marbuta
        "ة": "ه",
        // Alif maqsura
        "ى": "ي",
        // Other variations
        "ئ": "ي", "ؤ": "و",
        // Tatweel
        "ـ": "",
        // Diacritics (Fatha, Kasra, Damma, etc.)
        "َ": "", "ُ": "", "ِ": "", "ْ": "", "ً": "", "ٌ": "", "ٍ": "",
        "ّ": "", // Shadda
        "ٰ": "", // Alif khanjareeya
        "ۖ": "", "ۗ": "", "ۘ": "", "ۙ": "", "ۚ": "", "ۛ": "", "ۜ": "",
        "۞": "", "۩": "",
        // Special Quranic signs
        "ﷲ": "الله", // Ligature Allah
        "ﷻ": "الله", // Ligature Jallajala
    ]
    
    // MARK: - Phonetic Similarity Groups (Arabic letters that sound similar)
    private static let phoneticGroups: [[String]] = [
        ["ح", "ه", "خ"],
        ["س", "ص", "ث"],
        ["ط", "ت", "د"],
        ["ظ", "ز", "ذ", "ض"],
        ["ع", "أ", "ا", "ء", "غ"],
        ["ق", "ك"],
        ["ف", "ب", "م"],
        ["ر", "ز"],
        ["ي", "ئ", "ى"],
        ["و", "ؤ"],
        ["ل", "ن"],
    ]
    
    // Create a map for quick lookup
    private static let phoneticMap: [Character: Set<Character>] = {
        var map = [Character: Set<Character>]()
        for group in phoneticGroups {
            for char in group {
                let charSet = Set(group.compactMap { $0.first })
                map[char.first!] = charSet
            }
        }
        return map
    }()
    
    // MARK: - Common Misrecognitions Dictionary (covers common Quran words)
    // This can be expanded based on actual user data
    private static let commonMisrecognitions: [String: Set<String>] = [
        // Quranic common words
        "بسم": ["بسم", "بسمل", "بسم الله", "باسم", "بسام", "بس"],
        "الله": ["الله", "اللة", "اللهم", "اللاه", "اللهـ"],
        "الرحمن": ["الرحمن", "الرحمان", "الرحمٰن", "الرحم"],
        "الرحيم": ["الرحيم", "الرحیم", "الرحمي"],
        "الحمد": ["الحمد", "الحمدلله", "الحمد الله", "المد"],
        "رب": ["رب", "ربب", "راب"],
        "العالمين": ["العالمين", "العالم", "العلمين"],
        "مالك": ["مالك", "ملك"],
        "يوم": ["يوم"],
        "الدين": ["الدين", "الدین"],
        "إياك": ["إياك", "اياك", "أياك"],
        "نعبد": ["نعبد", "نعبذ"],
        "نستعين": ["نستعين", "نستعین"],
        "اهدنا": ["اهدنا", "اهدناء", "هدنا"],
        "الصراط": ["الصراط", "السراط"],
        "المستقيم": ["المستقيم", "المستقیم"],
        "أنعمت": ["أنعمت", "انعمت"],
        "عليهم": ["عليهم"],
        "غير": ["غير", "غیر"],
        "المغضوب": ["المغضوب"],
        "الضالين": ["الضالين", "الضالین", "الضال"],
        "قل": ["قل", "قال", "قول"],
        "هو": ["هو"],
        "الذي": ["الذي", "الذی", "الذى", "الذن"],
        "الذين": ["الذين", "الذین"],
        "إن": ["إن", "ان"],
        "ما": ["ما"],
        "من": ["من"],
        "في": ["في"],
        "إلى": ["إلى", "الى", "الي"],
        "على": ["على", "علی", "علي"],
        "ب": ["ب"],
        "و": ["و"],
        "ف": ["ف"],
        "ل": ["ل"],
        "ك": ["ك"],
        "قد": ["قد"],
        "لا": ["لا"],
        "ن": ["ن"],
        "س": ["س"],
        "سوف": ["سوف"],
    ]
    
    // MARK: - Main Matching Functions
    
    /// Normalize Arabic text for comparison
    static func normalizeArabic(_ text: String) -> String {
        var normalized = text
        
        // Apply all normalization rules
        for (key, value) in normalizationMap {
            normalized = normalized.replacingOccurrences(of: key, with: value)
        }
        
        // Remove extra spaces
        normalized = normalized.trimmingCharacters(in: .whitespacesAndNewlines)
        normalized = normalized.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        return normalized
    }
    
    /// Check if two words match phonetically
    static func isPhoneticMatch(_ spoken: String, _ expected: String) -> Bool {
        // Normalize both strings
        let normalizedSpoken = normalizeArabic(spoken)
        let normalizedExpected = normalizeArabic(expected)
        
        // 1. EXACT MATCH
        if normalizedSpoken == normalizedExpected {
            return true
        }
        
        // 2. COMMON MISRECOGNITIONS
        if let variations = commonMisrecognitions[normalizedExpected] {
            if variations.contains(where: { $0 == normalizedSpoken }) {
                return true
            }
        }
        
        // Also check reverse (if spoken text is in the variations map)
        for (key, variations) in commonMisrecognitions {
            if variations.contains(normalizedSpoken) && key == normalizedExpected {
                return true
            }
        }
        
        // 3. PREFIX/SUFFIX HANDLING
        // Common Arabic prefixes
        let prefixes = ["ال", "و", "ف", "ب", "ل", "ك", "س", "سوف", "حتى", "على", "من", "إلى"]
        // Common Arabic suffixes
        let suffixes = ["ه", "هم", "ها", "كم", "كن", "نا", "ي", "ك", "ا", "ون", "ين", "ات"]
        
        // Check if removing a common prefix makes it match
        for prefix in prefixes {
            if normalizedSpoken.hasPrefix(prefix) {
                let withoutPrefix = String(normalizedSpoken.dropFirst(prefix.count))
                if !withoutPrefix.isEmpty {
                    // Check if without prefix matches expected
                    if withoutPrefix == normalizedExpected {
                        return true
                    }
                    // Or if it matches with phonetic group substitution
                    if isPhoneticGroupMatch(withoutPrefix, normalizedExpected) {
                        return true
                    }
                }
            }
        }
        
        // Check if removing a common suffix makes it match
        for suffix in suffixes {
            if normalizedSpoken.hasSuffix(suffix) {
                let withoutSuffix = String(normalizedSpoken.dropLast(suffix.count))
                if !withoutSuffix.isEmpty {
                    if withoutSuffix == normalizedExpected {
                        return true
                    }
                    if isPhoneticGroupMatch(withoutSuffix, normalizedExpected) {
                        return true
                    }
                }
            }
        }
        
        // 4. PHONETIC GROUP SUBSTITUTION
        if isPhoneticGroupMatch(normalizedSpoken, normalizedExpected) {
            return true
        }
        
        // 5. PARTIAL WORD MATCH (user spoke part of the word)
        // For words like "بسم", user might say "بس"
        if normalizedExpected.hasPrefix(normalizedSpoken) && normalizedSpoken.count >= 2 {
            return true
        }
        // Or they might say the word with extra letters
        if normalizedSpoken.hasPrefix(normalizedExpected) && normalizedExpected.count >= 2 {
            return true
        }
        
        // 6. LEVENSHTEIN DISTANCE (fuzzy matching)
        let distance = levenshteinDistance(normalizedSpoken, normalizedExpected)
        let maxDistance = max(1, normalizedExpected.count / 3) // Allow up to 33% difference
        if distance <= maxDistance {
            return true
        }
        
        // 7. SOUNDEX-LIKE MATCHING (for very similar sounding words)
        if isSoundexMatch(normalizedSpoken, normalizedExpected) {
            return true
        }
        
        return false
    }
    
    // MARK: - Helper Methods
    
    /// Check if two strings match after phonetic group substitution
    private static func isPhoneticGroupMatch(_ a: String, _ b: String) -> Bool {
        let charsA = Array(a)
        let charsB = Array(b)
        
        guard charsA.count == charsB.count else {
            // Try with padding (some letters might be skipped)
            return isPhoneticGroupMatchWithPadding(a, b)
        }
        
        for i in 0..<charsA.count {
            let charA = charsA[i]
            let charB = charsB[i]
            
            // If characters are different, check if they're in the same phonetic group
            if charA != charB {
                if let groupA = phoneticMap[charA],
                   let groupB = phoneticMap[charB] {
                    // Check if they share a group (any intersection)
                    if groupA.intersection(groupB).isEmpty {
                        // Also check if the groups are closely related
                        if !arePhoneticallyClose(charA, charB) {
                            return false
                        }
                    }
                } else {
                    return false
                }
            }
        }
        
        return true
    }
    
    /// Check phonetic group match with padding (some letters may be skipped)
    private static func isPhoneticGroupMatchWithPadding(_ a: String, _ b: String) -> Bool {
        let charsA = Array(a)
        let charsB = Array(b)
        
        // Try to match with skipping up to 2 characters
        let maxSkip = 2
        for skipA in 0...maxSkip {
            for skipB in 0...maxSkip {
                if skipA == 0 && skipB == 0 { continue }
                
                var i = 0, j = 0
                var matched = true
                
                while i < charsA.count && j < charsB.count {
                    let charA = charsA[i]
                    let charB = charsB[j]
                    
                    if charA != charB {
                        if let groupA = phoneticMap[charA],
                           let groupB = phoneticMap[charB] {
                            if groupA.intersection(groupB).isEmpty && !arePhoneticallyClose(charA, charB) {
                                // Try skipping a character
                                if skipA > 0 && i + 1 < charsA.count {
                                    i += 1
                                    continue
                                } else if skipB > 0 && j + 1 < charsB.count {
                                    j += 1
                                    continue
                                } else {
                                    matched = false
                                    break
                                }
                            }
                        } else {
                            matched = false
                            break
                        }
                    }
                    
                    i += 1
                    j += 1
                }
                
                if matched {
                    return true
                }
            }
        }
        
        return false
    }
    
    /// Check if two characters are phonetically close
    private static func arePhoneticallyClose(_ a: Character, _ b: Character) -> Bool {
        let aStr = String(a)
        let bStr = String(b)
        
        // Check common misrecognitions for specific characters
        let pairs = [
            ("ح", "ه"), ("س", "ص"), ("س", "ث"),
            ("ط", "ت"), ("ط", "د"), ("ظ", "ز"),
            ("ظ", "ذ"), ("ظ", "ض"), ("ع", "ا"),
            ("ع", "أ"), ("ع", "ء"), ("ق", "ك"),
            ("ف", "ب"), ("ف", "م"), ("ر", "ز"),
            ("ي", "ئ"), ("ي", "ى"), ("و", "ؤ"),
            ("ل", "ن"),
        ]
        
        for (first, second) in pairs {
            if (aStr == first && bStr == second) || (aStr == second && bStr == first) {
                return true
            }
        }
        
        return false
    }
    
    /// Soundex-like matching for Arabic
    private static func isSoundexMatch(_ a: String, _ b: String) -> Bool {
        let soundexA = arabicSoundex(a)
        let soundexB = arabicSoundex(b)
        return soundexA == soundexB && !soundexA.isEmpty && !soundexB.isEmpty
    }
    
    /// Arabic Soundex implementation
    /// Arabic Soundex implementation
    private static func arabicSoundex(_ text: String) -> String {
        // Arabic soundex mapping (simplified)
        let mapping: [Character: Character] = [
            // Group 1: ح ه خ
            "ح": "1", "ه": "1", "خ": "1",
            // Group 2: س ص ث
            "س": "2", "ص": "2", "ث": "2",
            // Group 3: ط ت د
            "ط": "3", "ت": "3", "د": "3",
            // Group 4: ظ ذ ض
            "ظ": "4", "ذ": "4", "ض": "4",
            // Group 5: ع ا أ ء غ
            "ع": "5", "ا": "5", "أ": "5", "ء": "5", "غ": "5",
            // Group 6: ق ك
            "ق": "6", "ك": "6",
            // Group 7: ف ب م
            "ف": "7", "ب": "7", "م": "7",
            // Group 8: ر ز
            "ر": "8", "ز": "8",
            // Group 9: ي ئ ى
            "ي": "9", "ئ": "9", "ى": "9",
            // Group 0: و ؤ ل ن
            "و": "0", "ؤ": "0", "ل": "0", "ن": "0",
        ]
        
        let chars = Array(text)
        guard !chars.isEmpty else { return "" }
        
        // Keep first letter
        let firstChar = String(chars[0])
        var result = firstChar
        
        // Map remaining letters
        var lastCode: Character? = nil
        for char in chars.dropFirst() {
            if let code = mapping[char] {
                if code != lastCode {
                    result.append(code)
                    lastCode = code
                }
            } else {
                lastCode = nil
            }
        }
        
        // Pad or truncate to length 4
        if result.count > 4 {
            result = String(result.prefix(4))
        } else {
            result = result.padding(toLength: 4, withPad: "0", startingAt: 0)
        }
        
        return result
    }
    
    /// Levenshtein distance algorithm
    static func levenshteinDistance(_ a: String, _ b: String) -> Int {
        let a = Array(a)
        let b = Array(b)
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: b.count + 1), count: a.count + 1)
        
        for i in 0...a.count {
            matrix[i][0] = i
        }
        for j in 0...b.count {
            matrix[0][j] = j
        }
        
        for i in 1...a.count {
            for j in 1...b.count {
                let cost = a[i-1] == b[j-1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i-1][j] + 1,
                    matrix[i][j-1] + 1,
                    matrix[i-1][j-1] + cost
                )
            }
        }
        
        return matrix[a.count][b.count]
    }
}
