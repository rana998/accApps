//
//  StartScreen.swift
//  accApps
//
//  Created by Jana Abdulaziz Malibari on 02/12/2025.
//
import SwiftUI

struct StartScreen: View {
    @AppStorage(LastRouteKey.key) private var lastRouteRaw: String = Route.ucs.rawValue
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false
    
    @State private var navigateToUCS = false
    @State private var navigateToACS = false
    
    var body: some View {
        NavigationStack{
            ZStack{
                Image("splash")
                    .ignoresSafeArea()
                VStack{
                    splashScreen()
                    // Hidden navigation triggers
                    NavigationLink("", isActive: $navigateToUCS) { UCSView() }
                        .hidden()
                    NavigationLink("", isActive: $navigateToACS) { ACSView() }
                        .hidden()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Only auto-route after the first launch
            if hasLaunchedBefore {
                if Route(rawValue: lastRouteRaw) == .acs {
                    navigateToACS = true
                } else {
                    navigateToUCS = true
                }
            } else {
                // First launch: show StartScreen
                hasLaunchedBefore = true
            }
        }
    }
}

struct splashScreen: View {
    var body: some View {
        ZStack{
            logo()
            NavigationLink(destination: TargetUsers()){
                Button("Start"){
                }
                .frame(width: 300, height: 60)
                .font(.custom("Rubik-Medium", size: 20))
                .foregroundColor(.primary)
                .glassEffect(.clear.interactive().tint(Color(red: 191/255, green: 234/255, blue: 242/255)), in: .rect(cornerRadius: 17))
                .padding()
                .position(x: 600, y: 600)
            }
            
        }
    }
}

struct logo: View {
    @State private var swoop = false
    var body: some View {
        Image("Logo")
            .resizable()
            .frame(width: 256, height: 256)
            .position(x:600 ,y: 300)
            .scaleEffect(swoop ? 0.1: 1.0)
            .animation(.easeInOut(duration: 1.0), value: swoop)
    }
}

#Preview {
    StartScreen()
}
