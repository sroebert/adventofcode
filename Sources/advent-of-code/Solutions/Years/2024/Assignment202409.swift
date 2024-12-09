struct Assignment202409: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let diskMap = try await getDiskMap()
        return calculateDefragmentedChecksum(diskMap)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let diskMap = try await getDiskMap()
        return calculateDefragmentedChecksum(diskMap, moveWholeFilesOnly: true)
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    var isSlowInRelease: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private struct Checksum {
        private(set) var value: Int = 0
        private var diskIndex: Int = 0
        
        mutating func add(fileId: Int, blocks: Int) {
            guard blocks > 0 else {
                return
            }
            
            diskIndex -= 1
            let sumStart = (diskIndex * (diskIndex + 1)) / 2
            
            diskIndex += blocks
            let sumEnd = (diskIndex * (diskIndex + 1)) / 2
            
            diskIndex += 1
            value += (sumEnd - sumStart) * fileId
        }
        
        mutating func skipEmptyBlocks(_ count: Int) {
            diskIndex += count
        }
    }
    
    private func calculateDefragmentedChecksum(_ diskMap: [Int], moveWholeFilesOnly: Bool = false) -> Int {
        var diskMap = diskMap
        var movedWholeFileIds = Set<Int>()
        
        var leftIndex = 0
        var leftFileId = 0
        
        var rightIndex = diskMap.count - 1 - (diskMap.count % 2 == 0 ? 1 : 0)
        var rightFileId = rightIndex / 2
        
        var checksum = Checksum()
        while leftIndex < rightIndex {
            // Add left file block to the checksum
            if movedWholeFileIds.contains(leftFileId) {
                checksum.skipEmptyBlocks(diskMap[leftIndex])
            } else {
                checksum.add(fileId: leftFileId, blocks: diskMap[leftIndex])
            }
            
            // Fill empty space with right files and add to checksum
            while leftIndex < rightIndex && diskMap[leftIndex + 1] > 0 {
                
                if moveWholeFilesOnly {
                    // Find right most file that fits
                    var searchIndex = rightIndex
                    var searchFileId = rightFileId
                    while searchIndex > leftIndex && (movedWholeFileIds.contains(searchFileId) || diskMap[searchIndex] > diskMap[leftIndex + 1]) {
                        searchIndex -= 2
                        searchFileId -= 1
                    }
                    
                    // If we found a file that fits, move and add checksum
                    if searchIndex > leftIndex {
                        checksum.add(fileId: searchFileId, blocks: diskMap[searchIndex])
                        diskMap[leftIndex + 1] -= diskMap[searchIndex]
                        movedWholeFileIds.insert(searchFileId)
                        
                        // Move right index
                        while diskMap[rightIndex] == 0 {
                            rightIndex -= 2
                            rightFileId -= 1
                        }
                        
                    } else {
                        // Otherwise skip the empty space (no whole file fits)
                        checksum.skipEmptyBlocks(diskMap[leftIndex + 1])
                        break
                    }
                } else if diskMap[rightIndex] > diskMap[leftIndex + 1] {
                    // Right file is too large for the empty space, move as much as we can
                    checksum.add(fileId: rightFileId, blocks: diskMap[leftIndex + 1])
                    diskMap[rightIndex] -= diskMap[leftIndex + 1]
                    diskMap[leftIndex + 1] = 0
                } else {
                    // Right file fits in the space (and possibly more)
                    checksum.add(fileId: rightFileId, blocks: diskMap[rightIndex])
                    diskMap[leftIndex + 1] -= diskMap[rightIndex]
                    diskMap[rightIndex] = 0
                    
                    // Right file has been moved, go to next file
                    rightIndex -= 2
                    rightFileId -= 1
                }
            }
            
            // Move index
            leftIndex += 2
            leftFileId += 1
        }
        
        // Add final left file
        if !movedWholeFileIds.contains(leftFileId) {
            checksum.add(fileId: leftFileId, blocks: diskMap[leftIndex])
        }
        
        return checksum.value
    }
    
    private func getDiskMap() async throws -> [Int] {
        try await getInput()
            .trimming(while: \.isWhitespace)
            .compactMap(\.wholeNumberValue)
    }
}
