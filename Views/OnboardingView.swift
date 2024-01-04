//
//  OnboardingView.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2023/12/21.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var openaiKey: String = ""
    @State private var username: String = ""
    @State private var selectedCategory: String = ""
    @State private var isOnboardingComplete = false
    @State private var showingLoading = false
    @State private var showUsernamePrompt = true
    @State private var showCategoryPrompt = false
    @State private var showStartButton = false
    @State private var onboardingStep = 1
    
    let categories = ["Mood", "Info", "Prayer", "Just Start"]
    let dataService: DataStorageService
    
    var body: some View {
        if isOnboardingComplete {
            TodayView()
        } else {
            VStack {
                Group {
                    if onboardingStep == 1 {
                        Text("Input your OpenAI key")
                        Text(
                        "You can find and configure your OpenAI API key at"
                        )
                        .font(.caption)
                        Link(
                            "openai",
                            destination: URL(string: "https://platform.openai.com/account/api-keys")!
                        )
                        .font(.caption)
                        TextField("sk-XXXXXX", text: $openaiKey)
                            .multilineTextAlignment(.center)
                    }
                    if onboardingStep == 2 {
                        Text("What do you want me to call you?")
                        TextField("Your Nick Name", text: $username)
                            .transition(AnyTransition.opacity.animation(.easeIn))
                            .multilineTextAlignment(.center)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.blue, lineWidth: 1.5)
                            )
                            .padding()
                    }
                    
                    if onboardingStep == 3 {
                        Text("What you want to record")
                        Picker("What you want to record", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .transition(AnyTransition.opacity.animation(.easeInOut))
                    }
                    
                    if onboardingStep == 4 {
                        Text("Get Ready...")
                            .transition(AnyTransition.opacity.animation(.easeIn))
                    }
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .padding()
                
                Button(action: {
                    withAnimation {
                        proceedToNextStep()
                    }
                }) {
                    Text(onboardingStep == 4 ? "Go" : "Continue")
                }
                .disabled(onboardingStep == 1 && openaiKey.isEmpty)
                .padding()
            }
            .padding()
        }
    }
    
    private func createUserAndCompleteOnboarding() {
        let newUser = dataService.createUser(username: username, createdAt: Date(), openaiKey: openaiKey)
        UserDefaults.standard.set(newUser.id?.uuidString, forKey: "diaryUserId")
        hasCompletedOnboarding = true
    }
    
    // Next Step Logic
    private func proceedToNextStep() {
        if onboardingStep < 4 {
            onboardingStep += 1
        } else if onboardingStep == 4 {
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
