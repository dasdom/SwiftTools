
import Foundation
import Cocoa

public struct SwiftToolsHelper {
  
  public static func alignEquals(in lines: [String]) -> [String] {
    
    let typed = typedLines(from: lines)
    return alignEquals(in: typed)
  }

  public static func sort(in lines: [String]) -> [String] {
    let typed = typedLines(from: lines)
    return sort(in: typed)
  }

  public static func protocolFromMethods(in lines: [String]) {
    
    let typed = typedLines(from: lines)
    let protocolString = protocolFromMethods(in: typed)
    
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(protocolString, forType: NSPasteboard.PasteboardType.string)
  }
  
  public static func hexToUIColor(for text: String) -> String {
    
    let range = text.range(of: "//")
    
    let scanner = Scanner(string: text)
    scanner.charactersToBeSkipped = NSCharacterSet.alphanumerics.inverted
    
    var rgbValue: UInt64 = 0
    scanner.scanHexInt64(&rgbValue)
    var r = CGFloat(0)
    var g = CGFloat(0)
    var b = CGFloat(0)
    var a = CGFloat(0)
    if rgbValue > 0xffffff {
      r = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
      g = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
      b = CGFloat((rgbValue & 0xFF00) >> 8) / 255.0
      a = CGFloat((rgbValue & 0xFF)) / 255.0
    } else {
      r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
      g = CGFloat((rgbValue & 0xFF00) >> 8) / 255.0
      b = CGFloat((rgbValue & 0xFF)) / 255.0
      a = 1.0
    }
    
    var indentString = ""
    if range?.lowerBound != range?.upperBound {
      if let location = range?.lowerBound.utf16Offset(in: text) {
        for _ in 0..<location {
          indentString.append(" ")
        }
      }
    }
    
    return String(format: "%@let <#name#> = UIColor(red: %.3f, green: %.3f, blue: %.3f, alpha: %.3f)", indentString, r, g, b, a)
  }
  
  public static func uiColorToColorLiteral(for lines: [String]) -> [String] {
    
    let typed = typedLines(from: lines)
    return uiColorToColorLiteral(in: typed)
  }
  
  public static func colorLiteralToUIColor(for lines: [String]) -> [String] {
    
    let typed = typedLines(from: lines)
    return colorLiteralToUIColor(for: typed)
  }
  
  public static func sortImport(in lines: [String]) -> [String] {
    
    let typed = typedLines(from: lines)
    return sortImport(in: typed)
  }
  
  public static func sortFunctions(in lines: [String]) -> [String] {
    _ = typedLines(from: lines)
    var newLines = nonEmptyOutsideOfFunction.map({ $0.text })
    if newLines.count > 0 {
      newLines += ["\n"]
    }
    for function in functions.sorted(by: { $0.name < $1.name }) {
      newLines += function.lines()
      newLines += ["\n"]
    }
    return newLines
  }
}

extension SwiftToolsHelper {
  
  static var functions: [Function] = []
  static var nonEmptyOutsideOfFunction: [TypedLine] = []

