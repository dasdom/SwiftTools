//  Created by dasdom on 22.02.20.
//  
//

import Foundation

extension String {
  
  func rangeOfFirstMatchOf(regex: String) -> NSRange {
    
    let range = NSRange(location: 0, length: self.utf16.count)
    let regex = try! NSRegularExpression(pattern: regex)
    return regex.rangeOfFirstMatch(in: self, options: [], range: range)
  }
  
  func isMatching(regex: String) -> Bool {
    return rangeOfFirstMatchOf(regex: regex).location != NSNotFound
  }
}
