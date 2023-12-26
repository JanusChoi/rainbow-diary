//
//  OnboardingView.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2023/12/21.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var username: String = ""
    @State private var selectedCategory: String = ""
    @State private var isOnboardingComplete = false
    @State private var showingLoading = false
    @State private var showUsernamePrompt = true
    @State private var showCategoryPrompt = false
    @State private var showStartButton = false
    @State private var onboardingStep = 1
    
    let categories = ["心情", "知识", "工作", "祷告"]
    let dataService: DataStorageService
    
    var body: some View {
        if isOnboardingComplete {
            TodayView()
        } else {
            VStack {
                Group {
                    if onboardingStep == 1 {
                        Text("希望我如何称呼您？")
                        TextField("填入昵称", text: $username)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .transition(AnyTransition.opacity.animation(.easeIn))
                            .multilineTextAlignment(.center)
//                            .foregroundColor(.orange)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.blue, lineWidth: 1.5)
                            )
                            .padding()
                    }
                    
                    if onboardingStep == 2 {
                        Text("您希望记录的内容")
                        Picker("您希望记录的内容", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .transition(AnyTransition.opacity.animation(.easeInOut))
                    }
                    
                    if onboardingStep == 3 {
                        Text("一切准备开启")
                            .transition(AnyTransition.opacity.animation(.easeIn))
                    }
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .padding()
                
                // 提交按钮
                Button(action: {
                    withAnimation {
                        proceedToNextStep()
                    }
                }) {
                    Text(onboardingStep == 3 ? "开始" : "下一步")
                }
                .disabled(onboardingStep == 1 && username.isEmpty)
                .padding()
            }
            .padding()
        }
    }
    
    private func createUserAndCompleteOnboarding() {
        let newUser = dataService.createUser(username: username, createdAt: Date())
        UserDefaults.standard.set(newUser.id?.uuidString, forKey: "diaryUserId")
        hasCompletedOnboarding = true
    }
    
    // 处理下一步逻辑
    private func proceedToNextStep() {
        if onboardingStep < 3 {
            onboardingStep += 1
        } else if onboardingStep == 3 {
            // TODO: 处理完成引导后的逻辑，比如创建用户并跳转到ContentView
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                createUserAndCompleteOnboarding()
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasCompletedOnboarding: .constant(false), dataService: DataStorageService.shared)
    }
}
