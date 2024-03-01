//
//  CommonComponent.swift
//  passwd
//
//  Created by Leslie D on 2024/3/2.
//

import SwiftUI

struct TextBorder: View {
    
    var editable: Bool = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .strokeBorder(
                Color.gray,
//                LinearGradient(
//                    gradient: .init(colors: [
//                        Color.gray,
//                        Color.blue
//                    ]),
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                ),
                lineWidth: editable ? 2 : 0.8
            )
    }
}

