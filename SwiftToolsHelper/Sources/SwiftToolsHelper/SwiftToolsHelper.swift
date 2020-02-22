
import Foundation

struct SwiftToolsHelper {
  
  static func alignEquals(in selectedLines: [String]) -> [String] {
    
    let normalizedLines = selectedLines.map { text -> Line in
      
      let equalRange = text.rangeOfFirstMatchOf(regex: "\\s+=\\s+")
      let inlineCommentRange = text.rangeOfFirstMatchOf(regex: "/{2,}.+\\s+=\\s+")
      
      if inlineCommentRange.location != NSNotFound {
        return Line(type: .comment, text: text)
      }
      
      let normalizedLine: String
      if equalRange.location != NSNotFound {
        normalizedLine = text.replacingCharacters(in: Range(equalRange, in: text)!, with: " = ")
      } else {
        normalizedLine = text
      }
      return Line(type: .code, text: normalizedLine)
    }
    
    let maxEqualPosition = normalizedLines.reduce(0) { result, nextLine in
     
      let text = nextLine.text
      if let index = text.firstIndex(of: "=") {
        return max(result, index.utf16Offset(in: text))
      } else {
        return result
      }
    }
    
    let resultLinesText = normalizedLines.map { line -> String in
      
      let text = line.text
      if line.type == .comment {
        return text
      }
      
      if let index = text.firstIndex(of: "="), index.utf16Offset(in: text) < maxEqualPosition {
        var spaces = ""
        for _ in 0..<maxEqualPosition - index.utf16Offset(in: text) {
          spaces.append(" ")
        }
        return line.text.replacingOccurrences(of: " = ", with: "\(spaces) = ")
      }
      return line.text
    }
    
    return resultLinesText
  }
}
