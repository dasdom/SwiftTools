//  Created by dasdom on 23.02.20.
//  
//

import XCTest
@testable import SwiftToolsHelper

final class ProtocolFromSelectedMethodsTests : XCTestCase {
  
  func test_protocolFromSelectedMethods_oneMethod() {
    
    let input = [
      TypedLine(type: .startOfMultilineFuncDeclaration, text: "func foo() {"),
      TypedLine(type: .otherCode, text: "    return"),
      TypedLine(type: .otherCode, text: "}"),
    ]
    
    let result = SwiftToolsHelper.protocolFromMethods(in: input)
    
    let expectedResult = "protocol <#Protocol Name#> {\nfunc foo()\n}\n"
    XCTAssertEqual(expectedResult, result)
  }
  
  func test_protocolFromSelectedMethods_twoMethods() {
    
    let input = [
      TypedLine(type: .startOfMultilineFuncDeclaration, text: "func foo() {"),
      TypedLine(type: .otherCode,                       text: "    return"),
      TypedLine(type: .otherCode,                       text: "}"),
      TypedLine(type: .otherCode,                       text: ""),
      TypedLine(type: .startOfMultilineFuncDeclaration, text: "func a(a: A,"),
      TypedLine(type: .withinMultilineFuncDeclaration,  text: "       b: B,"),
      TypedLine(type: .endOfMultilineFuncDeclaration,   text: "       c: C) {"),
      TypedLine(type: .otherCode,                       text: "    foo()"),
    ]
    
    let result = SwiftToolsHelper.protocolFromMethods(in: input)
    
    let expectedResult = "protocol <#Protocol Name#> {\nfunc foo()\nfunc a(a: A,\nb: B,\nc: C)\n}\n"
    XCTAssertEqual(expectedResult, result)
  }
}
