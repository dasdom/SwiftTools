//  Created by dasdom on 22.02.20.
//  
//

import XCTest
@testable import SwiftToolsHelper

final class AlignEqualTests: XCTestCase {
  
  func test_alignEquals_twoLinesWithEquals() {
    let input = [
      TypedLine(type: .codeWithEquals, text: "let a =      getA()"),
      TypedLine(type: .codeWithEquals, text: "let foobar = getFoobar()"),
    ]
    
    let result = SwiftToolsHelper.alignEquals(in: input)
    
    let expectedResult = [
      "let a      = getA()",
      "let foobar = getFoobar()"
    ]
    XCTAssertEqual(expectedResult, result)
  }

  func test_alignEquals_2Lines_spaceBeforeEqual() {
    let input = [
      TypedLine(type: .codeWithEquals, text: "let a           = getA()"),
      TypedLine(type: .codeWithEquals, text: "let foobar      = getFoobar()")
    ]
    
    let result = SwiftToolsHelper.alignEquals(in: input)
    
    let expectedResult = [
      "let a      = getA()",
      "let foobar = getFoobar()"
    ]
    XCTAssertEqual(expectedResult, result)
  }
  
  func test_alignEquals_5Lines() {
    let input = [
      TypedLine(type: .codeWithEquals, text: "let a = getA()"),
      TypedLine(type: .codeWithEquals, text: "let foobar = getFoobar()"),
      TypedLine(type: .codeWithEquals, text: "let b = getA()"),
      TypedLine(type: .codeWithEquals, text: "let baz = getFoobar()"),
      TypedLine(type: .codeWithEquals, text: "let c = getA()")
    ]
    
    let result = SwiftToolsHelper.alignEquals(in: input)
    
    let expectedResult = [
      "let a      = getA()",
      "let foobar = getFoobar()",
      "let b      = getA()",
      "let baz    = getFoobar()",
      "let c      = getA()"
    ]
    XCTAssertEqual(expectedResult, result)
  }
  
  func test_alignEquals_interceptedLine() {
    let input = [
      TypedLine(type: .codeWithEquals, text: "let a = getA()"),
      TypedLine(type: .otherCode, text: "foobar()"),
      TypedLine(type: .codeWithEquals, text: "let blabla = getA()")
    ]
    
    let result = SwiftToolsHelper.alignEquals(in: input)
    
    let expectedResult = [
      "let a      = getA()",
      "foobar()",
      "let blabla = getA()"
    ]
    XCTAssertEqual(expectedResult, result)
  }
  
  func test_alignEquals_ignoresComments() {
    let input = [
      TypedLine(type: .inlineComment, text: "// let a  = getA()"),
      TypedLine(type: .codeWithEquals, text: "let b = getA()"),
      TypedLine(type: .codeWithEquals, text: "let blabla = getA()")
    ]
    
    let result = SwiftToolsHelper.alignEquals(in: input)
    
    let expectedResult = [
      "// let a  = getA()",
      "let b      = getA()",
      "let blabla = getA()"
    ]
    XCTAssertEqual(expectedResult, result)
  }
  
}
