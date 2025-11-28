# 🛒 ToToyAI Hardware - Shopping List

## 🚀 Quick Start Kit (~$30-40)

### Essential Components (Order from Amazon/AliExpress):

#### 1. ESP32-S3 Development Board

```
Product: ESP32-S3-DevKitC-1
Price: ~$10-15
Link: Search "ESP32-S3 DevKit" on Amazon
Quantity: 1-2 (get spare)
```

#### 2. MEMS Microphone Module

```
Product: INMP441 I2S Microphone
Price: ~$3-5
Link: Search "INMP441 microphone module"
Quantity: 2 (one for testing, one spare)
Features: I2S digital output, high SNR
```

#### 3. I2S Audio Amplifier

```
Product: MAX98357A I2S Amplifier Module
Price: ~$3-5
Link: Search "MAX98357A amplifier"
Quantity: 1-2
Features: 3W output, I2S input
```

#### 4. Speaker

```
Product: 3W 4Ω Speaker (40mm diameter)
Price: ~$2-3
Link: Search "3W 4 ohm speaker"
Quantity: 2
```

#### 5. Jumper Wires & Breadboard

```
Product: Breadboard + Jumper Wire Kit
Price: ~$5-8
Link: Search "breadboard jumper wire kit"
Quantity: 1 set
```

#### 6. USB-C Cable

```
Product: USB-C to USB-A Cable
Price: ~$3-5
Link: Any electronics store
Quantity: 1
```

### Total: ~$30-40

---

## 🔧 Optional Tools & Components

### For Prototyping:

#### 7. Li-ion Battery (Optional for mobile testing)

```
Product: 18650 Battery 2000mAh + Holder
Price: ~$5-8
Link: Search "18650 battery with holder"
Quantity: 1
Note: Get protected cells
```

#### 8. Battery Charger Module (Optional)

```
Product: TP4056 Charging Module
Price: ~$1-2
Link: Search "TP4056 USB charger"
Quantity: 1-2
```

#### 9. RGB LED (Optional for status)

```
Product: WS2812B LED Module
Price: ~$2-3
Link: Search "WS2812B LED module"
Quantity: 1
```

#### 10. Push Button

```
Product: Tactile Push Button
Price: ~$1-2
Link: Any electronics store
Quantity: 2-3
```

---

## 📦 Recommended Suppliers

### International (Ships Worldwide):

1. **AliExpress** - Cheapest, 2-4 weeks shipping
2. **Amazon** - Fast shipping, slightly more expensive
3. **Mouser** - Professional, reliable
4. **DigiKey** - Professional, fast shipping

### Europe:

1. **Electrokit** (Sweden) - Local, fast
2. **Conrad** - Germany, good selection
3. **Farnell** - UK, professional

### USA:

1. **Adafruit** - Great tutorials
2. **SparkFun** - Quality components
3. **Amazon** - Fast Prime shipping

---

## 🎯 Quick Start Order (Copy-Paste Ready)

### Amazon Search Terms:

```
1. "ESP32-S3 DevKitC development board"
2. "INMP441 I2S MEMS microphone module"
3. "MAX98357A I2S amplifier breakout"
4. "3W 4 ohm speaker 40mm"
5. "breadboard jumper wire kit"
6. "USB-C cable"
```

### AliExpress Search Terms (Cheaper):

```
1. "ESP32-S3 WROOM development board"
2. "INMP441 microphone I2S"
3. "MAX98357 amplifier module"
4. "3W speaker 4ohm"
5. "breadboard 830 points"
6. "dupont jumper wire"
```

---

## 💡 What You'll Build

### Phase 1: Basic Audio Test

```
ESP32-S3 → Microphone (record)
ESP32-S3 → Amplifier → Speaker (playback)
Test: Record and play back audio
```

### Phase 2: Wake Word Detection

```
ESP32-S3 + Microphone → Wake Word Detection
Test: Say "Hej Toy" and see LED light up
```

