//
//  HNView.swift
//  Swift Lab
//
//  Created by Tom Hill on 23/7/2024.
//

import SwiftUI

struct HNView: View {
    
    // You need to create and manage a reference type object (class) that conforms to ObservableObject.
    // The object needs to persist for the lifetime of the view.
    // You're creating the object, not just using one passed to you.
    @StateObject private var hnService = HNService()
    
    var body: some View {
        Group {
            if hnService.stories.isEmpty {
                ProgressView("Loading...")
            } else {
                List(hnService.stories, id: \.id) { story in
                    Button(story.title) {
                        UIApplication.shared.open(story.url)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Top HN")
        .refreshable {
            hnService.getTopStories()
        }
        .onAppear {
            if hnService.stories.isEmpty {
                Task {
                    hnService.getTopStories()
                }
            }
        }
    }
}

#Preview {
    HNView()
}
