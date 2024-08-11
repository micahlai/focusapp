import SwiftUI

struct ContentView: View {
    @State private var image: NSImage? = nil
    @State private var currentTime = Date()
    
    private let imageChangeInterval: TimeInterval = 3.0 // 3 seconds
    private let clockUpdateInterval: TimeInterval = 1.0 // 1 second

    var body: some View {
        ZStack {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill() // Fill the entire window
                    .edgesIgnoringSafeArea(.all) // Extend the image to fill the entire window
            } else {
                Color.black.edgesIgnoringSafeArea(.all)
            }
            VStack {
                Text(getFormattedTime(from: true))
                    .font(.system(size: 36, weight: .light))
                    .foregroundColor(.white)
                    .shadow(radius: 5) // Center the text
                    //.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                Text(getFormattedTime(from: false))
                    .font(.system(size: 104, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Center the text
            }
        }
        .onAppear {
            startTimers(from: "/Users/micahlai/Pictures/Slideshow")
        }
    }

    func startTimers(from path: String) {
        loadRandomImage(from: path)
        
        Timer.scheduledTimer(withTimeInterval: imageChangeInterval, repeats: true) { _ in
            loadRandomImage(from: path)
        }
        
        Timer.scheduledTimer(withTimeInterval: clockUpdateInterval, repeats: true) { _ in
            self.currentTime = Date()
        }
    }

    func loadRandomImage(from path: String) {
        let fileManager = FileManager.default
        do {
            let imagePaths = try fileManager.contentsOfDirectory(atPath: path)
                .filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".png") || $0.hasSuffix(".jpeg") }
            
            if let randomImagePath = imagePaths.randomElement() {
                let fullPath = "\(path)/\(randomImagePath)"
                self.image = NSImage(contentsOfFile: fullPath)
            }
        } catch {
            print("Error loading images: \(error)")
        }
    }

    func getFormattedTime(from date: Bool) -> String {
        let formatter = DateFormatter()
        if(date){
            formatter.dateFormat = "EEEE, MM-dd-yy"
            return formatter.string(from: currentTime)
        }else{
            formatter.dateFormat = "H:mm"
            return formatter.string(from: currentTime)
        }
    }
    
}


struct RandomImageApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600) // Optional: Define a minimum window size
        }
    }
}
