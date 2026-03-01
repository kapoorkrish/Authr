//
//  DemoSheet.swift
//  
//
//  Created by Krish Kapoor on 2/28/26.
//

import SwiftUI

struct DemoPickerSheet: View {
    @Environment(\.dismiss) var dismiss
    var onSelect: (UIImage) -> Void
    
    let demoNames = ["sig1", "sig2", "sig3"]
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 20)]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(demoNames, id: \.self) { name in
                        if let image = UIImage(named: name) ?? UIImage(named: "\(name).jpg") {
                            Button(action: {
                                onSelect(image)
                                dismiss()
                            }) {
                                VStack {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 80)
                                        .padding()
                                    
                                    Text(name.capitalized)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                        .padding(.bottom, 10)
                                }
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(15)
                                .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                            }
                            .buttonStyle(.plain)
                        } else {
                            // Fallback UI
                            VStack {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text("\(name) missing")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(height: 120)
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(15)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Select Demo Signature")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        }
    }
}
