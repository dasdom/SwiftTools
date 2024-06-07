//  Created by Dominik Hauser on 07.06.24.
//  
//


import Foundation

class Function {
  let name: String
  let comments: [TypedLine]
  var typedLines: [TypedLine] = []

  init(name: String, comments: [TypedLine]) {
    self.name = name
    self.comments = comments
  }

  func lines() -> [String] {
    return comments.map({ $0.text }) + typedLines.map({ $0.text })
  }
}
