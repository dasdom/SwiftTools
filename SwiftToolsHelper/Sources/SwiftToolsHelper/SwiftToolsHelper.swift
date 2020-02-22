
import Foundation

struct SwiftToolsHelper {
  
  static func typedLines(from lines: [String]) -> [TypedLine] {
    
    var typedLines: [TypedLine] = []
    var inMultilineComment = false
    
    for line in lines {
     
      if line.isMatching(regex: "\\*/") {
        if inMultilineComment {
          inMultilineComment = false
        } else {
          var tempTypedLines: [TypedLine] = []
          let indexOfStart = typedLines.lastIndex(where: { $0.type == .startOfMultilineComment }) ?? -1
          for (index, typedLine) in typedLines.enumerated() {
            if indexOfStart < index {
              tempTypedLines.append(TypedLine(type: .withinMultilineComment, text: typedLine.text))
            } else {
              tempTypedLines.append(typedLine)
            }
          }
          typedLines = tempTypedLines
        }
        typedLines.append(TypedLine(type: .endOfMultilineComment, text: line))
      } else if line.isMatching(regex: "\\*") {
        inMultilineComment = true
        typedLines.append(TypedLine(type: .startOfMultilineComment, text: line))
      } else if inMultilineComment {
        typedLines.append(TypedLine(type: .withinMultilineComment, text: line))
      } else if line.isMatching(regex: "/{2,}") {
        typedLines.append(TypedLine(type: .inlineComment, text: line))
      } else if line.isMatching(regex: "\\s+=\\s+") {
        typedLines.append(TypedLine(type: .codeWithEquals, text: line))
      } else {
        typedLines.append(TypedLine(type: .otherCode, text: line))
      }
    }
    return typedLines
  }
  
  static func alignEquals(in typedLines: [TypedLine]) -> [String] {

    let normalizedLines = typedLines.map { typedLine -> TypedLine in

      if typedLine.type != .codeWithEquals {
        return typedLine
      }
      
      let text = typedLine.text
      let equalRange = text.rangeOfFirstMatchOf(regex: "\\s+=\\s+")

      let normalizedLine = text.replacingCharacters(in: Range(equalRange, in: text)!, with: " = ")
      return TypedLine(type: .codeWithEquals, text: normalizedLine)
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
      if line.type != .codeWithEquals {
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
