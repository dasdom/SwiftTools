//  Created by dasdom on 14.03.20.
//  
//

import XCTest
@testable import SwiftToolsHelper

final class SortImportTests : XCTestCase {
  
  func test_sortImport_treeLines() {
    let input = [
      TypedLine(type: .inlineComment, text: "//"),
      TypedLine(type: .otherCode, text: ""),
      TypedLine(type: .import, text: "import UIKit"),
      TypedLine(type: .import, text: "import Foo"),
      TypedLine(type: .import, text: "import Foundation"),
      TypedLine(type: .import, text: "import Bar"),
      TypedLine(type: .otherCode, text: ""),
      TypedLine(type: .otherCode, text: "class Foo {"),
      TypedLine(type: .otherCode, text: "}"),
    ]
    
    let result = SwiftToolsHelper.sortImport(in: input)
    
    let expectedResult = [
      "//",
      "",
      "import Foundation",
      "import UIKit",
      "",
      "import Bar",
      "import Foo",
      "",
      "class Foo {",
      "}"
    ]
    XCTAssertEqual(expectedResult, result)
  }
}