### Phase 3: Full Integration

```
ESP32-S3 + Microphone → Wake Word → WiFi → Backend
Backend → Response → ESP32-S3 → Speaker
Test: Full conversation with toy
```

---

## 📚 Learning Resources (FREE)

### Tutorials:

1. **ESP32-S3 Getting Started**

   - https://docs.espressif.com/projects/esp-idf/en/latest/esp32s3/

2. **I2S Audio on ESP32**

   - Search YouTube: "ESP32 I2S audio tutorial"

3. **Edge Impulse Wake Word**

   - https://docs.edgeimpulse.com/docs/tutorials/audio-classification

4. **PlatformIO Setup**
   - https://platformio.org/install

---

## ⏱️ Estimated Delivery Times

### Amazon Prime (USA/EU):

- 1-2 days

### Amazon Standard:

- 3-5 days

### AliExpress:

- Standard: 15-30 days
- Express: 7-15 days

### Mouser/DigiKey:

- USA: 1-3 days
- International: 3-7 days

---

## 💰 Budget Breakdown

### Minimum to Start:

```
ESP32-S3 DevKit:     $12
INMP441 Mic:         $4
MAX98357A Amp:       $4
Speaker:             $3
Breadboard Kit:      $6
USB Cable:           $3
---
Total:               $32
```

### Recommended Starter Kit:

```
Above items:         $32
Extra components:    $5
Battery + Charger:   $8
Tools (optional):    $10
---
Total:               $55
```

### Professional Setup:

```
Starter Kit:         $55
Oscilloscope:        $50-100
Logic Analyzer:      $20-30
Soldering Station:   $30-50
---
Total:               $155-235
```

---

## 🎁 Pre-Made Kits (Alternative)

If you want everything in one package:

### Option 1: ESP32 Audio Kit

```
Product: ESP32-S3-Korvo-2 Audio Kit
Price: ~$40-50
Includes: ESP32-S3, mics, speaker, amp
Link: Search "ESP32-S3 Korvo audio"
```

### Option 2: DIY Kit from Adafruit

```
Products:
- Adafruit ESP32-S3 Feather: $20
- I2S MEMS Mic: $7
- I2S Amp: $8
- Speaker: $5
Total: ~$40
```

---

## ✅ Checklist Before Ordering

- [ ] Verified ESP32-S3 (not ESP32 or ESP32-S2)
- [ ] Microphone is I2S digital (not analog)
- [ ] Amplifier is I2S compatible
- [ ] Speaker is 4Ω (not 8Ω)
- [ ] Have USB-C cable for ESP32-S3
- [ ] Have computer with USB port
- [ ] Checked shipping times
- [ ] Compared prices across suppliers

---

## 🚀 Next Steps After Ordering

While waiting for delivery:

1. **Install Software:**

   - [ ] Install VS Code
   - [ ] Install PlatformIO extension
   - [ ] Create Edge Impulse account
   - [ ] Clone ToToyAI repository

2. **Learn Basics:**

   - [ ] Watch ESP32 tutorials
   - [ ] Read I2S audio guide
   - [ ] Study Edge Impulse docs

3. **Plan Project:**

   - [ ] Design enclosure concept
   - [ ] Plan PCB layout
   - [ ] Prepare wake word samples

4. **Set Up Backend:**
   - [ ] Test current backend
   - [ ] Prepare WebSocket endpoint
   - [ ] Test audio streaming

---

## 📞 Need Help?

### Communities:

- ESP32 Forum: https://esp32.com
- Reddit: r/esp32
- Discord: ESP32 Community

### Our Support:

- GitHub Issues
- Email: support@totoyai.com (when ready)

---

## 🎉 Ready to Build!

Order the components and let's start building the hardware!

**Estimated time to first prototype: 2-3 weeks after components arrive**

🚀 Let's make ToToy come to life! 🧸
