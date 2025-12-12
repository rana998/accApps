//
//  CardView.swift
//  accApps
//
//  Created by Jana Abdulaziz Malibari on 12/12/2025.
//

import SwiftUI

struct CardView: View {
    var body: some View {
       
    }
}

struct RecordingStatusView: View {

    let isRecording: Bool
    let hasRecording: Bool

    var body: some View {
        Group {
            if isRecording {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .scaleEffect(1.2)
                        .animation(
                            .easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true),
                            value: isRecording
                        )

                    Text("جاري التسجيل…")
                        .foregroundColor(.red)
                        .font(.system(size: 14, weight: .medium))
                }
            } else if hasRecording {
                HStack(spacing: 6) {
                    Image(systemName: "waveform.circle.fill")
                        .foregroundColor(.green)

                    Text("تم تسجيل مقطع صوتي")
                        .foregroundColor(.green)
                        .font(.system(size: 14, weight: .medium))
                }
            } else {
                EmptyView()
            }
        }
    }
}

struct AttachImageBox: View {

    var image: UIImage?
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [7]))
                    .foregroundColor(Color(red: 175/255, green: 242/255, blue: 254/255))
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color(red: 191/255, green: 234/255, blue: 242/255).opacity(0.18))
                    )
                    .frame(width: 280, height: 240)

                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 260, height: 220)
                        .clipped()
                        .cornerRadius(24)
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "icloud.and.arrow.up")
                            .font(.system(size: 60))
                            .foregroundColor(Color(red: 175/255, green: 242/255, blue: 254/255))

                        Text("إرفاق/التقاط صورة")
                            .font(.system(size: 17))
                            .foregroundColor(Color(red: 175/255, green: 242/255, blue: 254/255))
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct CardDisplay: View {
    @ObservedObject var viewModel: RecordVoiceViewModel

    var onClose: () -> Void = {}
    var onSaveCard: (CardData) -> Void = { _ in }   // 👈 مهم لإرسال البطاقة للشاشة الرئيسية

    @State private var showImagePicker   = false
    @State private var showSourceDialog  = false
    @State private var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary

    @State private var showSavedAlert = false

    var body: some View {
        ZStack {
            // خلفية كاملة بيضاء
            Color.white
                .ignoresSafeArea()

            // الكارد الأبيض
            ZStack {
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color.white)

                VStack(spacing: 0) {

                    Text("إضافة بطاقة")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.black.opacity(0.7))
                        .padding(.top, 24)

                    Spacer(minLength: 16)

                    // صورة
                    AttachImageBox(
                        image: viewModel.state.selectedImage,
                        onTap: { showSourceDialog = true }
                    )
                    .padding(.top, 8)

                    // اسم البطاقة
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("اسم البطاقة")
                            .font(.system(size: 12))
                            .foregroundColor(.gray.opacity(0.7))

                        ZStack(alignment: .trailing) {
                            if viewModel.state.cardName.isEmpty {
                                Text("اسم البطاقة")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.gray.opacity(0.35))
                                    .padding(.horizontal, 12)
                            }

                            TextField(
                                "",
                                text: Binding(
                                    get: { viewModel.state.cardName },
                                    set: { viewModel.send(.updateName($0)) }
                                )
                            )
                            .multilineTextAlignment(.trailing)
                            .padding(.horizontal, 12)
                        }
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                        )
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 120)

                    // خط فاصل
                    Divider()
                        .padding(.horizontal, 120)
                        .padding(.top, 20)

                    // عنوان الصوت
                    Text("الرجاء تسجيل صوتك")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.top, 12)

                    // أزرار الصوت
//                    HStack(spacing: 28) {
//                        // حذف
//                        CircularIconButton(
//                            systemName: "trash",
//                            iconColor: Color(red: 245/255, green: 84/255, blue: 84/255),
//                            backgroundColor: Color(red: 1.0, green: 0.94, blue: 0.95),
//                            size: 36
//                        ) {
//                            viewModel.send(.deleteTapped)
//                        }
//                        .opacity(viewModel.state.hasRecording ? 1 : 0.3)
//                        .disabled(!viewModel.state.hasRecording)
//
//                        // تسجيل
//                        MicrophoneMainButton(isRecording: viewModel.state.isRecording) {
//                            viewModel.send(.recordTapped)
//                        }
//
//                        // تشغيل
//                        CircularIconButton(
//                            systemName: viewModel.state.isPlaying ? "pause.fill" : "play.fill",
//                            iconColor: .black,
//                            backgroundColor: Color.white,
//                            size: 36
//                        ) {
//                            viewModel.send(.playTapped)
//                        }
//                        .opacity(viewModel.state.hasRecording ? 1 : 0.3)
//                        .disabled(!viewModel.state.hasRecording)
//                    }
                    .padding(.top, 18)

                    RecordingStatusView(
                        isRecording: viewModel.state.isRecording,
                        hasRecording: viewModel.state.hasRecording
                    )
                    .padding(.top, 4)

                    Spacer()

                    // أزرار الحفظ / الإلغاء
