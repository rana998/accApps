//
//  SplashScreen.swift
//  accApps
//
//  Created by رغد الجريوي on 27/11/2025.
//
import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    
    var body: some View {
        ZStack {
          
            Image("splash")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
        }
        .onAppear {
            isActive = true
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isActive = false
                }
            }
        }
    }
}

#Preview {
    SplashScreen()
}

