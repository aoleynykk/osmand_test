//
//  ContentView.swift
//  osmand_test
//
//  Created by Alex Oliynyk on 20.02.2025.
//

import SwiftUI

let coloredNavAppearance = UINavigationBarAppearance()

struct MainView: View {

    @ObservedObject private var viewModel = MainViewModel()

    init() {
        setupNavigationBarAppearance()
    }

    var body: some View {
        NavigationView {
            List {
                memoryView
                regionList
                Spacer()
            }
            .listStyle(.plain)
            .background(Color.gray.opacity(0.1))
            .navigationBarTitle("Download Maps")
        }
        .accentColor(.white)
        .ignoresSafeArea()
    }

    private var regionList: some View {
        ForEach(viewModel.regions) { region in
            Section {
                subregionList(for: region)
            } header: {
                regionHeader(for: region)
            }
        }
    }

    private func subregionList(for region: Region) -> some View {
        let subregions = region.subregions ?? []

        return ForEach(Array(subregions.enumerated()), id: \.element.id) { index, subregion in
            Group {
                if subregion.hasSubregions {
                    NavigationLink(destination: RegionView(region: subregion)) {
                        RegionRow(region: subregion)
                    }
                } else {
                    RegionRow(region: subregion)
                }
            }
            .listRowBackground(Color.cellBackground)
            .listRowSeparator((index + 1) % 2 == 0 ? .visible : .hidden)
            .listRowSeparatorTint(.separator)
        }
    }

    private func regionHeader(for region: Region) -> some View {
        VStack {
            Spacer()
            HStack {
                Text(region.name.uppercased())
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

    private var memoryView: some View {
        VStack {
            HStack {
                Text("Device memory")
                Spacer()
                Text(String(format: "Free %.2f Gb", UIDevice.current.freeDiskSpace))
            }
            .foregroundStyle(.black)
            .font(.system(size: 14, weight: .regular))

            LinearProgressView(
                value: UIDevice.current.usedDiskSpace,
                total: UIDevice.current.totalDiskSpace,
                shape: Capsule()
            )
            .frame(height: 18)
            .tint(.navigationBar)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        .listRowSeparator(.visible)
        .listRowSeparatorTint(.separator)
        .listRowInsets(EdgeInsets())
    }
}

extension MainView {
    private func setupNavigationBarAppearance() {
        coloredNavAppearance.configureWithOpaqueBackground()
        coloredNavAppearance.backgroundColor = .navigationBar
        coloredNavAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredNavAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = coloredNavAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredNavAppearance
    }
}
