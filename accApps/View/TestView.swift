//
//  TestView.swift
//  accApps
//
//  Created by Jana Abdulaziz Malibari on 12/12/2025.
//


//
//  TestView.swift
//  accApps
//
//  Created by Jana Abdulaziz Malibari on 11/12/2025.
//

import SwiftUI

struct TestView: View {
    @State private var isPageLocked = false
    @State private var isPressed = false
    @State private var addCard: Bool = false
    @Namespace private var animation
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.background
                    .ignoresSafeArea()

                    .navigationTitle("Choose From The Menu")
                    .toolbar{
                        ToolbarItem(id: "Lock", placement: .topBarTrailing){
                            Button{
                                isPageLocked.toggle()
                            } label: {
                                Image(systemName: isPageLocked ? "lock.open" : "lock")
                                    .font(.custom("Rubik-Medium", size: 20))
                                    .foregroundColor(.darkBlue)
                                
                            }
                            
                        }
                        ToolbarItem(id: "Star", placement: .topBarTrailing){
                            Button{
                                isPressed.toggle()
                            } label: {
                                Image(systemName: isPressed ? "star.fill" :"star")
                                    .foregroundColor(isPressed ? .orange : .darkBlue)
                                    .font(.custom("Rubik-Medium", size: 20))
                                
                            }
                            
                        }
                        ToolbarItem(id: "Settings", placement: .topBarTrailing){
                            Button{
                                
                            } label: {
                                Image(systemName: "gear")
                                    .font(.custom("Rubik-Medium", size: 20))
                                    .foregroundColor(.darkBlue)
                            }
                            .matchedTransitionSource(id: "Settings", in: animation)
                        }
                        ToolbarItem(id: "Edit", placement: .topBarTrailing){
                            Button{
                                
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.custom("Rubik-Medium", size: 20))
                                    .foregroundColor(.darkBlue)
                            }
                        }
                        ToolbarItem(id: "Add", placement: .topBarTrailing){
                            Button{
                                addCard.toggle()
                            } label: {
                                Image(systemName: "plus")
                                    .font(.custom("Rubik-Medium", size: 20))
                                    .foregroundColor(.darkBlue)
                            }
                        }
                        ToolbarSpacer(.fixed, placement: .topBarTrailing)
                        ToolbarItem(id: "Select", placement: .topBarTrailing){
                            Button{
                                
                            } label: {
                                Text("Select")
                                    .font(.custom("Rubik-Medium", size: 20))
                                    .foregroundColor(.darkBlue)
                            }
                        }
                        
                    }
                    .sheet(isPresented: $addCard){
                        Text("Add a New Card")
                            .font(.custom("Rubik-Medium", size: 20))
                            .foregroundColor(.darkBlue)
                            .navigationTransition(.zoom(sourceID: "Add", in: animation))
                    }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
        }
    }
}

#Preview {
    TestView()
}
