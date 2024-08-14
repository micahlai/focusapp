import SwiftUI
import IOKit.pwr_mgt

struct ContentView: View {
    @State private var image: NSImage? = nil
    @State private var currentTime = Date()
    @State private var sleepAssertionID: IOPMAssertionID = 0
    
    private let imageChangeInterval: TimeInterval = 300.0 // 3 seconds
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
                Spacer()
                Text(getFormattedTime(from: true))
                    .font(.system(size: 36, weight: .light))
                    .foregroundColor(.white)
                    .shadow(radius: 5) // Center the text
                    //.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                Text(getFormattedTime(from: false))
                    .font(.system(size: 204, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                     // Center the text
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .onAppear {
            startTimers(from: "/Users/micahlai/Pictures/Slideshow")
            preventSleep()
        }
        .onDisappear {
            allowSleep()
        }
        
    }
    func preventSleep() {
            let reasonForActivity = "App needs to prevent sleep while active" as CFString
            let result = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString,
                                                     IOPMAssertionLevel(kIOPMAssertionLevelOn),
                                                     reasonForActivity,
                                                     &sleepAssertionID)
            if result != kIOReturnSuccess {
                print("Failed to create sleep assertion: \(result)")
            }
        }

        func allowSleep() {
            IOPMAssertionRelease(sleepAssertionID)
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
            formatter.dateFormat = "EEEE, M-dd-yy"
            return formatter.string(from: currentTime)
        }else{
            formatter.dateFormat = "h:mm"
            return formatter.string(from: currentTime)
        }
    }
    
}


