import Foundation

struct FileInfo {
    var path: String
    var name: String
    var sizeKB: Int64
    var subFiles: [FileInfo]
}

// 使用 du 命令计算整个文件夹的大小（单位 KB）
func fastCalculateFolderSize(atPath path: String) -> Int64 {
    let task = Process()
    task.launchPath = "/usr/bin/du"
    task.arguments = ["-sk", path]

    let pipe = Pipe()
    task.standardOutput = pipe

    task.launch()
    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)

    if let output = output, let sizeString = output.split(separator: "\t").first, let size = Int64(sizeString) {
        return size
    } else {
        print("Error parsing output from du command for \(path)")
        return 0
    }
}

// 并行计算文件夹大小，避免递归耗时
func calculateFolderSizesRecursively(atPath path: String) -> FileInfo {
    let fileManager = FileManager.default
    var totalSize: Int64 = 0
    var subFiles: [FileInfo] = []

    do {
        let items = try fileManager.contentsOfDirectory(atPath: path)

        let queue = DispatchQueue.global(qos: .userInitiated)
        let group = DispatchGroup()

        var subFileResults: [FileInfo] = []
        let lock = NSLock() // 线程安全锁

        for item in items {
            let itemURL = URL(fileURLWithPath: path).appendingPathComponent(item)
            let itemPath = itemURL.path

            queue.async(group: group) {
                if let attributes = try? fileManager.attributesOfItem(atPath: itemPath) {
                    if attributes[.type] as? FileAttributeType == .typeDirectory {
                        // 直接用 du 计算子目录大小
                        let subSize = fastCalculateFolderSize(atPath: itemPath)
                        let subFileInfo = FileInfo(path: itemPath, name: item, sizeKB: subSize, subFiles: [])
                        lock.lock()
                        subFileResults.append(subFileInfo)
                        totalSize += subSize
                        lock.unlock()
                    } else if let fileSize = attributes[.size] as? Int64 {
                        let sizeKB = fileSize / 1024
                        let fileInfo = FileInfo(path: itemPath, name: item, sizeKB: sizeKB, subFiles: [])
                        lock.lock()
                        subFileResults.append(fileInfo)
                        totalSize += sizeKB
                        lock.unlock()
                    }
                }
            }
        }

        // 等待所有任务完成
        group.wait()
        subFiles = subFileResults
    } catch {
        print("Error reading directory at path \(path): \(error)")
    }

    return FileInfo(path: path, name: URL(fileURLWithPath: path).lastPathComponent, sizeKB: totalSize, subFiles: subFiles)
}

// 主函数
func main() {
    let arguments = CommandLine.arguments
    guard arguments.count > 1 else {
        print("Usage: \(arguments[0]) <folder_path>")
        exit(1)
    }

    let folderPath = arguments[1]
    let rootFileInfo = calculateFolderSizesRecursively(atPath: folderPath)
    
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
    }

    printFileInfo(rootFileInfo)
    print(rootFileInfo.subFiles)
}

main()
