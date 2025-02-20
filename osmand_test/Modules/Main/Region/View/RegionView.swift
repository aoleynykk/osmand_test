//
//  RegionView.swift
//  osmand_test
//
//  Created by Alex Oliynyk on 20.02.2025.
//

import SwiftUI

struct RegionView: View {

    var region: Region

    var body: some View {
        VStack {
            regionList
        }
        .navigationTitle(region.name.capitalized)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var regionList: some View {
        List {
            Section {
                subregionList()
            } header: {
                regionHeader
            }
        }
        .background(Color.gray.opacity(0.1))
        .listStyle(.plain)
    }

    private func subregionList() -> some View {
        let subregions = region.subregions ?? []

        return ForEach(Array(subregions.enumerated()), id: \.element.id) { index, subregion in
            RegionRow(region: subregion)
                .listRowBackground(Color.cellBackground)
                .listRowSeparator((index + 1) % 2 == 0 ? .visible : .hidden)
                .listRowSeparatorTint(.separator)
        }
    }

    private var regionHeader: some View {
        VStack {
            Spacer()
            HStack {
                Text("Regions")
                    .foregroundStyle(.gray)
                    .font(.system(size: 13, weight: .regular))
                Spacer()
            }
            .padding(.leading, 16)
            .padding(.bottom, 8)
        }
        .listRowSeparator(.visible)
        .listRowSeparatorTint(.separator)
        .listRowInsets(EdgeInsets())
    }
}
