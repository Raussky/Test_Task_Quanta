//
//  ContentView.swift
//  Test_Task_Quanta
//
//  Created by Rauan on 24.05.2024.
//

import SwiftUI
import Combine
import SDWebImage


struct ContentView: View {
    @ObservedObject var viewModel = PhotoViewModel()
    @State private var selectedPhoto: Photo?

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchText)
                GeometryReader { geometry in
                    let columns = [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ]
                    let isPortrait = geometry.size.width < geometry.size.height
                    let itemCount = isPortrait ? 1 : 3
                    
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: itemCount), spacing: 20) {
                            ForEach(viewModel.filteredPhotos) { photo in
                                VStack {
                                    AsyncImage(url: URL(string: photo.url), placeholder: Image(systemName: "photo"))
                                        .aspectRatio(contentMode: .fit)
                                        .onTapGesture {
                                            selectedPhoto = photo
                                        }
                                    Text(photo.title)
                                        .font(.caption)
                                        .lineLimit(1)
                                }
                                .onAppear {
                                    if photo == viewModel.photos.last {
                                        viewModel.loadPhotos()
                                    }
                                }
                            }
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .onAppear {
                                        viewModel.loadPhotos()
                                    }
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        viewModel.loadPhotos(reset: true)
                    }
                }
            }
            .navigationTitle("Photos")
            .sheet(item: $selectedPhoto) { photo in
                VStack {
                    AsyncImage(url: URL(string: photo.url), placeholder: Image(systemName: "photo"))
                        .aspectRatio(contentMode: .fit)
                    Text(photo.title)
                }
                .padding()
            }
        }
    }
}




#Preview {
    ContentView()
}
