# UX33: Progress Photos - Track Visual Fitness Progress

**Status**: ⏳ Pending  
**Created**: 2026-01-04  
**Category**: Feature Enhancement  
**Priority**: Low  
**Complexity**: Medium (4-5 hours)

## Problem

StandFit tracks numerical data (reps, exercises, streaks) but lacks visual progress tracking. Users cannot:
- Take progress photos
- View before/after comparisons
- Track body composition changes visually
- Associate photos with specific dates/achievements

## Solution

Add progress photo feature:
- Weekly/monthly photo capture
- Before/after slider comparison
- Photo gallery timeline
- Privacy-first local storage
- Optional photo notes

## Implementation

### Photo Storage

```swift
struct ProgressPhoto: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    var imageData: Data
    var note: String?
    var weight: Double?  // Optional
    
    var image: UIImage? {
        UIImage(data: imageData)
    }
}

// Store photos in app documents directory
class PhotoManager {
    private let photosURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("progress_photos")
    }()
    
    func savePhoto(_ image: UIImage, note: String? = nil) throws -> ProgressPhoto {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw PhotoError.compressionFailed
        }
        
        let photo = ProgressPhoto(
            id: UUID(),
            timestamp: Date(),
            imageData: imageData,
            note: note
        )
        
        // Save to disk
        try? FileManager.default.createDirectory(at: photosURL, withIntermediateDirectories: true)
        let fileURL = photosURL.appendingPathComponent("\\(photo.id.uuidString).jpg")
        try imageData.write(to: fileURL)
        
        return photo
    }
}
```

### Photo Capture View

```swift
import PhotosUI

struct ProgressPhotoView: View {
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photos: [ProgressPhoto] = []
    @State private var note: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Photo picker
                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images
                    ) {
                        Label("Take Progress Photo", systemImage: "camera")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Photo grid
                    LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                        ForEach(photos) { photo in
                            NavigationLink {
                                PhotoDetailView(photo: photo)
                            } label: {
                                AsyncImage(url: photo.imageURL) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fill)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Progress Photos")
        }
        .onChange(of: selectedPhoto) { newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    savePhoto(image)
                }
            }
        }
    }
}
```

### Before/After Comparison

```swift
struct BeforeAfterView: View {
    let beforePhoto: ProgressPhoto
    let afterPhoto: ProgressPhoto
    @State private var sliderPosition: CGFloat = 0.5
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Before image (full)
                Image(uiImage: beforePhoto.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
                // After image (masked by slider)
                Image(uiImage: afterPhoto.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .mask(
                        Rectangle()
                            .frame(width: geometry.size.width * sliderPosition)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    )
                
                // Slider line
                Rectangle()
                    .fill(.white)
                    .frame(width: 2)
                    .position(x: geometry.size.width * sliderPosition, y: geometry.size.height / 2)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        sliderPosition = max(0, min(1, value.location.x / geometry.size.width))
                    }
            )
        }
    }
}
```

## Features

### Weekly Photo Reminders
Notify users to take progress photo:
```swift
func schedulePhotoReminder() {
    let content = UNMutableNotificationContent()
    content.title = "Progress Photo Time!"
    content.body = "Track your weekly progress with a quick photo"
    
    var dateComponents = DateComponents()
    dateComponents.weekday = 1  // Sunday
    dateComponents.hour = 9
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    // ... schedule notification
}
```

### Photo Timeline
Display photos chronologically with date markers:
```
Week 1 ─────────────
[Photo]

Week 4 ─────────────
[Photo]

Week 8 ─────────────
[Photo]
```

### Privacy Options
- Photos never leave device
- Face blur option
- Photo deletion
- Export photos separately from other data

## Benefits

- Visual motivation
- Track body composition changes
- Before/after comparisons
- Long-term progress evidence
- Shareable (UX23 integration)

## Technical Requirements

- PhotosUI framework (iOS 16+)
- Local storage (10-50 MB per photo)
- Image compression
- Privacy permissions (Photo Library)

## Related Issues

- **UX23**: Social Sharing - Share before/after photos
- **UX31**: Notes - Add notes to photos
- **UX22**: Data Export - Export photo archive

## Conclusion

Popular fitness app feature. **4-5 hour implementation**. Provides powerful visual progress tracking that complements numerical data. Optional feature for engaged users.
