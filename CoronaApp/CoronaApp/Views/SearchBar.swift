//
//  SearchBar.swift
//  CoronaApp
//
//  Created by Gleb Radchenko on 29.11.20.
//

import SwiftUI

struct SearchBar: View {
    let placeholder: String
    @Binding var text: String
    @Binding var isEditing: Bool

    var body: some View {
        HStack {
            TextField(
                placeholder,
                text: $text,
                onEditingChanged: { isEditing in
                    self.isEditing = isEditing
                },
                onCommit: { print("commit") }
            )
            .padding(8)
            .padding(.horizontal, 24)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .animation(.linear)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 8)

                    if !text.isEmpty {
                        Button(action: { text = "" }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                        }
                    }
                }
            )

            if isEditing || !text.isEmpty {
                Button(
                    action: {
                        isEditing = false
                        text = ""
                    },
                    label: { Text("Cancel") }
                )
                .transition(.move(edge: .trailing))
                .animation(.linear)
            }
        }
        .padding()
    }
}


struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(
            placeholder: "Search",
            text: .constant(""),
            isEditing: .constant(false)
        )
    }
}
