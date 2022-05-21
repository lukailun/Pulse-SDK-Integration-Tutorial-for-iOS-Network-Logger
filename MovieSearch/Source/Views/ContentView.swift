import PulseUI
import SwiftUI

struct ContentView: View {
    @StateObject
    private var viewModel = MovieListViewModel()
    @State
    private var showingSheet = false

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.loading {
                    ProgressView("Loading....")
                        .padding()
                }
                List(viewModel.movieList) { movie in
                    NavigationLink {
                        MovieDetailView(movie: movie)
                    } label: {
                        MovieRowView(movie: movie)
                    }
                }
                .listStyle(.grouped)
                .navigationTitle("Movies")
                .searchable(text: $viewModel.searchText, prompt: "Search")
                .sheet(isPresented: $showingSheet) {
                    MainView()
                }
                .onSubmit(of: .search) {
                    viewModel.search()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingSheet = true
                        } label: {
                            Image(systemName: "wifi")
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
