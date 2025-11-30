//
//  MainScreen.swift
//  accApps
//
//  Created by Rana on 09/06/1447 AH.
//

import Foundation
import SwiftUI

struct MainScreen: View {
    @State private var showMenu = false
    @State private var isPageLocked = false
    // حذفنا isCalmModeOn لأنه ما عاد له استخدام
    // @State private var isCalmModeOn = false

    // حذفنا showAddCardSheet لأننا ما نعرض الشيت الآن
    // @State private var showAddCardSheet = false

    var body: some View {
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
            
            // طبقة لمس لإغلاق الشيت الصغير فقط
            if showMenu {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showMenu = false
                    }
            }
            
            // زر النقاط + الشيت الصغير
            VStack(alignment: .trailing, spacing: 12) {
                
                // زر الثلاث نقاط
                HStack {
                    Spacer()
                    
                    Button {
                        showMenu.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(180))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.darkBlue)
                            .padding(10)
                            .background(Color.lightBlue)
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 40)
                .padding(.trailing, 40)
                
                // الشيت الصغير
                if showMenu {
                    VStack(alignment: .trailing, spacing: 16) {
                        
                        // زر "إضافة بطاقة"
                        Button {
                            // حاليًا ما نسوي شيء، بس نقفل المنيو
                            showMenu = false
                            // لاحقًا تضيفي هنا الفنكشن أو الشيت الجديد
                        } label: {
                            HStack {
                                Text("إضافة بطاقة")
                                    .font(.custom("Rubik-Medium", size: 14))
                                    .foregroundColor(.darkBlue)
                                
                                Spacer()
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.lightBlue)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Image(systemName: "plus")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                        
                        Divider()
                        
                        Toggle("قفل الصفحة", isOn: $isPageLocked)
                        // حذفنا Toggle "الوضع الهادئ"
                    }
                    .environment(\.layoutDirection, .rightToLeft)
                    .font(.custom("Rubik-Regular", size: 14))
                    .foregroundColor(.darkBlue)
                    .padding(16)
                    .frame(width: 220, alignment: .trailing)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(radius: 8, y: 3)
                    .padding(.trailing, 20)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    MainScreen()
}
