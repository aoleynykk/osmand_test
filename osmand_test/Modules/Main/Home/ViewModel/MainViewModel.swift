//
//  MainViewModel.swift
//  osmand_test
//
//  Created by Alex Oliynyk on 20.02.2025.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
    @Published var freeSpace: String = "Calculating..."
    @Published var regions: [Region] = []

    private let xmlParser = RegionParser()

    init() {
        loadRegions()
    }

    func loadRegions() {
        if let url = Bundle.main.url(forResource: "regions", withExtension: "xml"),
           let data = try? Data(contentsOf: url) {
            DispatchQueue.global(qos: .background).async {
                let parsedRegions = self.xmlParser.parse(xmlData: data)
                DispatchQueue.main.async {
                    self.regions = parsedRegions
                }
            }
        }
    }

    func downloadFile(from url: URL) {
        let task = URLSession.shared.downloadTask(with: url) { localURL, _, _ in
            if let localURL = localURL {
                self.saveFile(from: localURL, name: url.lastPathComponent)
            }
        }
        task.resume()
    }

    private func saveFile(from location: URL, name: String) {
        let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(name)
        try? FileManager.default.moveItem(at: location, to: destinationURL)
    }
}
