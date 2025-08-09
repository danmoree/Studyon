//
//  ProfilePicSettingsView.swift
//  Studyon
//
//  Created by Daniel Moreno on 8/7/25.
//

import SwiftUI
import PhotosUI

struct ProfilePicSettingsView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @EnvironmentObject var userVM: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var pickedImage: UIImage?
    @State private var pickerItem: PhotosPickerItem?
    @State private var isUploading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Change Profile Picture")
                .font(.title2)
                .bold()

            // Current or selected profile image
            ZStack {
                if let img = userVM.profileImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                } else {
                    Circle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                        )
                }
                if isUploading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.4)
                }
            }

            PhotosPicker(selection: $pickerItem, matching: .images) {
                Text("Select Photo")
            }
            .onChange(of: pickerItem) { newItem in
                if let item = newItem {
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let uiImg = UIImage(data: data) {
                            pickedImage = uiImg
                            errorMessage = nil
                        } else {
                            errorMessage = "Failed to load image."
                        }
                    }
                }
            }

            Button("Upload Photo") {
                Task {
                    await uploadProfilePic()
                    await userVM.loadProfileImage()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(pickedImage == nil || isUploading)

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }

    private func uploadProfilePic() async {
        guard let image = pickedImage, let data = image.jpegData(compressionQuality: 1.0) else {
            errorMessage = "No image selected or image data invalid."
            return
        }
        isUploading = true
        errorMessage = nil
        do {
            try await settingsVM.changeProfilePic(imageData: data)
            errorMessage = "Success!"
            pickedImage = nil
            pickerItem = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        isUploading = false
    }
}

#Preview {
    ProfilePicSettingsView(settingsVM: SettingsViewModel())
        .environmentObject(ProfileViewModel())
}

