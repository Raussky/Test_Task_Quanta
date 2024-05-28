//
//  PhotoViewModel.swift
//  Test_Task_Quanta
//
//  Created by Rauan on 28.05.2024.
//
import SwiftUI
import Combine
import SDWebImage

class PhotoViewModel: ObservableObject {
    @Published var photos = [Photo]()
    @Published var searchText = ""
    @Published var isLoading = false
    private var cancellable: AnyCancellable?
    private var currentPage = 1
    private let pageSize = 30
    
    init() {
        loadPhotos()
    }
    
    func loadPhotos(reset: Bool = false) {
        if reset {
            photos.removeAll()
            currentPage = 1
        }
        
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/photos?_page=\(currentPage)&_limit=\(pageSize)") else { return }
        
        isLoading = true
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Photo].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newPhotos in
                self?.photos.append(contentsOf: newPhotos)
                self?.currentPage += 1
                self?.isLoading = false
            }
    }
    
    var filteredPhotos: [Photo] {
        if searchText.isEmpty {
            return photos
        } else {
            return photos.filter { $0.title.contains(searchText) }
        }
    }
}

class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
    
    private init() {}
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let url: URL?
    private var cancellable: AnyCancellable?
    
    init(url: URL?) {
        self.url = url
    }
    
    func load() {
        guard let url = url else { return }
        
        if let cachedImage = ImageCache.shared.object(forKey: url as NSURL) {
            self.image = cachedImage
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.image = image
                if let image = image {
                    ImageCache.shared.setObject(image, forKey: url as NSURL)
                }
            }
    }
    
    deinit {
        cancellable?.cancel()
    }
}

struct AsyncImage: View {
    @StateObject private var loader: ImageLoader
    var placeholder: Image
    
    init(url: URL?, placeholder: Image = Image(systemName: "photo")) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
        self.placeholder = placeholder
    }
    
    var body: some View {
        image
            .onAppear(perform: loader.load)
    }
    
    private var image: some View {
        Group {
            if let uiImage = loader.image {
                Image(uiImage: uiImage)
                    .resizable()
            } else {
                placeholder
            }
        }
    }
}