  static func typedLines(from lines: [String]) -> [TypedLine] {
    
    var typedLines: [TypedLine] = []
    var inMultilineComment = false
    var inMultilineFuncDeclaration = false
    var scopeCount = 0
//    var inFunction = false
    var functionComment: [TypedLine] = []
    var currentFunction: Function?
//    var functions: [Function] = []
//    var nonEmptyOutsideOfFunction: [TypedLine] = []

    for line in lines {
      if line.isMatching(regex: "\\*/") {
        if inMultilineComment {
          inMultilineComment = false
//        } else {
//          var tempTypedLines: [TypedLine] = []
//          let indexOfStart = typedLines.lastIndex(where: { $0.type == .startOfMultilineComment }) ?? -1
//          for (index, typedLine) in typedLines.enumerated() {
//            if indexOfStart < index {
//              tempTypedLines.append(TypedLine(type: .withinMultilineComment, text: typedLine.text))
//            } else {
//              tempTypedLines.append(typedLine)
//            }
//          }
//          typedLines = tempTypedLines
        }
        let typedLine = TypedLine(type: .endOfMultilineComment, text: line)
        typedLines.append(typedLine)
        functionComment.append(typedLine)

      } else if line.isMatching(regex: "/\\*") {
        inMultilineComment = true
        let typedLine = TypedLine(type: .startOfMultilineComment, text: line)
        typedLines.append(typedLine)
        functionComment.append(typedLine)

      } else if inMultilineComment {
        let typedLine = TypedLine(type: .withinMultilineComment, text: line)
        typedLines.append(typedLine)
        functionComment.append(typedLine)

      } else if line.isMatching(regex: "$.*/{2,}") {
        let typedLine = TypedLine(type: .inlineComment, text: line)
        typedLines.append(typedLine)
        functionComment.append(typedLine)

      } else if line.isMatching(regex: "(func).+\\{") {
        let typedLine = TypedLine(type: .inlineFuncDeclaration, text: line)
        typedLines.append(typedLine)
        currentFunction = Function(name: line, comments: functionComment)

        functionComment = []

      } else if line.isMatching(regex: "(func).+\\(") {
        inMultilineFuncDeclaration = true
        let typedLine = TypedLine(type: .startOfMultilineFuncDeclaration, text: line)
        typedLines.append(typedLine)
        currentFunction = Function(name: line, comments: functionComment)

        functionComment = []

      } else if false == line.isMatching(regex: "\\{") && inMultilineFuncDeclaration {
        let typedLine = TypedLine(type: .withinMultilineFuncDeclaration, text: line)
        typedLines.append(typedLine)

        functionComment = []

      } else if line.isMatching(regex: "=.*UIColor\\(red:.+green:.+blue:.+alpha:.+\\)") {
        let typedLine = TypedLine(type: .uiColorDefinitionRedGreenBlue, text: line)
        typedLines.append(typedLine)

        functionComment = []

      } else if line.isMatching(regex: "=.*#colorLiteral\\(red.+green:.+blue:.+alpha:.+\\)") {
        let typedLine = TypedLine(type: .colorLiteralDefinition, text: line)
        typedLines.append(typedLine)

        functionComment = []

      } else if line.isMatching(regex: " \\{") && inMultilineFuncDeclaration {
        inMultilineFuncDeclaration = false
        let typedLine = TypedLine(type: .endOfMultilineFuncDeclaration, text: line)
        typedLines.append(typedLine)

        functionComment = []

      } else if line.isMatching(regex: "#>") && line.isMatching(regex: "<#") {
        let typedLine = TypedLine(type: .placeHolder, text: line)
        typedLines.append(typedLine)

        functionComment = []

      } else if line.isMatching(regex: "\\s+=\\s+") && false == line.isMatching(regex: ".if.") {
        let typedLine = TypedLine(type: .codeWithEquals, text: line)
        typedLines.append(typedLine)

        functionComment = []

      } else if line.isMatching(regex: "^import") {
        let typedLine = TypedLine(type: .import, text: line)
        typedLines.append(typedLine)

        functionComment = []

      } else if line.isMatching(regex: "^@testable import") {
        let typedLine = TypedLine(type: .testableImport, text: line)
        typedLines.append(typedLine)

        functionComment = []

      } else if line.isMatching(regex: "\\}.*if.*\\{") {
        let typedLine = TypedLine(type: .otherCode, text: line)
        typedLines.append(typedLine)

        functionComment = []

      } else if line.isMatching(regex: " \\{") && false == line.isMatching(regex: "\\}") && nil != currentFunction {
        scopeCount += 1
        let typedLine = TypedLine(type: .otherCode, text: line)
        typedLines.append(typedLine)

      } else if line.isMatching(regex: "\\}") && nil != currentFunction {
        if scopeCount == 0 {
          let typedLine = TypedLine(type: .endOfFunc, text: line)
          typedLines.append(typedLine)
          if let currentFunction {
            currentFunction.typedLines.append(typedLine)
            functions.append(currentFunction)
          }
          currentFunction = nil
        } else {
          let typedLine = TypedLine(type: .otherCode, text: line)
          typedLines.append(typedLine)
          scopeCount -= 1
        }

      } else {
        let typedLine = TypedLine(type: .otherCode, text: line)
        typedLines.append(typedLine)

        functionComment = []

      }

      if line.isMatching(regex: "^\\s*$") && line != "\n" && nil == currentFunction {
        let typedLine = TypedLine(type: .otherCode, text: line)
        nonEmptyOutsideOfFunction.append(typedLine)
      }
      if let currentFunction,
         let typedLine = typedLines.last {
        currentFunction.typedLines.append(typedLine)
      }
    }
    return typedLines
  }
  
