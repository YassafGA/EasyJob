//
//  CompanyTabView.swift
//  EasyJob
//
//  Created by MAC on 25.12.2025.
//


import SwiftUI

struct CompanyTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                MyJobPostsView()
            }
            .tabItem { Label("İlanlarım", systemImage: "briefcase") }

            NavigationStack {
                CreateJobPostView()
            }
            .tabItem { Label("Yeni İlan", systemImage: "plus.circle") }

            NavigationStack {
                CompanyApplicationsView()
            }
            .tabItem { Label("Başvurular", systemImage: "tray.full") }

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Profil", systemImage: "person") }
        }
    }
}
