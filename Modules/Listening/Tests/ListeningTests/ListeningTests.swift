import XCTest
@testable import Listening

final class ListeningTests: XCTestCase {

    @MainActor
    func testDownloadedSurahModel() throws {
        let surah = DownloadedSurah(
            reciterId: 7,
            reciterName: "Mishary Rashid Alafasy",
            reciterArabicName: "مشاري راشد العفاسي",
            surahNumber: 1,
            surahName: "Al-Fatihah",
            fileSize: 1_048_576, // 1 MB
            audioFileName: "surah_1.mp3",
            timingsFileName: "surah_1_timings.json"
        )

        XCTAssertEqual(surah.id, "7_1")
        XCTAssertEqual(surah.reciterId, 7)
        XCTAssertEqual(surah.surahNumber, 1)
        XCTAssertFalse(surah.formattedSize.isEmpty)
    }

    @MainActor
    func testAudioDownloadManagerQueryAndDeletion() throws {
        let manager = AudioDownloadManager.shared
        XCTAssertNotNil(manager)
        XCTAssertEqual(manager.isSurahDownloaded(reciterId: 999999, surahNumber: 999), false)
        XCTAssertNil(manager.getLocalAudioAndTimings(reciterId: 999999, surahNumber: 999))
    }
}
