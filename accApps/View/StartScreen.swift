//
//  StartScreen.swift
//  accApps
//
//  Created by Jana Abdulaziz Malibari on 02/12/2025.
//
import SwiftUI

struct StartScreen: View {
    var body: some View {
           NavigationStack{
               ZStack{
                   Color("Background")
                       .ignoresSafeArea()
                   VStack{
                       splashScreen()
                   }
               }
           }.navigationBarBackButtonHidden(true)
       }
}

struct splashScreen: View {
    var body: some View {
        ZStack{
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
            logo()
            NavigationLink(destination: MainScreen()){
                Button("إبدء"){
                }
                .frame(width: 300, height: 60)
                .font(.system(size: 20, weight: .bold, design: .default))
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
struct triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}


#Preview {
    StartScreen()
}


