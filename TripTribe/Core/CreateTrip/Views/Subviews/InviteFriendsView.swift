//
//  InviteFriendsView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//

import SwiftUI

struct InviteFriendsView: View {
    @ObservedObject var viewModel: NewTripViewModel
    @State private var emailAddress: String = ""
    @State private var personalMessage: String = ""
    @State private var isShowingContactPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            NewTripHeaderView(onBackTap: {
                withAnimation {
                    viewModel.currentStep = 1
                }
            })
            
            ScrollView {
                // Progress Indicator
                ProgressDotsView(currentStep: viewModel.currentStep, totalSteps: viewModel.totalSteps)
                    .padding(.bottom, 40)
                
                // Form content
                VStack(alignment: .leading, spacing: 32) {
                    Text("Invite Friends")
                        .font(.jakartaSans(22, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 12)
                    
                    // Email input field
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Enter email address", text: $emailAddress)
                            .font(.jakartaSans(16, weight: .regular))
                            .padding(16)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        // Add button
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                // Add the email to invited list
                                if !emailAddress.isEmpty && isValidEmail(emailAddress) {
                                    viewModel.addInvitedEmail(emailAddress)
                                    emailAddress = ""
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.black)
                                    .clipShape(Circle())
                            }
                            .disabled(emailAddress.isEmpty || !isValidEmail(emailAddress))
                            .opacity(emailAddress.isEmpty || !isValidEmail(emailAddress) ? 0.5 : 1.0)
                        }
                    }
                    
                    // Access Contacts button
                    Button(action: {
                        isShowingContactPicker = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 20))
                            
                            Text("Access Contacts")
                                .font(.jakartaSans(14, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(Color(.systemGray6))
                        .cornerRadius(25)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Personalize your invite section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Personalize your invite")
                            .font(.jakartaSans(18, weight: .semibold))
                            .foregroundColor(.black)
                        
                        TextEditor(text: $personalMessage)
                            .font(.jakartaSans(16, weight: .regular))
                            .padding(16)
                            .frame(height: 150)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .overlay(
                                Group {
                                    if personalMessage.isEmpty {
                                        Text("Write a personal message (optional)")
                                            .font(.jakartaSans(16, weight: .regular))
                                            .foregroundColor(Color.gray.opacity(0.8))
                                            .padding(20)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                            .allowsHitTesting(false)
                                    }
                                }
                            )
                    }
                    
                    // Preview of invited contacts
                    if !viewModel.invitedEmails.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Invited")
                                .font(.jakartaSans(16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            ForEach(viewModel.invitedEmails, id: \.self) { email in
                                HStack {
                                    Text(email)
                                        .font(.jakartaSans(14, weight: .regular))
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        viewModel.removeInvitedEmail(email)
                                    }) {
                                        Image(systemName: "xmark")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(10)
                                .background(Color(.systemGray6).opacity(0.5))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Planning solo option
                    Button(action: {
                        // Skip invitations and finalize trip
                        viewModel.finalizeTripCreation()
                    }) {
                        Text("Planning solo?")
                            .font(.jakartaSans(16, weight: .regular))
                            .foregroundColor(.gray)
                            .underline()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Skip this step
                    Button(action: {
                        // Skip invitations and finalize trip
                        viewModel.finalizeTripCreation()
                    }) {
                        Text("Skip this step")
                            .font(.jakartaSans(16, weight: .regular))
                            .foregroundColor(.gray)
                            .underline()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, -15)
                    
                    // Send invites button
                    Button(action: {
                        // Send invites and finalize trip
                        viewModel.sendInvites(withMessage: personalMessage)
                    }) {
                        Text("Send Invites")
                            .font(.jakartaSans(16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.black)
                            .cornerRadius(28)
                    }
                    .padding(.top, 10)
                    .disabled(viewModel.invitedEmails.isEmpty)
                    .opacity(viewModel.invitedEmails.isEmpty ? 0.6 : 1.0)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

// Preview
struct InviteFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = NewTripViewModel(onDismiss: {})
        viewModel.currentStep = 2
        return InviteFriendsView(viewModel: viewModel)
    }
}
