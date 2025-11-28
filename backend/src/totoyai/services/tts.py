"""Text-to-Speech service."""

import logging
from typing import AsyncIterator

logger = logging.getLogger(__name__)


class TTSService:
    """Text-to-Speech service using edge-tts (Microsoft Edge TTS)."""

    def __init__(self, voice: str = "en-US-AriaNeural"):
        """Initialize TTS service with voice profile."""
        self.voice = voice

    async def synthesize(
        self,
        text: str,
        voice_profile: str = "friendly_child",
    ) -> AsyncIterator[bytes]:
        """Convert text to streaming audio.

        Args:
            text: Text to convert to speech
            voice_profile: Voice profile to use (friendly_child, etc)

        Yields:
            Audio chunks as bytes
        """
        try:
            import edge_tts

            # Use child-friendly voice
            voice = "en-US-JennyNeural"  # Warm, friendly female voice

            communicate = edge_tts.Communicate(text, voice)

            async for chunk in communicate.stream():
                if chunk["type"] == "audio":
                    yield chunk["data"]

        except Exception as e:
            logger.error(f"TTS synthesis failed: {e}")
            raise TTSError(f"Failed to synthesize speech: {e}")

    async def synthesize_to_bytes(self, text: str) -> bytes:
        """Convert text to complete audio bytes."""
        chunks = []
        async for chunk in self.synthesize(text):
            chunks.append(chunk)
        return b"".join(chunks)


class TTSError(Exception):
    """TTS service error."""
    pass


# Fallback audio message
TTS_FALLBACK_MESSAGE = "I'm having trouble speaking right now. Please try again!"

# Global TTS service instance
tts_service = TTSService()
