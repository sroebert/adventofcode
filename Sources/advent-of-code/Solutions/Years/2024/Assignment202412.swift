struct Assignment202412: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let plot = try await getGardenPlot()
        return calculatePlotPrices(plot: plot).perimeterPrice
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let plot = try await getGardenPlot()
        return calculatePlotPrices(plot: plot).sidePrice
    }
    
    // MARK: - Utils
    
    private func getGardenPlot() async throws -> [[Character]] {
        let borderCharacter: Character = "."
        let plot = try await mapInput {
            [borderCharacter] + $0 + [borderCharacter]
        }
        
        let border = [Array(repeating: borderCharacter, count: plot[0].count)]
        return border + plot + border
    }
    
    private func calculatePlotPrices(plot: [[Character]]) -> (perimeterPrice: Int, sidePrice: Int) {
        let size = plot.count
        
        var regionCount = 1
        var regionIds = Array(repeating: Array(repeating: 0, count: size), count: size)
        var childRegionIds: [Int] = [0]
        var parentRegionIds: [Int] = [0]
        var regionAreaSizes: [Int] = [0]
        var regionPerimeterLengths: [Int] = [0]
        
        var regionSidesCount: [Int] = [0]
        
        let range = 1..<size
        for y in range {
            for x in range {
                let point = Point(x: x, y: y)
                let letter = plot[point.y][point.x]
                
                let northPoint = point.north
                let northId = regionIds[northPoint.y][northPoint.x]
                let northLetter = plot[northPoint.y][northPoint.x]
                let isNorthPartOfRegion = northLetter == letter
                if isNorthPartOfRegion {
                    regionIds[point.y][point.x] = northId
                } else {
                    regionPerimeterLengths[northId] += 1
                }
                
                let westPoint = point.west
                let westId = regionIds[westPoint.y][westPoint.x]
                let westLetter = plot[westPoint.y][westPoint.x]
                let isWestPartOfRegion = westLetter == letter
                if isWestPartOfRegion {
                    regionIds[point.y][point.x] = westId
                } else {
                    regionPerimeterLengths[westId] += 1
                }
                
                if isNorthPartOfRegion && isWestPartOfRegion {
                    if northId != westId {
                        // Merge regions
                        var idToMergeFrom = northId
                        var idToMergeTo = westId
                        while parentRegionIds[idToMergeFrom] > 0 {
                            idToMergeFrom = parentRegionIds[idToMergeFrom]
                        }
                        while parentRegionIds[idToMergeTo] > 0 {
                            idToMergeTo = parentRegionIds[idToMergeTo]
                        }
                        
                        if idToMergeFrom != idToMergeTo {
                            idToMergeFrom = northId
                            while childRegionIds[idToMergeFrom] > 0 {
                                idToMergeFrom = childRegionIds[idToMergeFrom]
                            }
                            
                            childRegionIds[idToMergeFrom] = idToMergeTo
                            parentRegionIds[idToMergeTo] = idToMergeFrom
                        }
                    }
                    regionAreaSizes[northId] += 1
                } else if !isNorthPartOfRegion && !isWestPartOfRegion {
                    regionIds[point.y][point.x] = regionCount
                    regionAreaSizes.append(1)
                    regionPerimeterLengths.append(2)
                    regionSidesCount.append(0)
                    parentRegionIds.append(0)
                    childRegionIds.append(0)
                    regionCount += 1
                } else if isNorthPartOfRegion {
                    regionAreaSizes[northId] += 1
                    regionPerimeterLengths[northId] += 1
                } else {
                    regionAreaSizes[westId] += 1
                    regionPerimeterLengths[westId] += 1
                }
                
                let regionId = regionIds[point.y][point.x]
                
                if !isNorthPartOfRegion {
                    let northWestLetter = plot[point.y - 1][point.x - 1]
                    
                    // Check for current region
                    if !isWestPartOfRegion || letter == northWestLetter {
                        regionSidesCount[regionId] += 1
                    }
                    
                    // Check for north region
                    if northLetter != northWestLetter || westLetter == northLetter {
                        regionSidesCount[northId] += 1
                    }
                }
                
                if !isWestPartOfRegion {
                    let northWestLetter = plot[point.y - 1][point.x - 1]
                    
                    // Check for current region
                    if !isNorthPartOfRegion || letter == northWestLetter {
                        regionSidesCount[regionId] += 1
                    }
                    
                    // Check for west region
                    if westLetter != northWestLetter || westLetter == northLetter {
                        regionSidesCount[westId] += 1
                    }
                }
            }
        }
        
        return (1..<regionCount).reduce((0, 0)) { prices, regionId in
            guard parentRegionIds[regionId] == 0 else {
                return prices
            }
            
            var areaSize = regionAreaSizes[regionId]
            var perimeterLength = regionPerimeterLengths[regionId]
            var sidesCount = regionSidesCount[regionId]
            
            var currentRegionId = regionId
            while childRegionIds[currentRegionId] > 0 {
                currentRegionId = childRegionIds[currentRegionId]
                
                areaSize += regionAreaSizes[currentRegionId]
                perimeterLength += regionPerimeterLengths[currentRegionId]
                sidesCount += regionSidesCount[currentRegionId]
            }
            
            return (
                prices.perimeterPrice + areaSize * perimeterLength,
                prices.sidePrice + areaSize * sidesCount
            )
        }
    }
}
