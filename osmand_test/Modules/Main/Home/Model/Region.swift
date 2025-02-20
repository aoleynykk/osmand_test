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
        guard isAvailableToDownload, let suffix = downloadSuffix else { return nil }

        let formattedName = name.prefix(1).capitalized + name.dropFirst()
        return URL(string: "https://download.osmand.net/download?standard=yes&file=\(formattedName)_\(suffix)_2.obf.zip")
    }
}
