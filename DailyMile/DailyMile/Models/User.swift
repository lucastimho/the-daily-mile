import Foundation

struct User: Identifiable {
    var id = UUID()
    var username: String
    var password: String
    var profile: UserProfile
    
    // Static users for demo authentication
    static let demoUsers = [
        User(
            username: "emma",
            password: "password1",
            profile: UserProfile.demoProfiles[0] // Emma (beginner)
        ),
        User(
            username: "michael",
            password: "password2",
            profile: UserProfile.demoProfiles[1] // Michael (intermediate)
        ),
        User(
            username: "sarah",
            password: "password3",
            profile: UserProfile.demoProfiles[2] // Sarah (advanced)
        )
    ]
    
    // Authentication method
    static func authenticate(username: String, password: String) -> User? {
        return demoUsers.first(where: { 
            $0.username.lowercased() == username.lowercased() && 
            $0.password == password 
        })
    }
} 