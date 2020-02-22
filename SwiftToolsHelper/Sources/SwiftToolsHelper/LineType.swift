//  Created by dasdom on 22.02.20.
//  
//

import Foundation

enum LineType : String, Equatable {
  case startOfMultilineComment
  case endOfMultilineComment
  case withinMultilineComment
  case inlineComment
  case otherCode
  case codeWithEquals
}
