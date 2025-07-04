import Foundation
import CoreData
import Combine

class UserViewModel: ObservableObject {
    @Published var allUsers: [User] = []
    @Published var searchText: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchUsers()
        
        
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    
    
    
    var filteredUsers: [User] {
        guard !searchText.isEmpty else { return allUsers }
        
        return allUsers.filter { user in
            let values = [
                user.first_name,
                user.last_name,
                user.surname,
                user.phone,
                user.email
            ]
            return values.contains { $0?.localizedCaseInsensitiveContains(searchText) == true }
        }
    }
    
    var isEmpty: Bool {
        allUsers.isEmpty
    }
    
    func fetchUsers() {
        let request: NSFetchRequest<User> = User.fetchRequest()
        do {
            allUsers = try context.fetch(request)
        } catch {
            print("Ошибка при загрузке пользователей: \(error)")
        }
    }
    
    func addUser(first_name: String, last_name: String, surname: String, phone: String, email: String) {
        let newUser = User(context: context)
        newUser.first_name = first_name
        newUser.last_name = last_name
        newUser.surname = surname
        newUser.phone = phone
        newUser.email = email
        save()
    }
    
    func save() {
        do {
            try context.save()
            fetchUsers()
        } catch {
            print("Ошибка при сохранении: \(error)")
        }
    }
    
    func delete(_ user: User) {
        context.delete(user)
        save()
    }
    
    func updateUser(_ user: User,
                    first_name: String,
                    last_name: String,
                    surname: String,
                    phone: String,
                    email: String) {
        user.phone = phone
        user.first_name = first_name
        user.last_name = last_name
        user.surname = surname
        user.email = email
        save()
    }
}



