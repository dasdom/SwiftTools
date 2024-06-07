//  Created by dasdom on 22.02.20.
//  Copyright © 2020 dasdom. All rights reserved.
//

import Foundation
import XcodeKit
import SwiftToolsHelper
import UserNotifications

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
  func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    
    let identifier = invocation.commandIdentifier
    
    let buffer = invocation.buffer
    let selections = buffer.selections
    let lines = buffer.lines
    
    defer {
      completionHandler(nil)
    }
    
    if identifier.hasSuffix(".AlignEquals") {
      
      if let range = firstSelectedRange(from: selections) {
        if let lines = Array(lines.subarray(with: range)) as? [String] {
        
          let changedLines = SwiftToolsHelper.alignEquals(in: lines)
        
          buffer.lines.replaceObjects(in: range, withObjectsFrom: changedLines)
        }
      }
    } else if identifier.hasSuffix(".ColorLiteralToUIColor") {
      
      if let lines = lines as? [String] {
        let result = SwiftToolsHelper.colorLiteralToUIColor(for: lines)
        buffer.lines.removeAllObjects()
        buffer.lines.addObjects(from: result)
      }
      
    } else if identifier.hasSuffix(".CopyProtocolDeclarationToClipboard") {
      
      if let range = firstSelectedRange(from: selections) {
        if let lines = Array(lines.subarray(with: range)) as? [String] {
        
          SwiftToolsHelper.protocolFromMethods(in: lines)

          let center = UNUserNotificationCenter.current()
          center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
              
              if let error = error {
                  print("error: \(error)")
              }
              
              // Enable or disable features based on the authorization.
            let content = UNMutableNotificationContent()
            content.title = "Protocol definition copied"
            content.body = "Protocol definition for selected methods copied to clipboard."
            
            // Configure the recurring date.
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            
            dateComponents.weekday = 3  // Tuesday
            dateComponents.hour = 14    // 14:00 hours
            
            // Create the trigger as a repeating event.
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            // Create the request
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString,
                                                content: content, trigger: trigger)
            
            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
              if let error = error {
                print("error \(error)")
              }
            }
          }
          
        }
      }
    } else if identifier.hasSuffix(".HexToUIColor") {
      
      if let firstSelection = selections.firstObject as? XCSourceTextRange {
        
        let start = firstSelection.start.column
        let end = firstSelection.end.column
        let startLine = firstSelection.start.line
        let endLine = firstSelection.end.line
        
        if endLine - startLine > 1 {
          return
        }
        
        let line: String = lines[startLine] as! String
        let input: String
        if startLine == endLine, start < end {
          let range = NSRange(location: start, length: end-start)
          input = (line as NSString).substring(with: range)
        } else {
          input = line
        }
        
        let result = SwiftToolsHelper.hexToUIColor(for: input)
        lines.insert(result, at: startLine+1)
      }
      
    } else if identifier.hasSuffix(".UIColorToColorLiteral") {
      
      if let lines = lines as? [String] {
        let result = SwiftToolsHelper.uiColorToColorLiteral(for: lines)
        buffer.lines.removeAllObjects()
        buffer.lines.addObjects(from: result)
      }
      
    } else if identifier.hasSuffix(".SortImports") {
      
      if let lines = lines as? [String] {
        let result = SwiftToolsHelper.sortImport(in: lines)
        buffer.lines.removeAllObjects()
        buffer.lines.addObjects(from: result)
      }
    } else if identifier.hasSuffix(".SortSelected") {

      if let range = firstSelectedRange(from: selections) {
        if let lines = Array(lines.subarray(with: range)) as? [String] {

          let changedLines = SwiftToolsHelper.sort(in: lines)

          buffer.lines.replaceObjects(in: range, withObjectsFrom: changedLines)
        }
      }
    } else if identifier.hasSuffix(".SortSelectedFunctions") {

      if let range = firstSelectedRange(from: selections) {
        if let lines = Array(lines.subarray(with: range)) as? [String] {

          let changedLines = SwiftToolsHelper.sortFunctions(in: lines)

          buffer.lines.replaceObjects(in: range, withObjectsFrom: changedLines)
        }
      }
      
    } else if identifier.hasSuffix(".SelectPlaceholder") {

      guard let selectedText = firstSelectedText(from: selections, in: lines) else {
        return
      }
      
      guard let stringLines = lines as? [NSString] else {
        return
      }
      
      for (index, line) in stringLines.enumerated() {
        
        var range = NSRange(location: 0, length: 0)
        var rangeToCompare = NSRange(location: 0, length: line.length)
        
        repeat {
          
          range = line.range(of: selectedText, options: .backwards, range: rangeToCompare)
          
          if range.length > 0 {
            let start = XCSourceTextPosition(line: index, column: range.location)
            let end = XCSourceTextPosition(line: index, column: range.location + range.length)
            let selection = XCSourceTextRange(start: start, end: end)
            
            selections.add(selection)
            
            rangeToCompare = NSRange(location: 0, length: range.location)
          }
          
        } while range.length > 0
        
      }
    }
  }
  
  func firstSelectedRange(from selections: NSArray) -> NSRange? {
    if let firstSelection = selections.firstObject as? XCSourceTextRange {
      
      let start = firstSelection.start
      let end = firstSelection.end
      return NSRange(location: start.line, length: end.line - start.line+1)
    }
    return nil
  }
  
  
  func firstSelectedText(from selections: NSArray, in lines: NSArray) -> String? {
    
    guard let firstSelection = selections.firstObject as? XCSourceTextRange else {
      return nil
    }
    
    
    guard let line = lines[firstSelection.start.line] as? NSString else {
      return nil
    }
    
    let start = firstSelection.start
    let end = firstSelection.end
    let range = NSRange(location: start.column, length: end.column - start.column)
    
    return line.substring(with: range)
  }
}
