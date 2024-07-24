//
//  HNView.swift
//  Swift Lab
//
//  Created by Tom Hill on 23/7/2024.
//

import SwiftUI
import WebKit

struct HNView: View {
    
    // You need to create and manage a reference type object (class) that conforms to ObservableObject.
    // The object needs to persist for the lifetime of the view.
    // You're creating the object, not just using one passed to you.
    @StateObject private var hnService = HNService()
    @State private var dataLoaded = false
    @State private var selectedURL: IdentifiableURL?
    
    var body: some View {
        Group {
            if hnService.stories.isEmpty {
                ProgressView("Loading...")
            } else {
                List(hnService.stories, id: \.id) { story in
                    StoryRow(
                        story: story,
                        onOpenWebView: { url in
                            selectedURL = IdentifiableURL(url: url)
                        },
                        onOpenSafari: { url in
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    )
                }
                .listStyle(.plain)
                .refreshable {
                    hnService.getTopStories()
                }
            }
        }
        .navigationTitle("Top HN")
        .onAppear {
            if hnService.stories.isEmpty {
                Task {
                    hnService.getTopStories()
                    withAnimation {
                        dataLoaded = true
                    }
                }
            }
        }
        .sheet(item: $selectedURL) { identifiableUrl in
            WebView(url: identifiableUrl.url)
        }
    }
}

struct StoryRow: View {
    let story: Story
    let onOpenWebView: (URL) -> Void
    let onOpenSafari: (URL) -> Void
    
    var body: some View {
        HStack {
            if let score = story.score {
                Text("\(score)")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .frame(width: 50, alignment: .leading)
                    .contentTransition(.numericText())
                    .scaleEffect(1)
                    .opacity(1)
                    .animation(.easeInOut(duration: 0.5), value: score)
            } else {
                Text("?")
                    .frame(width: 50, alignment: .leading)
            }
            Button(action: {
                onOpenWebView(story.url)
            }) {
                Text(story.title)
            }
        }
        .swipeActions {
            Button {
                onOpenSafari(story.url)
            } label: {
                Label("Open in Safari", systemImage: "safari")
            }
            .tint(.blue)
        }
    }
}

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

#Preview {
    HNView()
}
