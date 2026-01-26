//
//  AuthView.swift
//  car-step
//
//  Created by Maxim Tampere on 21/01/2026.
//

import SwiftUI
import Supabase

struct AuthView: View {
    @State var email = ""
    @State var isLoading = false
    @State var result: Result<Void, Error>?

    var body: some View {
        VStack {
            Spacer()
            
            Text("Car Step")
                .font(.system(size: 64, weight: .bold))
            
            Spacer()
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email*")
                        .opacity(0.75)
                    TextField("...", text: $email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .background(Color("PrimaryAppColor"))
                        .padding(12)
                        .background(Color("PrimaryAppColor"))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                VStack{
                    if let result {
                        switch result {
                        case .success:
                            Text("Check your inbox.")
                                .foregroundStyle(Color.green)
                        case .failure(let error):
                            Text(error.localizedDescription)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .frame(height: 20)

                Button {
                    signInButtonTapped()
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Sign Up/In")
                                .bold()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isLoading || !isValidEmail ? Color.gray.opacity(0.5) : Color.blue)
                    .foregroundStyle(Color.white)
                    .cornerRadius(12)
                }
                .disabled(isLoading || !isValidEmail)
                .padding(.horizontal, 20)
                
            }
        }
        .padding(.vertical, 30)
        .background(Color("BackgroundAppColor"))
        .onOpenURL(perform: { url in
            Task {
                do {
                    try await supabase.auth.session(from: url)
                } catch {
                    self.result = .failure(error)
                }
            }
        })
    }
    
    func signInButtonTapped() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                try await supabase.auth.signInWithOTP(
                    email: email,
                    redirectTo: URL(string: "io.supabase.user-management://login-callback")
                )
                result = .success(())
            } catch {
                result = .failure(error)
            }
        }
    }
    
    var isValidEmail: Bool {
        let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
}

#Preview {
    AuthView()
}
