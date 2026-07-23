//
//  MushafFontManager.swift
//  Mushaf
//

import CoreText
import CoreGraphics
import Foundation

/// Which variant of the Mushaf font set to use.
public enum MushafFontSet: String, CaseIterable {
    case tajweed = "V4Fonts"
    case plain   = "V4FontsPlain"
}

public final class MushafFontManager: ObservableObject {
    public static let shared = MushafFontManager()
    @Published public private(set) var isReady = false
    private var fontNames: [MushafFontSet: [Int: String]] = [:]

    private init() {}

    /// Registers all Mushaf TTF fonts from the app bundle.
    /// Safe to call multiple times — subsequent calls are no-ops.
    /// Runs off the main thread and calls `completion` back on the main thread.
    public func registerFonts(completion: (() -> Void)? = nil) {
        guard !isReady else {
            completion?()
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }

            let urls = self.findFontURLs()
            guard !urls.isEmpty else {
                print("No .ttf fonts found in the app bundle")
                DispatchQueue.main.async { completion?() }
                return
            }

            for url in urls {
                self.register(fontAt: url)
            }

            DispatchQueue.main.async {
                self.isReady = true
                for set in MushafFontSet.allCases {
                    let count = self.fontNames[set]?.count ?? 0
                    print(" \(set): registered \(count) page fonts")
                }
                completion?()
            }
        }
    }

    /// Returns the PostScript name of the font for `page` in the given `set`.
    /// Falls back to the tajweed variant if the plain variant isn't available.
    public func fontName(forPage page: Int, set: MushafFontSet) -> String? {
        fontNames[set]?[page] ?? fontNames[.tajweed]?[page]
    }

    public func isFontSetAvailable(_ set: MushafFontSet) -> Bool {
        !(fontNames[set]?.isEmpty ?? true)
    }

    // MARK: - Private helpers

    private func findFontURLs() -> [URL] {
        guard let resourcePath = Bundle.main.resourcePath else { return [] }
        let resourceURL = URL(fileURLWithPath: resourcePath)

        guard let enumerator = FileManager.default.enumerator(
            at: resourceURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        var results: [URL] = []
        for case let fileURL as URL in enumerator where fileURL.pathExtension.lowercased() == "ttf" {
            let filename = fileURL.lastPathComponent
            if filename.hasPrefix("Inter") || filename.hasPrefix("AmiriQuran") {
                continue
            }
            results.append(fileURL)
        }
        return results
    }

    private func register(fontAt url: URL) {
        var errorRef: Unmanaged<CFError>?
        let registered = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &errorRef)

        if !registered {
            if let error = errorRef?.takeRetainedValue() as Error? {
                let nsError = error as NSError
                if nsError.code != 305 {
                    print("Font registration failed for \(url.lastPathComponent): \(error.localizedDescription)")
                    return
                }
            } else {
                return
            }
        }

        guard
            let dataProvider = CGDataProvider(url: url as CFURL),
            let cgFont = CGFont(dataProvider),
            let postScriptName = cgFont.postScriptName as String?
        else {
            print("Could not read font metadata for: \(url.lastPathComponent)")
            return
        }

        guard let page = extractPageNumber(from: url.lastPathComponent) else { return }
        guard let set = fontSet(for: url) else { return }

        fontNames[set, default: [:]][page] = postScriptName
    }

    private func fontSet(for url: URL) -> MushafFontSet? {
        let path = url.path
        if path.contains(MushafFontSet.plain.rawValue) {
            return .plain
        } else if path.contains(MushafFontSet.tajweed.rawValue) {
            return .tajweed
        }
        return nil
    }

    private func extractPageNumber(from filename: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: #"(\d{1,3})(?=\.ttf$)"#) else {
            return nil
        }
        let range = NSRange(filename.startIndex..., in: filename)
        guard
            let match = regex.firstMatch(in: filename, range: range),
            let matchRange = Range(match.range, in: filename)
        else { return nil }

        return Int(filename[matchRange])
    }
}

