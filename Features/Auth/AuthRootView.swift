//
//  AuthRootView.swift
//  EasyJob
//
//  Created by MAC on 25.12.2025.
//


import SwiftUI

struct AuthRootView: View {
    @State private var segment = 0

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.98, green: 0.93, blue: 0.86), Color(red: 0.86, green: 0.93, blue: 0.97)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        VStack(spacing: 6) {
                            Text("EasyJob")
                                .font(.system(size: 32, weight: .bold))
                            Text("Doğru işi daha hızlı bul")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 16)

                        Picker("", selection: $segment) {
                            Text("Giriş").tag(0)
                            Text("Kayıt").tag(1)
                        }
                        .pickerStyle(.segmented)

                        AuthCard {
                            if segment == 0 {
                                LoginView()
                            } else {
                                RegisterView()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("EasyJob")
        }
    }
}
