
import Foundation
import Cocoa

public struct SwiftToolsHelper {
  
  public static func alignEquals(in lines: [String]) -> [String] {
    
    let typed = typedLines(from: lines)
    return alignEquals(in: typed)
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
  
  public static func sortImport(in lines: [String]) -> [String] {
    
    let typed = typedLines(from: lines)
    return sortImport(in: typed)
  }
  
}

extension SwiftToolsHelper {
  
  static func typedLines(from lines: [String]) -> [TypedLine] {
    
    var typedLines: [TypedLine] = []
    var inMultilineComment = false
    var inMultilineFuncDeclaration = false
    
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
      } else if line.isMatching(regex: "(func).+\\{") {
        typedLines.append(TypedLine(type: .inlineFuncDeclaration, text: line))
      } else if line.isMatching(regex: "(func).+\\(") {
        inMultilineFuncDeclaration = true
        typedLines.append(TypedLine(type: .startOfMultilineFuncDeclaration, text: line))
      } else if false == line.isMatching(regex: "\\{") && inMultilineFuncDeclaration {
        typedLines.append(TypedLine(type: .withinMultilineFuncDeclaration, text: line))
      } else if line.isMatching(regex: " \\{") && inMultilineFuncDeclaration {
        inMultilineFuncDeclaration = false
        typedLines.append(TypedLine(type: .endOfMultilineFuncDeclaration, text: line))
      } else if line.isMatching(regex: "\\s+=\\s+") {
        typedLines.append(TypedLine(type: .codeWithEquals, text: line))
      } else if line.isMatching(regex: "^import") {
        typedLines.append(TypedLine(type: .import, text: line))
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
      
      return replace(pattern: "\\s+=\\s+", with: " = ", in: typedLine)
    }
    
    let maxEqualPosition = maxOffsetOfFirst(character: "=", in: normalizedLines)
    
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
    
    guard let indexOfFirstImport = lines.firstIndex(where: { $0.type == .import }) else {
      return lines.map({ $0.text })
    }
    
    var typedWithSortedImport = lines.filter({ $0.type != .import })
    
    let imports = sortedFirstPartyImportLines + [TypedLine(type: .otherCode, text: "")] + sortedThirdPartyImportLines
    
    typedWithSortedImport.insert(contentsOf: imports, at: indexOfFirstImport)
    return typedWithSortedImport.map({ $0.text })
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
    return ["AppKit",
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
    ]
  }
  
}

