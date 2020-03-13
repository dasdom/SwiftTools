//  Created by dasdom on 23.02.20.
//  
//

import XCTest
@testable import SwiftToolsHelper

final class HexToUIColorTests : XCTestCase {
  
  func test_hexToUIColor_withHashtagSign() {
    let input = "#FFa004ce"
    
    let result = SwiftToolsHelper.hexToUIColor(for: input)
    
    let expectedResult = "let <#name#> = UIColor(red: 1.000, green: 0.627, blue: 0.016, alpha: 0.808)"
    XCTAssertEqual(expectedResult, result)
  }
  
  func test_hexToUIColor_withoutHashtagSign() {
    let input = "FFa004ce"
    
    let result = SwiftToolsHelper.hexToUIColor(for: input)
    
    let expectedResult = "let <#name#> = UIColor(red: 1.000, green: 0.627, blue: 0.016, alpha: 0.808)"
    XCTAssertEqual(expectedResult, result)
  }
  
  func test_hexToUIColor_withHashtagSignAndBeginningOfLine() {
    let input = "  // #FFa004ce"
    
    let result = SwiftToolsHelper.hexToUIColor(for: input)
    
    let expectedResult = "  let <#name#> = UIColor(red: 1.000, green: 0.627, blue: 0.016, alpha: 0.808)"
    XCTAssertEqual(expectedResult, result)
  }
}
