//  Created by dasdom on 22.02.20.
//  
//

import XCTest
@testable import SwiftToolsHelper

final class AlignEqualTests: XCTestCase {
  
  func test_alignEquals_2Lines() {
    let input = [
      "let a =      getA()",
      "let foobar = getFoobar()"
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
      "let a           = getA()",
      "let foobar      = getFoobar()"
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
      "let a = getA()",
      "let foobar = getFoobar()",
      "let b = getA()",
      "let baz = getFoobar()",
      "let c = getA()"
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
      "let a = getA()",
      "foobar()",
      "let blabla = getA()"
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
      "// let a  = getA()",
      "let b = getA()",
      "let blabla = getA()"
    ]
    
    let result = SwiftToolsHelper.alignEquals(in: input)
    
    let expectedResult = [
      "// let a  = getA()",
      "let b      = getA()",
      "let blabla = getA()"
    ]
    XCTAssertEqual(expectedResult, result)
  }
  
  func test_alignEquals_ignoresMultilineComments() {
    let input = [
      "let a  = getA()",
      "let a  = getA() */",
      "let b = getA()",
      "let blabla = getA()"
    ]
    
    let result = SwiftToolsHelper.alignEquals(in: input)
    
    let expectedResult = [
      "let a  = getA()",
      "let a  = getA() */",
      "let b      = getA()",
      "let blabla = getA()"
    ]
    XCTAssertEqual(expectedResult, result)
  }
}
