//
//  LinearProgressView.swift
//  osmand_test
//
//  Created by Alex Oliynyk on 20.02.2025.
//

import SwiftUI

struct LinearProgressView<Shape: SwiftUI.Shape>: View {
    var value: Double
    var total: Double
    var shape: Shape

    var body: some View {
        shape.fill(.foreground.quinary)
             .overlay(alignment: .leading) {
                 GeometryReader { proxy in
                     shape.fill(.tint)
                          .frame(width: proxy.size.width * value/total)
                 }
             }
             .clipShape(shape)
    }
}
