//
//  RegionXMPParser.swift
//  osmand_test
//
//  Created by Alex Oliynyk on 20.02.2025.
//

import Foundation

class RegionParser: NSObject, XMLParserDelegate {

    var regions: [Region] = []

    private var regionStack: [Region] = []

    func parse(xmlData: Data) -> [Region] {
        let parser = XMLParser(data: xmlData)
        parser.delegate = self
        parser.parse()
        return regions
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName: String?, attributes: [String : String] = [:]) {
        if elementName == "region", let name = attributes["name"] {
            let isAvailableToDownload = calculateDownloadAvailability(attributes: attributes)

            let parentDownloadSuffix = regionStack.last?.downloadSuffix
            let downloadSuffix = attributes["inner_download_suffix"] ?? parentDownloadSuffix

            let newRegion = Region(
                name: name,
                type: attributes["type"],
                translate: attributes["translate"],
                lang: attributes["lang"],
                downloadPrefix: attributes["inner_download_prefix"],
                downloadSuffix: downloadSuffix,
                isAvailableToDownload: isAvailableToDownload,
                subregions: []
            )

            regionStack.append(newRegion)
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName: String?) {
        if elementName == "region" {
            let finishedRegion = regionStack.popLast()

            if let parentRegion = regionStack.last {
                var updatedParent = parentRegion
                updatedParent.subregions?.append(finishedRegion!)
                regionStack[regionStack.count - 1] = updatedParent
            } else {
                regions.append(finishedRegion!)
            }
        }
    }
    
    private func calculateDownloadAvailability(attributes: [String: String]) -> Bool {
        let mapAttribute = attributes["map"]
        let typeAttribute = attributes["type"]
        return mapAttribute == "yes" || typeAttribute == "map"
    }
}
