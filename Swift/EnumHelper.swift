#!/usr/bin/env swift

import Foundation

func subString(pattern:String,str:String) -> [String] {
    var subStr = [String]()
    let regex = try! NSRegularExpression(pattern: pattern, options:[])
    let matches = regex.matches(in: str, options: [], range: NSRange(str.startIndex...,in: str))
    for  match in matches {
        for i in 1..<match.numberOfRanges  {
            let str = String(str[Range(match.range(at: i), in: str)!])
            subStr.append(str)
        }
    }
    return subStr
}

let argsCount = CommandLine.argc
let arguments = CommandLine.arguments

if argsCount > 1 {
    let string = arguments[1]
    
    let pattern0 = "case (.*?)\\("
    let name = subString(pattern: pattern0, str: string).first
    var caseString = "case let .\(name!)("
    let pattern = ".*?\\((.*)\\)"
    let args = subString(pattern:pattern,str: string)
    var keys = [String]()
    for i in args {
        let keyvaluePairs = i.components(separatedBy: ",")
        for j in keyvaluePairs {
            let key = String(j.split(separator: ":").first ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            keys.append(key)
        }
    }
    
    caseString.append(keys.joined(separator: ","))
    caseString.append("):")
    print(caseString)
    for key in keys {
        print("params[\"\(key)\"] = \(key)")
    }

    print("case .\(name!):")
    print("    return \"\"")
}



