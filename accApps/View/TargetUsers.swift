//
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
                Color("Background")
                    .ignoresSafeArea()
                RoundedRectangle(cornerRadius: 16)
                    .glassEffect(.regular.tint(Color(red: 254/255, green: 226/255, blue: 136/255, opacity: 0.20)), in: .rect(cornerRadius: 16))
                    .frame(width: 105, height: 105)
                    .foregroundColor(.clear)
                    .rotationEffect(.degrees(-254), anchor: .leading)
                    .position(x: 1290, y: 490)
                Circle()
                    .glassEffect(.regular.tint(Color(red: 197/255, green: 238/255, blue: 161/255, opacity: 0.20)))
                    .frame(width: 250, height: 218)
                    .foregroundColor(.clear)
                    .position(x: 1190, y:20)
                Circle()
                    .glassEffect(.regular.tint(Color(red: 191/255, green: 234/255, blue: 242/255, opacity: 0.20)))
                    .frame(width: 200, height: 200)
                    .foregroundColor(.clear)
                    .position(x: 290, y: 120)
                triangle()
                    .glassEffect(.regular.tint(Color(red: 255/255, green: 197/255, blue: 163/255, opacity: 0.20)))
                    .clipShape(triangle())
                    .frame(width: 206, height: 181)
                    .foregroundColor(.clear)
                    .rotationEffect(.degrees(-65), anchor: .trailing)
                    .position(x: 50, y: 450)
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Text("Choose a level")
                            .font(.custom("Rubik-Medium", size: 61))
                            .foregroundColor(.darkBlue)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)

                        Spacer()
                            .frame(height: geo.size.height * 0.30)

                        HStack(spacing: 25) {

                            NavigationLink(destination:
                                            MainScreen()
                                                .navigationBarBackButtonHidden(true)
                            ) {
                                VStack {
                                    Image("Image1")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 120)

                                    Text("Unable to create a sentences")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.black)
                                }
                                .frame(width: 200, height: 250)
                                .foregroundColor(.primary)
                                .glassEffect(.clear.interactive().tint(Color(red: 191/255, green: 234/255, blue: 242/255)), in: .rect(cornerRadius: 17))
                                .cornerRadius(20)
                            }

                            NavigationLink(destination:
                                            SconedMainScreen()
                                                .navigationBarBackButtonHidden(true)
                            ) {
                                VStack {
                                    Image("Image2")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 120)

                                    Text("Able to create a sentences")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.black)
                                }
                                .frame(width: 200, height: 250)
                                .foregroundColor(.primary)
                                .glassEffect(.clear.interactive().tint(Color(red: 191/255, green: 234/255, blue: 242/255)), in: .rect(cornerRadius: 17))
                                .cornerRadius(20)
                            }
                        }

                        Spacer()
                    }
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

#Preview {
    TargetUsers()
}
