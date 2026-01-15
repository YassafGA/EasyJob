//
//  MyJobPostsView.swift
//  EasyJob
//
//  Created by MAC on 25.12.2025.
//


import SwiftUI

struct MyJobPostsView: View {
    @StateObject private var vm = CompanyPostsViewModel()

    @State private var showDeleteConfirm = false
    @State private var pendingDeletePost: JobPost?

    var body: some View {
        List {
            ForEach(vm.posts) { post in
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(post.title ?? "Başlık yok").font(.headline)
                        Text(meta(post)).font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(role: .destructive) {
                        pendingDeletePost = post
                        showDeleteConfirm = true
                    } label: {
                        Text("Sil")
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.vertical, 4)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        pendingDeletePost = post
                        showDeleteConfirm = true
                    } label: {
                        Text("Sil")
                    }
                }
            }
        }
        .overlay { if vm.isLoading { ProgressView() } }
        .navigationTitle("İlanlarım")
        .toolbar {
            Button { Task { await vm.fetchMyPosts() } } label: { Image(systemName: "arrow.clockwise") }
        }
        .task { await vm.fetchMyPosts() }
        .alert("İlan silinsin mi?", isPresented: $showDeleteConfirm) {
            Button("Vazgeç", role: .cancel) { pendingDeletePost = nil }
            Button("Sil", role: .destructive) {
                guard let post = pendingDeletePost else { return }
                Task {
                    do {
                        try await vm.deletePost(postId: post.id)
                        await vm.fetchMyPosts()
                        pendingDeletePost = nil
                    } catch {
                        vm.errorMessage = error.localizedDescription
                    }
                }
            }
        } message: {
            Text("Bu işlem geri alınamaz.")
        }
        .alert("Hata", isPresented: .constant(vm.errorMessage != nil)) {
            Button("Tamam") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    private func meta(_ post: JobPost) -> String {
        var parts: [String] = []
        if let loc = post.location, !loc.isEmpty { parts.append(loc) }
        if let wm = post.work_model, !wm.isEmpty { parts.append(wm) }
        if let s = post.seniority, !s.isEmpty { parts.append(s) }
        if let c = post.job_category, !c.isEmpty { parts.append(c) }
        return parts.joined(separator: " • ")
    }
}
