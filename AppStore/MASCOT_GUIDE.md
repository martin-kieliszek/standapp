# Upio Mascot Guide

## Mascot Names by Language

The Upio app features a friendly mascot character with localized names:

| Language | Mascot Name | Pronunciation | Notes |
|----------|-------------|---------------|-------|
| English | **Upi** | "You-pee" | Short, friendly version of Upio |
| German | **Upi** | "Ooh-pee" | Same as English |
| Spanish | **Upi** | "Ooh-pee" | Same as English |
| French | **Upi** | "Ooh-pee" | Same as English |
| Japanese | **あぴくん** (Apikun) | "Ah-pee-kun" | "くん" (-kun) is a friendly suffix |
| Portuguese | **Upi** | "Ooh-pee" | Same as English |
| Chinese | **阿动** (Ā Dòng) | "Ah Dong" | 阿 is a friendly prefix, 动 means "move/active" |

## Mascot Character Design

### Character Concept
Upi/Apikun/Ā Dòng is a friendly, energetic character that embodies movement and positivity. The mascot should feel:
- **Approachable**: Soft, rounded shapes
- **Energetic**: Dynamic poses suggesting motion
- **Encouraging**: Friendly expression, welcoming pose
- **Neutral**: Works across all cultures and ages

### Design Specifications

#### Primary Design (Recommended)
- **Style**: Minimalist, modern, flat design
- **Shape**: Circular/rounded body with simple limbs
- **Color Palette**:
  - Primary: Blue (#007AFF - iOS system blue)
  - Secondary: Cyan (#5AC8FA)
  - Accent: Orange (#FF9500) for energy
- **Size Variations**:
  - Small: 44x44pt (icon size)
  - Medium: 120x120pt (card display)
  - Large: 256x256pt (onboarding, empty states)

#### Character Elements
1. **Body**: Simple circular or pill-shaped form
2. **Face**: Minimalist eyes (two dots) and curved smile
3. **Arms/Limbs**: Optional, simple stick-like appendages
4. **Motion Lines**: Subtle lines suggesting movement
5. **Expression**: Always positive and encouraging

### Visual Style Guide

#### For Japanese Market (あぴくん)
- Slightly more "kawaii" (cute) styling
- Rounder, softer edges
- Possibly wearing a small headband or having distinctive hair tuft
- May include small "sparkle" effects

#### For Chinese Market (阿动)
- Clean, modern appearance
- Slightly more athletic/sporty look
- May include subtle motion blur or speed lines
- Color palette can lean toward warmer tones (orange/red accents)

#### For Other Markets (Upi)
- Universal, neutral design
- Balanced between cute and modern
- Emphasis on clarity and recognizability

## Usage Guidelines

### Where to Display the Mascot

1. **Onboarding Flow** (HIGH PRIORITY)
   - Welcome screen: Large mascot with greeting
   - Tutorial steps: Small mascot providing guidance
   - Final screen: Mascot celebrating completion

2. **Empty States**
   - No exercises logged today
   - No achievements yet
   - No custom exercises created
   - First time using a feature

3. **Encouragement Moments**
   - After logging an exercise
   - Reaching a milestone (streak, achievement)
   - Weekly insights summary
   - Progress report highlights

4. **Settings About Section**
   - Small mascot icon next to app version
   - Credits/acknowledgments

5. **Notification Content (Optional)**
   - Small mascot icon in notification image
   - Rich notifications with mascot

### Mascot Messages

The mascot should provide contextual, localized messages using:
- `LocalizedString.General.mascotGreeting` - "Hi! I'm Upi!" / "こんにちは！あぴくんだよ！" / "你好！我是阿动！"
- `LocalizedString.General.mascotEncouragement` - "You got this!" / "がんばって！" / "加油！"

## Implementation Location

### Recommended First Implementation: Onboarding Welcome Screen

Add the mascot to the first onboarding screen with:
1. Large mascot illustration (center of screen)
2. Localized greeting message
3. App name below
4. "Get Started" button

### Code Example
```swift
struct OnboardingWelcomeView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Mascot Image
            Image("Mascot_Large")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .accessibilityHidden(true)

            // Greeting
            Text(LocalizedString.General.mascotGreeting)
                .font(.title)
                .fontWeight(.semibold)

            // App Name
            Text(LocalizedString.General.appName)
                .font(.largeTitle)
                .fontWeight(.bold)

            Spacer()

            // Get Started Button
            Button(LocalizedString.Onboarding.getStarted) {
                // Continue onboarding
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

## Asset Naming Convention

```
Assets.xcassets/
└── Mascot/
    ├── Mascot_Small.imageset/      # 44x44pt
    ├── Mascot_Medium.imageset/     # 120x120pt
    ├── Mascot_Large.imageset/      # 256x256pt
    ├── Mascot_Waving.imageset/     # Greeting pose
    ├── Mascot_Celebrating.imageset/ # Achievement pose
    └── Mascot_Thinking.imageset/   # Tutorial/help pose
```

## Localization Notes

- The mascot's **name** changes per language (Upi/あぴくん/阿动)
- The mascot's **appearance** can be the same across all languages OR have subtle regional variations
- **Messages** from the mascot should always be fully localized
- Use `LocalizedString.General.mascotName` to display the mascot's name in UI

## Design Tools & Resources

### Recommended Tools for Creation
- **Vector**: Figma, Adobe Illustrator, Sketch
- **Raster**: Procreate (iPad), Affinity Designer
- **3D** (if desired): Blender, Cinema 4D (for more dimensional look)

### Export Specifications
- **Format**: PDF (vector) or PNG with @1x, @2x, @3x
- **Color Space**: Display P3 or sRGB
- **Transparency**: Yes (alpha channel)
- **File Naming**: `Mascot_[Variant]@[scale]x.png`

## Cultural Considerations

### Japanese Market (あぴくん)
- "くん" suffix implies friendly, approachable male character
- Kawaii aesthetic is culturally appropriate
- Can be slightly playful/childlike
- Bright, cheerful colors work well

### Chinese Market (阿动)
- "阿" prefix creates friendly, informal tone
- "动" (move/motion) reinforces app's purpose
- Clean, modern design preferred
- Athletic/healthy appearance resonates well

### Western Markets (Upi)
- Keep it simple and universal
- Avoid overly cutesy or childish design
- Modern, minimalist aesthetic
- Focus on functionality and clarity

## Next Steps

1. **Design Creation**: Create mascot illustrations in 3 sizes
2. **Asset Integration**: Add to Assets.xcassets
3. **Onboarding Implementation**: Add to welcome screen
4. **Empty State Integration**: Add to empty state views
5. **Testing**: Verify appearance across all languages and devices

## Reference Examples

**Style Inspiration:**
- iOS Memoji (simplified version)
- Duolingo's Duo owl (friendly, encouraging)
- Headspace animations (calm, supportive)
- Slack emoji style (simple, expressive)

**Key Principle:**
The mascot should feel like a supportive friend, not a demanding coach. It celebrates with you, encourages you, and makes the app feel more personal and engaging.
