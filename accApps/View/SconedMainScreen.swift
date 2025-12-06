//
//  SconedMainScreen.swift
//  accApps
//
//  Created by Jana Abdulaziz Malibari on 02/12/2025.
//

import SwiftUI

struct SconedMainScreen: View {
    @StateObject var viewModel = ViewModel()
    @State private var currentPage: Page = .noun
    @State private var isPageLocked = false
    @State private var sentacncePage = false
    @State private var word = false
    enum Page { case noun, name, verb }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // الخلفية من الـ Assets
                Color.background
                    .ignoresSafeArea()
                
                // العنوان
                VStack {
                    Text("Choose From The Menu")
                        .font(.custom("Rubik-Medium", size: 61))
                        .foregroundColor(.darkBlue)
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, 80)
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Menu {
                            // خيار إضافة بطاقة
                            Button {
                                // لاحقاً: افتحي شيت إضافة بطاقة
                            } label: {
                                Label("Add Card", systemImage: "plus")
                            }
                            // فاصل
                            Divider()
                            // خيار قفل الصفحة
                            Button {
                                isPageLocked.toggle()
                            } label: {
                                Label(
                                    isPageLocked ? "Screen Unlock" : "Screen Lock",
                                    systemImage: isPageLocked ? "lock.open" : "lock"
                                )
                            }
                            
                        } label: {
                            // شكل زر الـ ٣ نقاط (اللي يفتح المنيو)
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(180))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.darkBlue)
                                .padding(10)
                                .background(Color.lightBlue)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.top, 70)
                    .padding(.trailing ,30)
                    
                    BubbleView(viewModel: viewModel, text: "", onRemove: {word = true})
                    Divider()
                        .frame(width: 900)
                    HStack{
                        Button("Verbs", systemImage: ""){
                            currentPage = .verb
                        }
                        .frame(width: 100, height: 40)
                        .font(.custom("Rubik-Medium", size: 18))
                        .foregroundColor(.darkBlue)
                        .glassEffect(.regular.tint(.green.opacity(0.3)).interactive(), in: .rect(cornerRadius: 20))
                        .padding(.top,20)
                        .padding(.bottom, 10)
                        .padding(.leading, 10)
                        
                        Button("Names",systemImage: ""){
                            currentPage = .name
                        }
                        .frame(width: 100, height: 40)
                        .font(.custom("Rubik-Medium", size: 18))
                        .foregroundColor(.darkBlue)
                        .glassEffect(.regular.tint(.red.opacity(0.3)).interactive(), in: .rect(cornerRadius: 20))
                        .padding(.top,20)
                        .padding(.bottom, 10)
                        .padding(.leading, 10)
                        
                        Button("Nouns",systemImage: ""){
                            currentPage = .noun
                        }
                        .frame(width: 100, height: 40)
                        .font(.custom("Rubik-Medium", size: 18))
                        .foregroundColor(.darkBlue)
                        .glassEffect(.regular.tint(.yellow.opacity(0.3)).interactive(), in: .rect(cornerRadius: 20))
                        .padding(.top,20)
                        .padding(.bottom, 10)
                        .padding(.leading, 10)
                        
                    }
                    
                    switch currentPage {
                    case .noun:
                        nounList(viewModel: viewModel)
                    case .name:
                        nameList(viewModel: viewModel)
                    case .verb:
                        verbList(viewModel: viewModel)
                    }
                    
                    Spacer()

                }
                .padding()
                                
                Button("Done"){
                    sentacncePage = true
                    viewModel.generateSentence()
                }
                .sheet(isPresented: $sentacncePage) {
                    sentenceView(viewModel: viewModel, onClose: {sentacncePage = false})
                }
                .frame(width: 200, height: 60)
                .font(.custom("Rubik-Medium", size: 20))
                .foregroundColor(.primary)
                .glassEffect(.clear.interactive().tint(Color.purple.opacity(0.3)), in: .rect(cornerRadius: 17))
                .padding(.top, 650)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct nameList: View {
    @ObservedObject var viewModel: ViewModel
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    let names = ["Rana", "Jana", "Fatimah"]
    
    var body: some View {
        ScrollView{
            LazyVGrid(columns: columns, spacing: 40) {
                    ForEach(names, id: \.self) { name in
                        Button(name) {
                            viewModel.selectedNames.append(name)
                        }
                        .frame(width: 200, height: 200, alignment: .center)
                        .font(.custom("Rubik-Medium", size: 20))
                        .foregroundColor(Color.darkBlue)
                        .glassEffect(.regular.tint(Color.lightBlue).interactive(), in: .rect(cornerRadius: 25))
                    }
            }
            .padding(.all, 40)
        }
    }
}

