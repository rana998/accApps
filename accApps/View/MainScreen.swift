
import Foundation
import SwiftUI

struct MainScreen: View {
    @State private var isPageLocked = false

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
                .padding(.top, 40)
                .padding(.trailing, 40)
                
                Spacer()
            }
        }
    }
}

#Preview {
    MainScreen()
}
