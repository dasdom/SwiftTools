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
  
  func test_type_inlineFuncDeclaration() {
    let input = [
      "func a() {"
    ]
    
    let result = SwiftToolsHelper.typedLines(from: input)
    
    let expectedResult = [
      TypedLine(type: .inlineFuncDeclaration, text: "func a() {")
    ]
    XCTAssertEqual(expectedResult, result)
  }
  
  func test_type_multilineFuncDeclaration() {
    let input = [
      "func a(a: A",
      "       b: B",
      "       c: C) {"
    ]
    
    let result = SwiftToolsHelper.typedLines(from: input)
    
    let expectedResult = [
      TypedLine(type: .startOfMultilineFuncDeclaration, text: "func a(a: A"),
      TypedLine(type: .withinMultilineFuncDeclaration, text: "       b: B"),
      TypedLine(type: .endOfMultilineFuncDeclaration, text: "       c: C) {")
    ]
    XCTAssertEqual(expectedResult, result)
  }
  
  func test_type_multilineFuncDeclaration_andOtherCode() {
    let input = [
      "func a(a: A",
      "       b: B) {",
      "    foo()"
    ]
    
    let result = SwiftToolsHelper.typedLines(from: input)
    
    let expectedResult = [
      TypedLine(type: .startOfMultilineFuncDeclaration, text: "func a(a: A"),
      TypedLine(type: .endOfMultilineFuncDeclaration, text: "       b: B) {"),
      TypedLine(type: .otherCode, text: "    foo()")
    ]
    XCTAssertEqual(expectedResult, result)
  }
  
  func test_type_import() {
    let input = [
      "import UIKit",
      "import Foundation",
      "import MapKit"
    ]
    
    let result = SwiftToolsHelper.typedLines(from: input)
    
    let expectedResult = [
      TypedLine(type: .import, text: "import UIKit"),
      TypedLine(type: .import, text: "import Foundation"),
      TypedLine(type: .import, text: "import MapKit"),
    ]
    XCTAssertEqual(expectedResult, result)
  }
  
  func test_type_uiColorDefinition() {
    let input = [
        "let foobarColor = UIColor(red: 1.000, green: 0.627, blue: 0.016, alpha: 0.808)"
    ]
    
    let result = SwiftToolsHelper.typedLines(from: input)
    
    let expectedResult = [
      TypedLine(type: .uiColorDefinitionRedGreenBlue, text: input[0])
    ]
    XCTAssertEqual(expectedResult, result)
  }
  
  func test_type_placeholder() {
    let input = [
      "let foobar = <#name#>"
    ]
    
    let result = SwiftToolsHelper.typedLines(from: input)
    
    let expectedResult = [
      TypedLine(type: .placeHolder, text: input[0])
    ]
    XCTAssertEqual(expectedResult, result)
  }
}
