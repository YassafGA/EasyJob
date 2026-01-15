import SwiftUI

struct CandidateTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                JobListView()
            }
            .tabItem { Label("İşler", systemImage: "magnifyingglass") }

            NavigationStack {
                MyApplicationsView()
            }
            .tabItem { Label("Başvurular", systemImage: "tray.full") }

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Profil", systemImage: "person") }

            NavigationStack {
                CVBuilderView()
            }
            .tabItem { Label("CV", systemImage: "doc") }
        }
    }
}
