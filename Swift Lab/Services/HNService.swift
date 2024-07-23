//
//  HNService.swift
//  Swift Lab
//
//  Created by Tom Hill on 23/7/2024.
//

import Foundation
import Alamofire

struct Story: Codable {
    let id: Int
    let url: URL
    let title: String
}

class HNService: ObservableObject {
    @Published var stories: [Story] = []
    @Published var isLoading = false
    
    private let baseURL = "https://hacker-news.firebaseio.com/v0"
    
    func getTopStories() {
        guard !isLoading else { return }
        
        isLoading = true
        debugPrint("Fetching Top Stories")
        
        AF.request("\(baseURL)/topstories.json").responseDecodable(of: [Int].self) { [weak self] response in
            switch response.result {
            case .success(let storyIDs):
                let topStoryIDs = Array(storyIDs.prefix(20))
                self?.fetchStories(ids: topStoryIDs)
            case .failure(let error):
                print("Error fetching top stories: \(error)")
                self?.isLoading = false
            }
        }
    }
    
    private func fetchStories(ids: [Int]) {
        let group = DispatchGroup()
        var fetchedStories: [Story] = []
        
        for id in ids {
            group.enter()
            AF.request("\(baseURL)/item/\(id).json").responseDecodable(of: Story.self) { response in
                defer { group.leave() }
                
                switch response.result {
                case .success(let story):
                    fetchedStories.append(story)
                case .failure(let error):
                    print("Error fetching story \(id): \(error)")
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.stories = fetchedStories.sorted(by: { $0.id < $1.id })
            self?.isLoading = false
        }
    }
}
