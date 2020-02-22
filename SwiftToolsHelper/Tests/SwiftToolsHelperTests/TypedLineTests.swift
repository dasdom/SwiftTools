//  Created by dasdom on 22.02.20.
//  
//

import XCTest
@testable import SwiftToolsHelper

final class TypedLineTests: XCTestCase {

  func test_type_inlineComment() {
    
    let input = [
      "// let a  = getA()",
    ]
    
    let result = SwiftToolsHelper.typedLines(from: input)
    
    let expectedResult = [
      TypedLine(type: .inlineComment, text: "// let a  = getA()"),
    ]
    XCTAssertEqual(expectedResult, result)
  }
  
  func test_type_code() {
    
    let input = [
      "let a  = getA()",
    ]
    
    let result = SwiftToolsHelper.typedLines(from: input)
    
    let expectedResult = [
      TypedLine(type: .codeWithEquals, text: "let a  = getA()"),
    ]
    XCTAssertEqual(expectedResult, result)
  }
  
  func test_type_inlineCommentAndCode() {
    
    let input = [
      "// let a  = getA()",
      "let a  = getA()",
    ]
    
    let result = SwiftToolsHelper.typedLines(from: input)
    
    let expectedResult = [
      TypedLine(type: .inlineComment, text: "// let a  = getA()"),
      TypedLine(type: .codeWithEquals, text: "let a  = getA()"),
    ]
    XCTAssertEqual(expectedResult, result)
  }
  
  func test_type_multilineCommentAndCode_start() {
    
    let input = [
      "let a  = getA()",
      "let a  = getA() */",
      "let a  = getA()",
    ]
    
    let result = SwiftToolsHelper.typedLines(from: input)
    
    let expectedResult = [
      TypedLine(type: .withinMultilineComment, text: "let a  = getA()"),
      TypedLine(type: .endOfMultilineComment, text: "let a  = getA() */"),
      TypedLine(type: .codeWithEquals, text: "let a  = getA()"),
    ]
    XCTAssertEqual(expectedResult, result)
  }
  
  func test_type_multilineCommentAndCode_within() {
    
    let input = [
      "let a  = getA()",
      "/* let a  = getA()",
      "let a  = getA()",
      "let a  = getA() */",
      "let a  = getA()",
    ]
    
    let result = SwiftToolsHelper.typedLines(from: input)
    
    let expectedResult = [
      TypedLine(type: .codeWithEquals, text: "let a  = getA()"),
      TypedLine(type: .startOfMultilineComment, text: "/* let a  = getA()"),
      TypedLine(type: .withinMultilineComment, text: "let a  = getA()"),
      TypedLine(type: .endOfMultilineComment, text: "let a  = getA() */"),
      TypedLine(type: .codeWithEquals, text: "let a  = getA()"),
    ]
    XCTAssertEqual(expectedResult, result)
  }
  
  func test_type_multilineCommentAndCode_end() {
    
    let input = [
      "let a  = getA()",
      "/* let a  = getA()",
      "let a  = getA()",
    ]
    
    let result = SwiftToolsHelper.typedLines(from: input)
    
    let expectedResult = [
      TypedLine(type: .codeWithEquals, text: "let a  = getA()"),
      TypedLine(type: .startOfMultilineComment, text: "/* let a  = getA()"),
      TypedLine(type: .withinMultilineComment, text: "let a  = getA()"),
    ]
    XCTAssertEqual(expectedResult, result)
  }
}