//                    VStack(spacing: 12) {
//                        FilledRoundedButton(
//                            title: "حفظ البطاقة",
//                            isPrimary: true
//                        ) {
//                            handleSaveCard()
//                        }
//                        .frame(width: 280)
//
//                        FilledRoundedButton(
//                            title: "إلغاء",
//                            isPrimary: false
//                        ) {
//                            viewModel.send(.cancelTapped)
//                            onClose()
//                        }
//                        .frame(width: 280)
//                    }
                    .padding(.bottom, 32)
                }
            }
            .frame(width: 750, height: 560)
        }
        // اختيار مصدر الصورة
        .confirmationDialog("اختيار الصورة", isPresented: $showSourceDialog, titleVisibility: .visible) {
            Button("اختيار من الألبوم") {
                pickerSourceType = .photoLibrary
                showImagePicker = true
            }
            Button("التقاط من الكاميرا") {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    pickerSourceType = .camera
                } else {
                    pickerSourceType = .photoLibrary
                }
                showImagePicker = true
            }
            Button("إلغاء", role: .cancel) { }
        }
        // شيت الصورة
//        .sheet(isPresented: $showImagePicker) {
//            ImagePicker(sourceType: pickerSourceType) { image in
//                viewModel.send(.imageSelected(image))
//            }
//        }
        // تنبيه الحفظ
        .alert("تم حفظ البطاقة", isPresented: $showSavedAlert) {
            Button("حسناً") {
                onClose()
            }
        } message: {
            Text("تم حفظ البطاقة بنجاح.")
        }
    }

    // MARK: - حفظ البطاقة وإرسالها
    private func handleSaveCard() {
        // لو لسه يسجل، أوقفي التسجيل أول
        if viewModel.state.isRecording {
            viewModel.send(.recordTapped)
        }

        let trimmedName = viewModel.state.cardName
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let selectedImage = viewModel.state.selectedImage

        guard !trimmedName.isEmpty else { return }

        let newCard = CardData(
            title: trimmedName,
            image: selectedImage,
            audioURL: viewModel.state.recordingURL   // 👈 أهم سطر
        )

        onSaveCard(newCard)
        viewModel.send(.saveTapped)
        showSavedAlert = true
    }
}

struct ContentView: View {
    @StateObject private var recordVM = RecordVoiceViewModel()
    @StateObject private var cardsVM  = CardsViewModel()
    @State private var showAddCard = false

    // شبكة 3 أعمدة
    private let columns = [
        GridItem(.flexible(), spacing: 40),
        GridItem(.flexible(), spacing: 40),
        GridItem(.flexible(), spacing: 40)
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text("اختر من القائمة")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(Color(red: 0/255, green: 28/255, blue: 57/255))
                    .padding(.top, 40)
                
                Spacer()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 40) {
                        ForEach(cardsVM.cards) { card in
                            MainCardView(card: card)
                        }
                    }
                    .padding(.horizontal, 80)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                
                Spacer()
            }
            
            // زر إضافة بطاقة
            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.spring()) {
                            showAddCard = true
                        }
                    } label: {
                        Text("إضافة بطاقة")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(radius: 4)
                    }
                    .padding(.top, 40)
                    .padding(.trailing, 40)
                }
                Spacer()
            }
            
            // شاشة إضافة البطاقة
            if showAddCard {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()

                CardDisplay(
                    viewModel: recordVM,
                    onClose: {
                        withAnimation(.spring()) {
                            showAddCard = false
                        }
                    }
                )
                .frame(width: 750, height: 560)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

struct MainCardView: View {
    let card: CardData
    var onTap: () -> Void = {}

    var body: some View {
        ZStack {
            // الإطار الخارجي الأخضر
            RoundedRectangle(cornerRadius: 36)
                .fill(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 36)
                        .stroke(
                            Color(red: 204/255, green: 235/255, blue: 184/255),
                            lineWidth: 4
                        )
                )

            // الكارد الأبيض الداخلي
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.12),
                        radius: 10, x: 0, y: 6)
                .padding(6)

            VStack(spacing: 8) {
                if let uiImage = card.image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, 32)
                        .padding(.top, 24)
                } else {
                    Color.clear
                        .frame(height: 140)
                }

                Spacer(minLength: 8)

                Text(card.title)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .padding(.bottom, 18)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct SentenceCardView: View {
    @ObservedObject var viewModel: RecordVoiceViewModel
    let sentence: String
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40)
                
            
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.25),
                        radius: 16, x: 0, y: 8)
                
            
            VStack(spacing: 0) {
                // العنوان أعلى الكارد
                Text("الجملة")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black.opacity(0.7))
                    .padding(.top, 24)
                
                Spacer(minLength: 32)
                
                // نص الجملة في المنتصف
                Text(sentence)
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 80)
                
                Spacer(minLength: 32)
                
                // زر تشغيل الصوت (سماعة)
                Button {
                    viewModel.send(.playTapped)
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.9),
                                        Color(red: 191/255, green: 234/255, blue: 242/255)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 80, height: 80)
                            .shadow(color: Color.black.opacity(0.15),
                                    radius: 10, x: 0, y: 4)
                        
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.black)
                    }
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
                
                Spacer()
                
//                // زر رجوع
//                FilledRoundedButton(
//                    title: "رجوع",
//                    isPrimary: true
//                ) {
//                    dismiss()
//                }
//                .frame(width: 280)
//                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: 700, maxHeight: 520)
    }
}


#Preview {
    CardView()
}
