//
//  AddActivityView.swift
//  TripTribe
//
//  Created by Claude on 03.04.2025.
//

import SwiftUI
import PhotosUI

struct AddActivityView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ActivityViewModel
    @State private var showingImagePicker = false
    @State private var selectedItem: PhotosPickerItem?
    
    // Initialize with a trip ID for new activities
    init(tripId: String) {
        self._viewModel = StateObject(wrappedValue: ActivityViewModel(tripId: tripId))
    }
    
    // Initialize with an existing activity for editing
    init(activity: Activity) {
        self._viewModel = StateObject(wrappedValue: ActivityViewModel(activity: activity))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main Form
                ScrollView {
                    VStack(spacing: 24) {
                        // Activity Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Activity Name")
                                .font(.jakartaSans(16, weight: .medium))
                                .foregroundColor(.black)
                            
                            TextField("", text: $viewModel.activityName)
                                .font(.jakartaSans(16))
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                        
                        // Location
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Location")
                                .font(.jakartaSans(16, weight: .medium))
                                .foregroundColor(.black)
                            
                            HStack {
                                TextField("Location", text: $viewModel.location)
                                    .font(.jakartaSans(16))
                                    .padding()
                                
                                Button(action: {
                                    // Location action - could show map view
                                }) {
                                    Image(systemName: "mappin.circle")
                                        .font(.system(size: 24))
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 16)
                                }
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        
                        // Date & Time
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date & Time")
                                .font(.jakartaSans(16, weight: .medium))
                                .foregroundColor(.black)
                            
                            DatePicker("", selection: $viewModel.startDateTime, in: viewModel.validDateRange)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                        
                        // Duration
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Duration")
                                .font(.jakartaSans(16, weight: .medium))
                                .foregroundColor(.black)
                            
                            // Custom duration picker
                            Menu {
                                Button("30 minutes") { viewModel.duration = 30 }
                                Button("1 hour") { viewModel.duration = 60 }
                                Button("1.5 hours") { viewModel.duration = 90 }
                                Button("2 hours") { viewModel.duration = 120 }
                                Button("3 hours") { viewModel.duration = 180 }
                                Button("4 hours") { viewModel.duration = 240 }
                                Button("Full day (8 hours)") { viewModel.duration = 480 }
                                Button("Custom...") {
                                    // Show custom duration picker
                                }
                            } label: {
                                HStack {
                                    Text(viewModel.formattedDuration)
                                        .font(.jakartaSans(16))
                                        .foregroundColor(.black)
                                        .padding()
                                    
                                    Spacer()
                                    
                                    Image(systemName: "clock")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 16)
                                }
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                        
                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.jakartaSans(16, weight: .medium))
                                .foregroundColor(.black)
                            
                            Menu {
                                ForEach(Activity.ActivityCategory.allCases, id: \.self) { category in
                                    Button {
                                        viewModel.category = category
                                    } label: {
                                        Label(category.rawValue, systemImage: category.iconName)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(viewModel.category.rawValue)
                                        .font(.jakartaSans(16))
                                        .foregroundColor(.black)
                                        .padding()
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.up.chevron.down")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 16)
                                }
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                        
                        // Upload Photo
                        VStack(alignment: .leading, spacing: 8) {
                            Button(action: {
                                showingImagePicker = true
                            }) {
                                HStack {
                                    Text("Upload Photo")
                                        .font(.jakartaSans(16, weight: .medium))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    if viewModel.photoUIImage != nil {
                                        // Show a small thumbnail of the selected image
                                        Image(uiImage: viewModel.photoUIImage!)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 40, height: 40)
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                    } else {
                                        Image(systemName: "photo")
                                            .font(.system(size: 24))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                            .photosPicker(
                                isPresented: $showingImagePicker,
                                selection: $selectedItem,
                                matching: .images
                            )
                            .onChange(of: selectedItem) { item in
                                if let item = item {
                                    Task {
                                        if let data = try? await item.loadTransferable(type: Data.self),
                                           let uiImage = UIImage(data: data) {
                                            viewModel.didSelectImage(uiImage)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Add Link
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Add Link")
                                .font(.jakartaSans(16, weight: .medium))
                                .foregroundColor(.black)
                            
                            HStack {
                                TextField("https://", text: $viewModel.linkURL)
                                    .font(.jakartaSans(16))
                                    .keyboardType(.URL)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .padding()
                                
                                Button(action: {
                                    // Copy link action
                                    if !viewModel.linkURL.isEmpty,
                                       let url = URL(string: viewModel.linkURL) {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Image(systemName: "link")
                                        .font(.system(size: 24))
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 16)
                                }
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        
                        // Save Button
                        Button(action: {
                            Task {
                                await viewModel.saveActivity()
                            }
                        }) {
                            Text("Save")
                                .font(.jakartaSans(18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(AppConstants.Colors.primary)
                                .cornerRadius(28)
                        }
                        .disabled(viewModel.isLoading)
                        .padding(.top, 32)
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                // Loading overlay
                if viewModel.isLoading {
                    LoadingOverlayView()
                }
            }
            .navigationTitle("Add Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                // Set the dismiss handler
                viewModel.onDismiss = {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    // For preview purposes
    AddActivityView(tripId: "previewTripId")
}
