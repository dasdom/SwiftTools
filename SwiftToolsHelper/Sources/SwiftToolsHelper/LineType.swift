//  Created by dasdom on 22.02.20.
//  
//

import Foundation

enum LineType : String, Equatable {
  case startOfMultilineComment
  case endOfMultilineComment
  case withinMultilineComment
  case inlineComment
  case inlineFuncDeclaration
  case startOfMultilineFuncDeclaration
  case endOfMultilineFuncDeclaration
  case withinMultilineFuncDeclaration
  case otherCode
  case codeWithEquals
  case `import`
  case testableImport
  case uiColorDefinitionRedGreenBlue
  case colorLiteralDefinition
}
