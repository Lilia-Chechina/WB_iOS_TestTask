import SwiftUI
import CoreData

struct UserListView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: UserViewModel
    @State private var showAddUser = false
    @State private var selectedUser: User? = nil
    
    init(context: NSManagedObjectContext? = nil) {
        let ctx = context ?? PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: UserViewModel(context: ctx))
    }
    var body: some View {
        VStack {
            Text("Пользователи")
                .font(.custom("ABeeZee-Regular", size: 18))
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
            if viewModel.allUsers.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "person")
                        .font(.system(size: 50))
                        .foregroundColor(Color("icon"))
                    
                    Text("У вас пока нет пользователей")
                        .font(.custom("ABeeZee-Regular", size: 18))
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        showAddUser = true
                    }) {
                        Label("Добавить", systemImage: "plus")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("wb_color"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                Spacer()
            } else {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color("search"))
                        TextField("Поиск по пользователям", text: $viewModel.searchText)
                            .autocapitalization(.none)
                            .foregroundColor(Color("FIO"))
                            .disableAutocorrection(true)
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("form"), lineWidth: 1)
                    )
                    .padding()
                    
                    if viewModel.filteredUsers.isEmpty && !viewModel.searchText.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image("Cat:not_found")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 180)
                            
                            Text("Пользователь не найден")
                                .font(.custom("ABeeZee-Regular", size: 18))
                                .foregroundColor(Color("FIO"))
                        }
                        .frame(maxWidth: .infinity)
                        Spacer()
                    } else {
                        List {
                            ForEach(viewModel.filteredUsers, id: \.objectID) { user in
                                VStack(alignment: .leading, spacing: 4) {
                                    let full_name = "\(user.last_name ?? "") \(user.first_name ?? "") \(user.surname ?? "")"
                                    Text(full_name)
                                        .font(.system(size: 17))
                                        .foregroundColor(.black)
                                        .padding(.bottom, 4)
                                    
                                    if let phone = user.phone {
                                        Text(phone)
                                            .font(.system(size: 15))
                                            .foregroundColor(Color("FIO"))
                                    }
                                    if let email = user.email {
                                        Text(email)
                                            .font(.system(size: 15))
                                            .foregroundColor(Color("FIO"))
                                    }
                                }
                                .padding(.vertical, 4)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedUser = user
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .sheet(item: $selectedUser) { user in
                            AddUserView(viewModel: viewModel, userToEdit: user)
                        }
                    }
                    Button(action: {
                        showAddUser = true
                    }) {
                        Label("Добавить пользователя", systemImage: "plus")
                            .padding()
                            .font(.system(size: 18))
                            .frame(maxWidth: .infinity)
                            .background(Color("wb_color"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showAddUser) {
            AddUserView(viewModel: viewModel)
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return UserListView(context: context)
}
