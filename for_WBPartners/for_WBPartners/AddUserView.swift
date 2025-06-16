import SwiftUI

struct ValidationMessages {
    static let requiredField = "Поле обязательно для заполнения"
    static let invalidEmail = "Введите корректный email"
}

struct AddUserView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: UserViewModel
    var userToEdit: User?
    
    @State private var phone = ""
    @State private var first_name = ""
    @State private var last_name = ""
    @State private var sur_name = ""
    @State private var email = ""
    @State private var isPhoneValid = true
    @State private var isFirstNameValid = true
    @State private var isLastNameValid = true
    @State private var isMiddleNameValid = true
    @State private var isEmailValid = true
    
    @State private var showValidationError = false
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(userToEdit == nil ? "Новый пользователь" : "Редактирование пользователя")
            //                .font(.title2)
                .font(.system(size: 18))
                .padding(.bottom)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Group {
                LabeledField(title: "Телефон", text: $phone, isValid: isPhoneValid, errorText: "Поле обязательно", keyboardType: .phonePad)
                
                LabeledField(title: "Имя", text: $first_name, isValid: isFirstNameValid, errorText: "Поле обязательно")
                LabeledField(title: "Фамилия", text: $last_name, isValid: isLastNameValid, errorText: "Поле обязательно")
                LabeledField(title: "Отчество", text: $sur_name, isValid: isMiddleNameValid, errorText: "Поле обязательно")
                LabeledField(title: "Почта", text: $email, isValid: isEmailValid, errorText: "Некорректный email", keyboardType: .emailAddress)
            }
            
            if showValidationError {
                Text("Все поля должны быть заполнены корректно")
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.top, 4)
            }
            
            Spacer()
            
            HStack {
                Button("Отмена") {
                    dismiss()
                }
                .foregroundColor(Color("FIO"))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("form"))
                .cornerRadius(8)
                
                Button("Сохранить") {
                    isPhoneValid = isValidPhone(phone)
                    isFirstNameValid = isValidName(first_name)
                    isLastNameValid = isValidName(last_name)
                    isMiddleNameValid = isValidName(sur_name)
                    isEmailValid = isValidEmail(email)
                    
                    
                    if isFormValid {
                        if let user = userToEdit {
                            viewModel.updateUser(user,
                                                 first_name: first_name,
                                                 last_name: last_name,
                                                 surname: sur_name,
                                                 phone: phone,
                                                 email: email)
                        } else {
                            viewModel.addUser(
                                first_name: first_name,
                                last_name: last_name,
                                surname: sur_name,
                                phone: phone,
                                email: email
                            )
                        }
                        dismiss()
                    } else {
                        showValidationError = true
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color("wb_color") : Color("no_active"))
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(!isFormValid)
            }
        }
        .onAppear {
            if let user = userToEdit {
                phone = user.phone ?? ""
                first_name = user.first_name ?? ""
                last_name = user.last_name ?? ""
                sur_name = user.surname ?? ""
                email = user.email ?? ""
            }
        }
        .padding()
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
    }
    private func isValidPhone(_ phone: String) -> Bool {
        let phoneRegex = #"^\+?[0-9]{10,15}$"#
        return phone.range(of: phoneRegex, options: .regularExpression) != nil
    }
    private func isValidName(_ name: String) -> Bool {
        let nameRegex = #"^[A-Za-zА-Яа-яЁё\s\-]+$"#
        return !name.isEmpty && name.range(of: nameRegex, options: .regularExpression) != nil
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^\S+@\S+\.\S+$"#
        return email.range(of: regex, options: .regularExpression) != nil
    }
    private var isFormValid: Bool {
        isValidPhone(phone) &&
        isValidName(first_name) &&
        isValidName(last_name) &&
        isValidName(sur_name) &&
        isValidEmail(email)
    }
}

struct LabeledField: View {
    let title: String
    @Binding var text: String
    var isValid: Bool
    var errorText: String?
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .foregroundColor(.gray)
            
            TextField("", text: $text)
                .foregroundColor(Color("FIO"))
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isValid ? Color("form") : Color.red, lineWidth: 1)
                )
                .keyboardType(keyboardType)
                .cornerRadius(8)
            
            if !isValid, let errorText {
                Text(errorText)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}


#Preview {
    let context = PersistenceController.preview.container.viewContext
    let viewModel = UserViewModel(context: context)
    return AddUserView(viewModel: viewModel)
}

