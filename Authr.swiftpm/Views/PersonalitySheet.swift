//
//  PersonalitySheet.swift
//  
//
//  Created by Krish Kapoor on 2/28/26.
//
import SwiftUI

public struct PersonalitySheet: View {
    @ObservedObject var viewModel: SignatureViewModel
    @Binding var isPresented: Bool
    let personalities: [Personality] = Personality.allCases
    
    public var body: some View {
        NavigationStack {
            List(personalities, id: \.self) { type in
                Button(action: {
                    viewModel.personality = type
                    isPresented = false
                }) {
                    HStack(alignment: .center, spacing: 15) {
                        Text(String(describing: type).uppercased())
                            .font(.system(.headline, design: .monospaced))
                            .frame(width: 55, alignment: .leading)
                            .foregroundColor(.primary)
                        
                        Text(type.traitDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        if viewModel.personality == type {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(UIColor.systemCyan))
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Select Personality")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { isPresented = false }
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
