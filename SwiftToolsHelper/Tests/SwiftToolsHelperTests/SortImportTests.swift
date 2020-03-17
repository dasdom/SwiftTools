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
      TypedLine(type: .import, text: "import UIKit\n"),
      TypedLine(type: .import, text: "import Foo\n"),
      TypedLine(type: .import, text: "import Foundation\n"),
      TypedLine(type: .import, text: "import Bar\n"),
      TypedLine(type: .otherCode, text: ""),
      TypedLine(type: .otherCode, text: "class Foo {"),
      TypedLine(type: .otherCode, text: "}"),
    ]
    
    let result = SwiftToolsHelper.sortImport(in: input)
    
    let expectedResult = [
      "//",
      "",
      "import Foundation\n",
      "import UIKit\n",
      "",
      "import Bar\n",
      "import Foo\n",
      "",
      "class Foo {",
      "}"
    ]
    XCTAssertEqual(expectedResult, result)
  }
}
