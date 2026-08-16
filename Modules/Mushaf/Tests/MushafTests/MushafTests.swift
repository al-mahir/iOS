import XCTest
@testable import Mushaf

final class MushafTests: XCTestCase {

    @MainActor
    func testSurahStartPagesMapping() throws {
        XCTAssertEqual(MushafViewModel.surahStartPages.count, 114)
        XCTAssertEqual(MushafViewModel.surahStartPages[0], 1) // Surah 1 -> Page 1
        XCTAssertEqual(MushafViewModel.surahStartPages[1], 2) // Surah 2 -> Page 2
        XCTAssertEqual(MushafViewModel.surahStartPages[35], 440) // Surah 36 -> Page 440
        XCTAssertEqual(MushafViewModel.surahStartPages[113], 604) // Surah 114 -> Page 604
    }
}
