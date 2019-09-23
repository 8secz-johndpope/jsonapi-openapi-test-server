//
//  ApiTestPackageCompile.swift
//  SwiftGen
//
//  Created by Mathew Polzin on 9/21/19.
//

import Foundation

public func prepOutFolder(_ outPath: String) {
    try? FileManager.default.removeItem(atPath: outPath + "/Tests/GeneratedAPITests")

    if !FileManager.default.fileExists(atPath: outPath + "/Tests/GeneratedAPITests/resourceObjects") {
        try! FileManager.default.createDirectory(atPath: outPath + "/Tests/GeneratedAPITests/resourceObjects",
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
    }
}

//public func compileAPITestPackage(at path: String) throws {
//    guard shell("cd '\(path)' && swift build > build.log 2>&1") == shellSuccessCode else {
//        throw TestPackageSwiftError.compilationFailed
//    }
//}

public func runAPITestPackage(at path: String) throws {
    guard shell("cd '\(path)' && swift test > test.log 2>&1") == shellSuccessCode else {
        throw TestPackageSwiftError.executionFailed
    }
}

let shellSuccessCode: Int32 = 0

public enum TestPackageSwiftError: Swift.Error {
//    case compilationFailed
    case executionFailed
}

@discardableResult
func shell(_ command: String) -> Int32 {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]

//    let pipe = Pipe()
//    task.standardOutput = pipe
    task.launch()

//    let data = pipe.fileHandleForReading.readDataToEndOfFile()
//    let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String

    task.waitUntilExit()
    return task.terminationStatus
}