  static func alignEquals(in typedLines: [TypedLine]) -> [String] {
    
    let normalizedLines = typedLines.map { typedLine -> TypedLine in
      
      if typedLine.type != .codeWithEquals && typedLine.type != .uiColorDefinitionRedGreenBlue {
        return typedLine
      }
      
      return replace(pattern: "\\s+=\\s+", with: " = ", in: typedLine)
    }
    
    let maxEqualPosition = maxOffsetOfFirst(character: "=", in: normalizedLines)
    
    let resultLinesText = normalizedLines.map { line -> String in
      
      let text = line.text
      if line.type != .codeWithEquals && line.type != .uiColorDefinitionRedGreenBlue {
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
  
  static func protocolFromMethods(in typedLines: [TypedLine]) -> String {
    
    let lines = typedLines.filter({ typedLine -> Bool in
      return [LineType.inlineFuncDeclaration, .startOfMultilineFuncDeclaration, .withinMultilineFuncDeclaration, .endOfMultilineFuncDeclaration].contains(typedLine.type)
    }).map { typedLines -> String in
      let text = typedLines.text
      let rangeOfMatch = text.rangeOfFirstMatchOf(regex: "\\s*\\{")
      let result: String
      if rangeOfMatch.location != NSNotFound {
        result = text.replacingCharacters(in: Range(rangeOfMatch, in: text)!, with: "")
      } else {
        result = text
      }
      return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    let rawlines = lines.joined(separator: "\n")
    return "protocol <#Protocol Name#> {\n\(rawlines)\n}\n"
  }
  
  static func sortImport(in lines: [TypedLine]) -> [String] {
    
    let sortedImportLines = lines.filter({ $0.type == .import }).sorted(by: { $0.text < $1.text })
    let sortedTestableImportLines = lines.filter({ $0.type == .testableImport }).sorted(by: { $0.text < $1.text })
    
    let firstParty = appleFrameworks()
    
    var sortedFirstPartyImportLines: [TypedLine] = []
    var sortedThirdPartyImportLines: [TypedLine] = []
    for importLine in sortedImportLines {
      if let framework = importLine.text.components(separatedBy: " ").last?.trimmingCharacters(in: .whitespacesAndNewlines) {
//        print("framework: \(framework)")
        if firstParty.contains(framework) {
          sortedFirstPartyImportLines.append(importLine)
        } else {
          sortedThirdPartyImportLines.append(importLine)
        }
      }
    }
    
    guard let indexOfFirstImport = lines.firstIndex(where: { $0.type == .import || $0.type == .testableImport }) else {
      return lines.map({ $0.text })
    }
    
    guard let indexOfLastImport = lines.lastIndex(where: { $0.type == .import || $0.type == .testableImport }) else {
      return lines.map({ $0.text })
    }
    
    
    var typedWithSortedImport = lines.filter({ $0.type != .import && $0.type != .testableImport })

    let numberOfNonImportLinesInGroupOfImports =  indexOfLastImport - indexOfFirstImport - (sortedFirstPartyImportLines.count + sortedThirdPartyImportLines.count + sortedTestableImportLines.count)
    
    if numberOfNonImportLinesInGroupOfImports == 0 {
      if typedWithSortedImport[indexOfFirstImport].text == "\n" {
        typedWithSortedImport.remove(at: indexOfFirstImport)
      }
    }
    
    if numberOfNonImportLinesInGroupOfImports == 2 {
      if typedWithSortedImport[indexOfFirstImport].text == "\n" {
        typedWithSortedImport.remove(at: indexOfFirstImport)
      }
      if typedWithSortedImport[indexOfFirstImport+1].text == "\n" {
        typedWithSortedImport.remove(at: indexOfFirstImport+1)
      }
    }
    
    var imports: [TypedLine] = []
    if sortedFirstPartyImportLines.count > 0 {
      imports.append(contentsOf: sortedFirstPartyImportLines)
    }
    if sortedTestableImportLines.count > 0 {
      if imports.count > 0 {
        imports.append(TypedLine(type: .otherCode, text: ""))
      }
      imports.append(contentsOf: sortedTestableImportLines)
    }
    if sortedThirdPartyImportLines.count > 0 {
      if imports.count > 0 {
        imports.append(TypedLine(type: .otherCode, text: ""))
      }
      imports.append(contentsOf: sortedThirdPartyImportLines)
    }
    
    typedWithSortedImport.insert(contentsOf: imports, at: indexOfFirstImport)
    return typedWithSortedImport.map({ $0.text })
  }
 
  static func sort(in lines: [TypedLine]) -> [String] {
    return lines.sorted(by: { $0.text < $1.text }).map({ $0.text })
  }

  static func uiColorToColorLiteral(in lines: [TypedLine]) -> [String] {
    
    var result: [String] = []
    for line in lines {
      if line.type == .uiColorDefinitionRedGreenBlue {
        result.append(line.text.replacingOccurrences(of: "UIColor", with: "#colorLiteral"))
      } else {
        result.append(line.text)
      }
    }
    return result
  }
  
  static func colorLiteralToUIColor(for lines: [TypedLine]) -> [String] {
    
    var result: [String] = []
    for line in lines {
      if line.type == .colorLiteralDefinition {
        result.append(line.text.replacingOccurrences(of: "#colorLiteral", with: "UIColor"))
      } else {
        result.append(line.text)
      }
    }
    return result
  }
}

// MARK: - Helper Methods
extension SwiftToolsHelper {
  static func replace(pattern: String, with replacement: String, in typedLine: TypedLine) -> TypedLine {
    let text = typedLine.text
    let equalRange = text.rangeOfFirstMatchOf(regex: pattern)
    let normalizedLine = text.replacingCharacters(in: Range(equalRange, in: text)!, with: " = ")
    return TypedLine(type: typedLine.type, text: normalizedLine)
  }
  
  static func maxOffsetOfFirst(character: Character, in typedLines: [TypedLine]) -> Int {
    
    let maxOffset = typedLines.reduce(0) { result, nextLine in
      
      let text = nextLine.text
      if let index = text.firstIndex(of: character) {
        return max(result, index.utf16Offset(in: text))
      } else {
        return result
      }
    }
    return maxOffset
  }
  
  static func appleFrameworks() -> [String] {
    return ["Cocoa",
            "Foundation",
            "Swift",
            "SwiftUI",
            "TVML",
            "TVMLKit",
            "TVUIKit",
            "UIKit",
            "WatchKit",
    
            "AGL",
            "ARKit",
            "ColorSync",
            "CoreAnimation",
            "CoreGraphics",
            "CoreImage",
            "GameController",
            "GameKit",
            "GameplayKit",
            "GLKit",
            "ImageIO",
            "Metal",
            "MetalPerformanceShaders",
            "MetalKit",
            "ModelIO",
            "OpenGL",
            "PDFKit",
            "PencilKit",
            "Quartz",
            "RealityKit",
            "ReplayKit",
            "SceneKit",
            "SpriteKit",
            "Vision",
            
            "Accounts",
            "AddressBook",
            "AddressBookUI",
            "ApplicationServices",
            "AutomaticAssessmentConfiguration",
            "BackgroundTasks",
            "BusinessChat",
            "CallKit",
            "CareKit",
            "CarPlay",
            "ClassKit",
            "ClockKit",
            "CloudKit",
            "Combine",
            "Contacts",
            "ContactsUI",
            "CoreData",
            "CoreFoundation",
            "CoreLocation",
            "CoreML",
            "CoreMotion",
            "CoreSpotlight",
            "CoreText",
            "CreateML",
            "DeviceCheck",
            "EventKit",
            "EventKitUI",
            "FileProvider",
            "FileProviderUI",
            "HealthKit",
            "HomeKit",
            "iAd",
            "JavaScriptCore",
            "MapKit",
            "Messages",
            "MessageUI",
            "MultipeerConnectivity",
            "NaturalLanguage",
            "NewsstandKit",
            "NotificationCenter",
            "PassKit",
            "PreferencePanes",
            "PushKit",
            "QuickLook",
            "QuickLookThumbnailing",
            "SafariServices",
            "SiriKit",
            "Social",
            "Speech",
            "StoreKit",
            "TVServices",
            "UserNotifications",
            "UserNotificationsUI",
            "WatchConnectivity",
            "WebKit",
            
            "AssetsLibrary",
            "AudioToolbox",
            "AudioUnit",
            "AVFoundation",
            "AVKit",
            "CoreAudio",
            "CoreAudioKit",
            "CoreAudioTypes",
            "CoreHaptics",
            "CoreMedia",
            "CoreMIDI",
            "CoreVideo",
            "ImageCaptureCore",
            "iTunesLibrary",
            "MediaPlayer",
            "MediaAccessibility",
            "MediaLibrary",
            "PhotoKit",
            "QTKit",
            "ScreenSaver",
            "SoundAnalysis",
            "VideoToolbox",
            "VisionKit",
            
            "Accelerate",
            "CryptoKit",
            "AuthenticationServices",
            "CFNetwork",
            "Collaboration",
            "Compression",
            "CoreBluetooth",
            "CoreNFC",
            "CoreServices",
            "CoreTelephony",
            "CoreWLAN",
            "CryptoTokenKit",
            "DarwinNotify",
            "Device Management",
            "DiskArbitration",
            "Dispatch",
            "dnssd",
            "DriverKit",
            "EndpointSecurity",
            "ExceptionHandling",
            "ExecutionPolicy",
            "ExternalAccessory",
            "FinderSync",
            "ForceFeedback",
            "FWAUserLib",
            "GSS",
            "HIDDriverKit",
            "Hypervisor",
            "InputMethodKit",
            "IOBluetooth",
            "IOBluetoothUI",
            "IOKit",
            "IOSurface",
            "IOUSBHost",
            "libkern",
            "LatentSemanticMapping",
            "LocalAuthentication",
            "MetricKit",
            "MobileCoreServices",
            "Network",
            "NetworkExtension",
            "NetworkingDriverKit",
            "ObjectiveC",
            "OpenDirectory",
            "os",
            "OSLog",
            "PCIDriverKit",
            "Security",
            "SecurityFoundation",
            "SecurityInterface",
            "SerialDriverKit",
            "ServiceManagement",
            "simd",
            "SystemConfiguration",
            "SystemExtensions",
            "USBDriverKit",
            "USBSerialDriverKit",
            "vmnet",
            "XPC",
            
            "XCTest",
    ]
  }
  
}

