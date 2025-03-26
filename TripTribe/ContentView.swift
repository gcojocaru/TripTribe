//
//  ContentView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 26.03.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    
    var body: some View {
        Group {
            if authViewModel.isLoading {
                LoadingView()
            } else if authViewModel.user != nil {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
    }
}
#Preview {
    ContentView()
}
