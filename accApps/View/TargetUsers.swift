//  TargetUsers.swift
//  accApps
//
//  Created by sumaya alawad on 12/06/1447 AH.
//

import SwiftUI

struct TargetUsers: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Image("splash")
                    .ignoresSafeArea()
                
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Text("Choose a level")
                            .font(.custom("Rubik-Medium", size: 61))
                            .foregroundColor(.darkBlue)
                            .multilineTextAlignment(.center)
                            .padding(.top, 80)

                        Spacer()
                            .frame(height: geo.size.height * 0.20)

                        HStack(spacing: 170) {

                            NavigationLink(destination:
                                            UCSView()
                                                .navigationBarBackButtonHidden(true)
                            ) {
                                VStack {
                                    Image("Image1")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 169)

                                    Text("Unable to create a sentences")
                                        .font(.custom("Rubik-Medium", size: 24))
                                        .foregroundColor(.darkBlue)
                                        .padding(.bottom)
                                }
                                .frame(width: 257, height: 257)
                                .glassEffect(.clear.interactive().tint(Color.lightBlue), in: .rect(cornerRadius: 17))
                                .cornerRadius(40)
                            }

                            NavigationLink(destination:
                                            ACSView()
                                                .navigationBarBackButtonHidden(true)
                            ) {
                                VStack {
                                    Image("Image2")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 169)

                                    Text("Able to create a sentences")
                                        .font(.custom("Rubik-Medium", size: 24))
                                        .foregroundColor(.darkBlue)
                                        .padding(.bottom)

                                }
                                .frame(width: 257, height: 257)
                                .foregroundColor(.primary)
                                .glassEffect(.clear.interactive().tint(Color.lightBlue), in: .rect(cornerRadius: 17))
                                .cornerRadius(40)
                            }
                        }

                        Spacer()
                    }
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    TargetUsers()
}
