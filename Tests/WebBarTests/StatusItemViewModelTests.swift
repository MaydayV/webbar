import XCTest
@testable import WebBar

final class StatusItemViewModelTests: XCTestCase {
    func testReturnsControlItemWhenNoLinks() {
        let viewModels = StatusItemViewModel.make(from: [])
        XCTAssertEqual(viewModels.count, 1)
        XCTAssertNil(viewModels[0].link)
    }

    func testReturnsAllItemsWithoutArtificialLimit() {
        let links = (0..<7).map { i in
            LinkItem(name: "Link \(i)", urlString: "https://\(i).example.com")
        }
        let viewModels = StatusItemViewModel.make(from: links)
        XCTAssertEqual(viewModels.count, 7)
        XCTAssertEqual(viewModels.compactMap(\.link).count, 7)
    }
}
