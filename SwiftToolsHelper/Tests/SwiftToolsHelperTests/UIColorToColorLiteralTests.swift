//  Created by dasdom on 30.03.20.
//  
//

import XCTest
@testable import SwiftToolsHelper

final class UIColorToColorLiteralTests : XCTestCase {
  
  func test_uiColorToColorLiteral() {
    let input = "  let foobarColor = UIColor(red: 1.000, green: 0.627, blue: 0.016, alpha: 0.808)"
    
    let result = SwiftToolsHelper.uiColorToColorLiteral(for: [input])
    
    let expectedResult = ["  let foobarColor = #colorLiteral(red: 1.000, green: 0.627, blue: 0.016, alpha: 0.808)"]
    XCTAssertEqual(expectedResult, result)
  }
}
