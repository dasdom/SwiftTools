//  Created by dasdom on 03.04.20.
//  
//

import XCTest
@testable import SwiftToolsHelper

final class ColorLiteralToUIColorTests : XCTestCase {
  
  func test_colorLiteralToUIColor() {
    let input = "  let foobarColor = #colorLiteral(red: 1.000, green: 0.627, blue: 0.016, alpha: 0.808)"
    
    let result = SwiftToolsHelper.colorLiteralToUIColor(for: [input])
    
    let expectedResult = ["  let foobarColor = UIColor(red: 1.000, green: 0.627, blue: 0.016, alpha: 0.808)"]
    XCTAssertEqual(expectedResult, result)
  }
}
