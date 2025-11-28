"""Test wake word detection and toy interaction."""

import asyncio
from totoyai.services.gemini import gemini_service
from totoyai.services.tts import tts_service


async def detect_wake_word(text: str) -> bool:
    """Detect if wake word is present in text.

    Wake words: "hej toy", "hey toy", "hej leksak"
    """
    text_lower = text.lower()
    wake_words = ["hej toy", "hey toy", "hej leksak"]

    for wake_word in wake_words:
        if wake_word in text_lower:
            return True
    return False


async def toy_interaction(user_input: str, language: str = "sv"):
    """Simulate toy interaction with wake word detection."""

    print(f"\n🎤 User said: '{user_input}'")

    # Check for wake word
    if await detect_wake_word(user_input):
        print("✅ Wake word detected! Toy is now listening...")

        # Generate response using Gemini
        print("🤖 Generating response...")
        response_text, intent = await gemini_service.generate_conversation_response(
            user_input=user_input,
            language=language
        )

        print(f"💬 Toy responds: '{response_text}'")
        print(f"🎯 Detected intent: {intent}")

        # Convert to speech
        print("🔊 Converting to speech...")
        audio_bytes = await tts_service.synthesize_to_bytes(response_text, language)

        # Save audio
        output_file = "test_response.mp3"
        with open(output_file, "wb") as f:
            f.write(audio_bytes)

        print(f"✅ Audio saved to: {output_file}")
        print(f"📊 Audio size: {len(audio_bytes) / 1024:.1f} KB")

        return response_text, output_file
    else:
        print("❌ No wake word detected. Toy is sleeping...")
        return None, None


async def main():
    """Test wake word detection."""

    print("=" * 60)
    print("🧸 ToToy AI - Wake Word Detection Test")
    print("=" * 60)

    # Test cases
    test_inputs = [
        "Hej toy, kan du berätta en saga?",  # Should wake up
        "Vad är klockan?",  # Should not wake up
        "Hey toy, what's the weather like?",  # Should wake up (English)
        "Hej leksak, hur mår du?",  # Should wake up (Swedish alternative)
    ]

    for user_input in test_inputs:
        await toy_interaction(user_input, language="sv")
        print()

    print("=" * 60)
    print("✅ Test complete!")
    print("=" * 60)


if __name__ == "__main__":
    asyncio.run(main())
