//
//  main.swift
//  Cleaner-Swift
//
//  Created by Renjun Li on 2025/2/6.
//

import Foundation

func calculateFolderSize(atPath path: String) -> Int64 {
    let task = Process()
    task.launchPath = "/usr/bin/du"
    task.arguments = ["-sk", path]
    
    let pipe = Pipe()
    task.standardOutput = pipe
    
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    
    task.waitUntilExit()
    
    if let output = output, let sizeString = output.split(separator: "\t").first, let size = Int64(sizeString) {
        return size // Return size in KB
    } else {
        print("Error parsing output from du command")
        return 0
    }
}

struct FileInfo {
    var path: String
    var name: String
    var sizeKB: Int64
    var subFiles: [FileInfo]
}

func calculateFolderSizesRecursively(atPath path: String) -> FileInfo {
    var totalSize: Int64 = 0
    let fileManager = FileManager.default
    var subFiles: [FileInfo] = []
    
    do {
        let items = try fileManager.contentsOfDirectory(atPath: path)
        for item in items {
            let itemURL = URL(fileURLWithPath: path).appendingPathComponent(item)
            let itemPath = itemURL.path
            print("Checking path: \(itemPath)") // Debugging line to verify path
            
            if let itemAttributes = try? fileManager.attributesOfItem(atPath: itemPath),
               itemAttributes[FileAttributeKey.type] as? String == FileAttributeType.typeDirectory.rawValue {
                let subFileInfo = calculateFolderSizesRecursively(atPath: itemPath)
                totalSize += subFileInfo.sizeKB
                subFiles.append(subFileInfo)
            } else {
                let size = calculateFolderSize(atPath: itemPath)
                totalSize += size
                subFiles.append(FileInfo(path: itemPath, name: item, sizeKB: size, subFiles: []))
            }
        }
    } catch {
        print("Error reading directory at path \(path): \(error)")
    }
    
    return FileInfo(path: path, name: URL(fileURLWithPath: path).lastPathComponent ?? path, sizeKB: totalSize, subFiles: subFiles)
}

func main() {
    let arguments = CommandLine.arguments
    guard arguments.count > 1 else {
        print("Usage: \(arguments[0]) <folder_path>")
        exit(1)
    }
    
    let folderPath = arguments[1]
    let rootFileInfo = calculateFolderSizesRecursively(atPath: folderPath)
    let folderSizeKB = rootFileInfo.sizeKB
    let folderSizeMB = Double(folderSizeKB) / 1024.0
    
    func printFileInfo(_ fileInfo: FileInfo, indent: String = "") {
        let sizeMB = Double(fileInfo.sizeKB) / 1024.0
        if sizeMB >= 1024 {
            let sizeGB = sizeMB / 1024.0
            print("\(indent)Total size of folder '\(fileInfo.name)': \(String(format: "%.2f", sizeGB))G")
        } else if sizeMB >= 1 {
            print("\(indent)Total size of folder '\(fileInfo.name)': \(String(format: "%.2f", sizeMB))M")
        } else {
            print("\(indent)Total size of folder '\(fileInfo.name)': \(String(format: "%.2f", Double(fileInfo.sizeKB)))K")
        }
        for subFile in fileInfo.subFiles {
            printFileInfo(subFile, indent: indent + "  ")
        }
    }
    
    printFileInfo(rootFileInfo)
}

main()
