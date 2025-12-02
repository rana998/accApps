//
//  SconedMainScreen.swift
//  accApps
//
//  Created by Jana Abdulaziz Malibari on 02/12/2025.
//

import SwiftUI

struct SconedMainScreen: View {
    @State private var isPageLocked = false
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // الخلفية من الـ Assets
                Color.background
                    .ignoresSafeArea()
                
                // العنوان
                VStack {
                    Text("اختر من القائمة")
                        .font(.custom("Rubik-Medium", size: 61))
                        .foregroundColor(.darkBlue)
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, 80)
                
                // زر المنيو الزجاجي (٣ نقاط) + خياراته
                VStack {
                    HStack {
                        Spacer()
                        
                        Menu {
                            // خيار إضافة بطاقة
                            Button {
                                // لاحقاً: افتحي شيت إضافة بطاقة
                            } label: {
                                Label("إضافة بطاقة", systemImage: "plus")
                            }
                            
                            // فاصل
                            Divider()
                            
                            // خيار قفل الصفحة
                            Button {
                                isPageLocked.toggle()
                            } label: {
                                Label(
                                    isPageLocked ? "إلغاء قفل الصفحة" : "قفل الصفحة",
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
                    .padding(40)
                    nameList(viewModel: viewModel)
                    
                    NavigationLink("التالي") {
                        verbList(viewModel: viewModel)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct nameList: View {
    @ObservedObject var viewModel: ViewModel
        
        let names = ["Noora", "Jana", "Fatima", "Sara"] // Example list
    var body: some View {
        HStack {
            if let selected = viewModel.selectedName {
                BubbleView(text: selected) {
                    viewModel.selectedName = nil
                }
            } else {
                Text("اختر إسم…")
                    .foregroundColor(.gray)
                    .padding(.leading, 1060)
            }
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color("Background")))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
        
        // List of options
        ForEach(names, id: \.self) { name in
            Button {
                viewModel.selectedName = name
            } label: {
                Text(name)
                    .padding()
                    .padding(.leading, 1060)
                    .frame(maxWidth: .infinity)
                    .background(Color.lightBlue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        
        Spacer()
    }
}


struct verbList: View {
    @ObservedObject var viewModel: ViewModel
    
    let verbs = ["Eat", "Walk", "Drink"] // Example list
    var body: some View {
        HStack {
            if let selected = viewModel.selectedName {
                BubbleView(text: selected) {
                    viewModel.selectedName = nil
                }
            } else {
                Text("اختر فعل…")
                    .foregroundColor(.gray)
                    .padding(.leading, 1060)
            }
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color("Background")))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
        
        // List of options
        ForEach(verbs, id: \.self) { verb in
            Button {
                viewModel.selectedName = verb
            } label: {
                Text(verb)
                    .padding()
                    .padding(.leading, 1060)
                    .frame(maxWidth: .infinity)
                    .background(Color.lightBlue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        
        Spacer()
    }
}

struct nounList: View {
    @ObservedObject var viewModel: ViewModel
    
    let nouns = ["Me", "You", "We, Us"] // Example list
    var body: some View {
        HStack {
            if let selected = viewModel.selectedName {
                BubbleView(text: selected) {
                    viewModel.selectedName = nil
                }
            } else {
                Text("اختر ضمير…")
                    .foregroundColor(.gray)
                    .padding(.leading, 1060)
            }
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color("Background")))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
        
        // List of options
        ForEach(nouns, id: \.self) { noun in
            Button {
                viewModel.selectedName = noun
            } label: {
                Text(noun)
                    .padding()
                    .padding(.leading, 1060)
                    .frame(maxWidth: .infinity)
                    .background(Color.lightBlue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        
        Spacer()
    }
}

struct BubbleView: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .foregroundColor(.white)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)

            
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.trailing,10)
            }
        }
        .background(Color.gray)
        .clipShape(Capsule())
    }
}

#Preview {
    SconedMainScreen()
}
