//
//  CVBuildFlowView.swift
//  EasyJob
//
//  Created by MAC on 26.12.2025.
//


import SwiftUI

struct CVBuildFlowView: View {
    @StateObject private var vm = CVBuildFlowViewModel()
    @State private var showShare = false

    var body: some View {
        VStack(spacing: 16) {
            Text("CV Oluştur")
                .font(.title2).bold()

            if let s = vm.statusText {
                Text(s).foregroundStyle(.secondary)
            }

            if let err = vm.errorMessage {
                Text(err).foregroundStyle(.red)
            }

            Button {
                Task {
                    await vm.buildCV(templateFileName: "cv_template", templateExt: "docx", profileImageData: nil)
                    if vm.generatedDocxURL != nil {
                        showShare = true
                    }
                }
            } label: {
                Text(vm.isWorking ? "Hazırlanıyor..." : "Bilgilerimden CV Otomatik Oluştur")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.isWorking)

            if let url = vm.generatedDocxURL {
                Button {
                    showShare = true
                } label: {
                    Text("CV’yi Paylaş / Dosyalara Kaydet")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Text("Dosya: \(url.lastPathComponent)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showShare) {
            if let url = vm.generatedDocxURL {
                ActivityView(items: [url])
            } else {
                Text("Dosya bulunamadı")
            }
        }
    }
}