struct verbList: View {
    @ObservedObject var viewModel: ViewModel
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    let verbs = ["Eat", "Drink", "Walk"]
    
    var body: some View {
        ScrollView{
            LazyVGrid(columns: columns, spacing: 40) {
                    ForEach(verbs, id: \.self) { verb in
                        Button(verb) {
                            viewModel.selectedVerbs.append(verb)
                        }
                        .frame(width: 200, height: 200, alignment: .center)
                        .font(.custom("Rubik-Medium", size: 20))
                        .foregroundColor(Color.darkBlue)
                        .glassEffect(.regular.tint(Color.lightBlue).interactive(), in: .rect(cornerRadius: 25))
                    }
            }
            .padding(.all, 40)
        }
    }
}

struct nounList: View {
    @ObservedObject var viewModel: ViewModel
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    let nouns = ["Her", "I", "Him", "Them","Us"]
    
    var body: some View {
        ScrollView{
            LazyVGrid(columns: columns, spacing: 40) {
                    ForEach(nouns, id: \.self) { noun in
                        Button(noun) {
                            viewModel.selectedNouns.append(noun)
                        }
                        .frame(width: 200, height: 200, alignment: .center)
                        .font(.custom("Rubik-Medium", size: 20))
                        .foregroundColor(Color.darkBlue)
                        .glassEffect(.regular.tint(Color.lightBlue).interactive(), in: .rect(cornerRadius: 25))
                    }
            }
            .padding(.all, 40)
        }
    }
}
struct BubbleView: View {
    @ObservedObject var viewModel: ViewModel
        let text: String
        let onRemove: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                
                ForEach(viewModel.selectedNouns, id: \.self) { item in
                    Bubble(text: item, color: .yellow.opacity(0.3)) {
                        viewModel.selectedNouns.removeAll { $0 == item }
                    }
                }
                
                ForEach(viewModel.selectedNames, id: \.self) { item in
                    Bubble(text: item, color: .red.opacity(0.3)) {
                        viewModel.selectedNames.removeAll { $0 == item }
                    }
                }
                
                ForEach(viewModel.selectedVerbs, id: \.self) { item in
                    Bubble(text: item, color: .green.opacity(0.3)) {
                        viewModel.selectedVerbs.removeAll { $0 == item }
                    }
                }
                
            }
            .padding(.horizontal)
        }
        .frame(width: 900 ,height: 60)
    }
}

struct Bubble: View {
    let text: String
    let color: Color
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.custom("Rubik-Medium", size: 20))
                .foregroundColor(.darkBlue)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.darkBlue.opacity(0.9))
                    .padding(.trailing, 10)
            }
        }
        .background(color)
        .clipShape(Capsule())
    }
}




struct sentenceView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var show = true
    let onClose: () -> Void
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 30)
                .frame(width: 825, height: 700)
                .foregroundColor(.white)
            VStack{
                Text("The Sentence")
                    .font(.custom("Rubik-Medium", size: 31))
                    .foregroundColor(.darkBlue)
                    .multilineTextAlignment(.center)
                    .padding(.top, 70)
                Spacer()
                
                Text(viewModel.generatedSentence.isEmpty ? "No sentence yet" : viewModel.generatedSentence)
                    .font(.custom("Rubik-Medium", size: 51))
                    .foregroundColor(.darkBlue)
                    .multilineTextAlignment(.center)
                    .padding(.top, 100)
                Spacer()
                Button {
                    
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 60)
                            .frame(width: 110, height: 110)
                            .foregroundColor(Color.lightBlue)
                        Image(systemName: "speaker.wave.2.fill")
                            .frame(width: 100, height: 100)
                            .foregroundColor(Color.darkBlue)
                            .font(Font.system(size: 30).bold())
                            .background(Color.whitiesh)
                            .cornerRadius(50)
                    }
                    .glassEffect(.regular.interactive())
                }
                .padding(.top, 10)
                Spacer()
                Button("Back"){
                    onClose()
                }
                .frame(width: 325, height: 50)
                .font(.custom("Rubik-Medium", size: 18))
                .foregroundColor(Color.darkBlue)
                .cornerRadius(40)
                .glassEffect(.regular.tint(Color.lightBlue).interactive())
                }
                .padding(.bottom, 40)
                Spacer()
                
            }
            
        }
    }

#Preview {
    SconedMainScreen()
}
