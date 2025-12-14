//
//  StartScreen.swift
//  accApps
//
//  Created by Jana Abdulaziz Malibari on 02/12/2025.
//
import SwiftUI

struct StartScreen: View {
    // Keep storage, but do not default to a route here.
    @AppStorage(LastRouteKey.key) private var lastRouteRaw: String = ""
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false
    
    @State private var navigateToUCS = false
    @State private var navigateToACS = false
    
    var body: some View {
        NavigationStack{
            ZStack{
                Image("splash")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack{
                    logo()
                        .padding(30)
                    
                    // Use a plain NavigationLink as the tappable control
                    NavigationLink {
                        TargetUsers()
                    } label: {
                        Text("Start")
                            .frame(width: 300, height: 60)
                            .font(.custom("Rubik-Medium", size: 20))
                            .foregroundColor(.primary)
                            .glassEffect(
                                .clear
                                    .interactive()
                                    .tint(Color(red: 191/255, green: 234/255, blue: 242/255)),
                                in: .rect(cornerRadius: 17)
                            )
                            .padding()
                            .offset(y: 60)
                    }

                    // Hidden navigation triggers (programmatic routing)
                    NavigationLink("", isActive: $navigateToUCS) { UCSView() }
                        .hidden()
                    NavigationLink("", isActive: $navigateToACS) { ACSView() }
                        .hidden()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Auto-route if a last route has been saved by TargetUsers
            if lastRouteRaw == Route.ucs.rawValue {
                navigateToUCS = true
            } else if lastRouteRaw == Route.acs.rawValue {
                navigateToACS = true
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
            .offset(y: -60)
    }
}

#Preview {
    StartScreen()
}
