//
//  Region.swift
//  osmand_test
//
//  Created by Alex Oliynyk on 20.02.2025.
//

import Foundation

struct Region: Identifiable {
    let id = UUID()
    let name: String
    let type: String?
    let translate: String?
    let lang: String?
    let downloadPrefix: String?
    let downloadSuffix: String?
    let isAvailableToDownload: Bool
    var subregions: [Region]?

    var hasSubregions: Bool {
        return !(subregions?.isEmpty ?? true)
    }

    var downloadURL: URL? {
        guard isAvailableToDownload, let preffix = downloadPrefix, let suffix = downloadSuffix else {
            return nil
        }

        let formattedPrefix = preffix.prefix(1).capitalized + preffix.dropFirst()
        
        return URL(string: "https://download.osmand.net/download?standard=yes&file=\(formattedPrefix)_\(name)_\(suffix)_2.obf.zip")
    }
}
