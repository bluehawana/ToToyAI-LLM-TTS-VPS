# Implementation Plan

## Phase 1: Project Setup and Core Infrastructure

- [ ] 1. Initialize project structure and dependencies

  - [-] 1.1 Create backend directory structure (api, services, models, tests)

    - Set up Python project with pyproject.toml
    - Configure FastAPI application skeleton
    - Set up pytest and hypothesis for testing

    - _Requirements: 10.1, 12.1_

  - [x] 1.2 Create Docker configuration for development

    - Write Dockerfile for backend service
    - Create docker-compose.yml with Redis and API services
    - _Requirements: 10.1_

  - [ ] 1.3 Define core data models and interfaces
    - Create Pydantic models for Device, ConversationRequest, ConversationResponse, WeatherData, SessionContext
    - _Requirements: 12.1, 12.5_
  - [ ]\* 1.4 Write property test for JSON serialization round trip
    - **Property 30: JSON Serialization Round Trip**
    - **Validates: Requirements 12.5, 12.6**

## Phase 2: API Gateway and Authentication

- [ ] 2. Implement API Gateway with authentication

  - [x] 2.1 Create REST API endpoints structure

    - Implement POST /api/v1/conversation endpoint skeleton
    - Implement POST /api/v1/auth/device endpoint
    - Implement GET /api/v1/health endpoint
    - Implement GET /api/v1/weather endpoint
    - _Requirements: 12.1, 12.2_

  - [x] 2.2 Implement device authentication middleware

    - Create JWT-based authentication
    - Implement device credential validation
    - Add authentication middleware to protected routes
    - _Requirements: 9.2, 9.5_

  - [ ]\* 2.3 Write property test for authentication validation
    - **Property 21: Authentication Validation**
    - **Validates: Requirements 9.2, 9.5**
  - [ ] 2.4 Implement request validation and error handling
    - Add JSON schema validation for requests
    - Implement standardized error response format
    - Add request logging
    - _Requirements: 12.2, 12.6, 10.4_
  - [ ]\* 2.5 Write property test for API response format
    - **Property 29: API Response Format**
    - **Validates: Requirements 12.1, 12.2**
  - [x]\* 2.6 Write property test for error logging completeness

    - **Property 24: Error Logging Completeness**
    - **Validates: Requirements 10.4**

- [x] 3. Checkpoint - Ensure all tests pass

  - Ensure all tests pass, ask the user if questions arise.

## Phase 3: Session Management

- [ ] 4. Implement session management with Redis

  - [ ] 4.1 Create SessionManager service

    - Implement get_context, update_context, clear_session methods
    - Configure Redis connection

    - Set session expiration (30 minutes)
    - _Requirements: 2.4_

  - [x] 4.2 Implement conversation context tracking

    - Store message history per session
    - Maintain story context for continuation
    - _Requirements: 2.4, 5.5_

  - [ ]\* 4.3 Write property test for session context preservation
    - **Property 6: Session Context Preservation**
    - **Validates: Requirements 2.4**

## Phase 4: STT Service Integration

- [x] 5. Implement Speech-to-Text service

  - [ ] 5.1 Create STT service wrapper for Whisper

    - Implement transcribe method
    - Handle audio format conversion

    - Return TranscriptResult with confidence score

    - _Requirements: 1.3, 1.4_

  - [ ] 5.2 Implement STT error handling and fallback

    - Add timeout handling

    - Return friendly error message on failure
    - _Requirements: 1.5_

  - [ ]\* 5.3 Write property test for STT error fallback
    - **Property 3: STT Error Fallback**
    - **Validates: Requirements 1.5**

## Phase 5: LLM Service Integration

- [ ] 6. Implement LLM service with Ollama

  - [ ] 6.1 Create LLM service wrapper

    - Implement generate_response method
    - Configure Ollama client connection

    - Set up system prompt for child-friendly responses

    - _Requirements: 2.1, 2.2_

  - [ ] 6.2 Implement content filtering
    - Create blocklist for inappropriate content patterns
    - Add pre-response and post-response filtering
    - _Requirements: 2.3_
  - [ ]\* 6.3 Write property test for content filter
    - **Property 5: Content Filter Blocks Inappropriate Content**
    - **Validates: Requirements 2.3**
  - [ ] 6.4 Implement LLM error handling and fallback
    - Add timeout handling
    - Return friendly fallback message on failure
    - _Requirements: 2.5_
  - [ ]\* 6.5 Write property test for LLM response generation

    - **Property 4: LLM Response Generation**

    - **Validates: Requirements 2.1**

  - [ ]\* 6.6 Write property test for LLM error fallback
    - **Property 7: LLM Error Fallback**
    - **Validates: Requirements 2.5**

- [ ] 7. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Phase 6: TTS Service Integration

- [ ] 8. Implement Text-to-Speech service
  - [ ] 8.1 Create TTS service wrapper for Coqui/Piper
    - Implement synthesize method with streaming support
    - Configure child-friendly voice profile
    - _Requirements: 3.1, 3.2_
  - [ ] 8.2 Implement TTS error handling and fallback
    - Add timeout handling
    - Return pre-recorded fallback audio on failure
    - Create fallback audio files
    - _Requirements: 3.5_
  - [ ]\* 8.3 Write property test for TTS produces audio
    - **Property 8: TTS Produces Audio Output**
    - **Validates: Requirements 3.1**
  - [ ]\* 8.4 Write property test for TTS error fallback
    - **Property 9: TTS Error Fallback**
    - **Validates: Requirements 3.5**

## Phase 7: Weather Feature

- [ ] 9. Implement weather service
  - [ ] 9.1 Create weather service with Open-Meteo integration
    - Implement get_weather method
    - Parse and format weather data
    - Ensure temperature in Celsius
    - _Requirements: 4.1, 4.3_
  - [ ] 9.2 Implement weather error handling
    - Handle API failures gracefully
    - Return unavailability message on failure
    - _Requirements: 4.4_
  - [ ]\* 9.3 Write property test for weather query returns data
    - **Property 10: Weather Query Returns Data**
    - **Validates: Requirements 4.1**
  - [ ]\* 9.4 Write property test for temperature in Celsius
    - **Property 11: Temperature in Celsius**
    - **Validates: Requirements 4.3**
  - [ ]\* 9.5 Write property test for weather error fallback
    - **Property 12: Weather Service Error Fallback**
    - **Validates: Requirements 4.4**

## Phase 8: Storytelling Feature

- [ ] 10. Implement storytelling feature

  - [ ] 10.1 Create story generation in LLM service
    - Implement generate_story method
    - Configure story length constraints (300-750 words)
    - Add story theme handling
    - _Requirements: 5.1, 5.3_
  - [ ] 10.2 Implement story continuation
    - Store current story in session context
    - Handle "continue story" requests
    - _Requirements: 5.5_
  - [ ]\* 10.3 Write property test for story length bounds
    - **Property 13: Story Length Bounds**
    - **Validates: Requirements 5.1**
  - [ ]\* 10.4 Write property test for story continuation context
    - **Property 14: Story Continuation Context**
    - **Validates: Requirements 5.5**

- [ ] 11. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Phase 9: Singing Feature

- [ ] 12. Implement singing feature
  - [ ] 12.1 Create song service
    - Implement song lookup for known songs
    - Store pre-recorded song audio files
    - _Requirements: 6.1, 6.2_
  - [ ] 12.2 Implement lyrics generation fallback
    - Generate simple lyrics via LLM for unknown songs
    - Route generated lyrics through TTS
    - _Requirements: 6.3_
  - [ ]\* 12.3 Write property test for song request produces output
    - **Property 15: Song Request Produces Output**
    - **Validates: Requirements 6.1, 6.2, 6.3**

## Phase 10: Educational Q&A Feature

- [ ] 13. Implement educational Q&A
  - [ ] 13.1 Create math question handler
    - Detect math questions in user input
    - Compute correct answers for verification
    - Format child-friendly explanations
    - _Requirements: 7.1, 7.2_
  - [ ] 13.2 Implement inappropriate topic redirection
    - Create topic blocklist
    - Redirect to safe topics when triggered
    - _Requirements: 7.4_
  - [ ]\* 13.3 Write property test for math answer correctness
    - **Property 16: Math Answer Correctness**
    - **Validates: Requirements 7.1**
  - [ ]\* 13.4 Write property test for inappropriate topic redirection
    - **Property 17: Inappropriate Topic Redirection**
    - **Validates: Requirements 7.4**

## Phase 11: Privacy and Safety

- [ ] 14. Implement privacy and safety features

  - [ ] 14.1 Implement audio data non-persistence
    - Delete audio after processing
    - Verify no audio stored beyond session
    - _Requirements: 11.1_
  - [ ] 14.2 Implement PII detection and blocking
    - Create PII pattern detection
    - Block requests attempting to extract personal info
    - _Requirements: 11.3_
  - [ ] 14.3 Implement safety concern logging
    - Detect safety concerns in conversations
    - Log events without storing content
    - _Requirements: 11.4_
  - [ ] 14.4 Implement data deletion endpoint
    - Create DELETE /api/v1/device/{device_id}/data endpoint
    - Remove all associated data from storage
    - _Requirements: 11.5_
  - [ ]\* 14.5 Write property test for audio data non-persistence
    - **Property 25: Audio Data Non-Persistence**
    - **Validates: Requirements 11.1**
  - [ ]\* 14.6 Write property test for PII request blocking
    - **Property 26: PII Request Blocking**
    - **Validates: Requirements 11.3**
  - [ ]\* 14.7 Write property test for safety concern logging
    - **Property 27: Safety Concern Logging**
    - **Validates: Requirements 11.4**
  - [ ]\* 14.8 Write property test for data deletion completeness
    - **Property 28: Data Deletion Completeness**
    - **Validates: Requirements 11.5**

- [ ] 15. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Phase 12: Conversation Flow Integration

- [ ] 16. Integrate full conversation pipeline
  - [ ] 16.1 Wire up conversation endpoint
    - Connect STT → LLM → TTS pipeline
    - Implement intent detection (weather, story, song, math, general)
    - Route to appropriate handlers
    - _Requirements: 1.3, 2.1, 3.1_
  - [ ] 16.2 Implement audio streaming response
    - Stream TTS audio to client
    - Handle partial response delivery
    - _Requirements: 3.4_
  - [ ]\* 16.3 Write integration tests for conversation flow
    - Test end-to-end conversation
    - Test multi-turn conversations
    - _Requirements: 2.4_

## Phase 13: Device Firmware (ESP32)

- [ ] 17. Create ESP32 firmware foundation

  - [ ] 17.1 Set up ESP-IDF project structure
    - Configure WiFi connectivity
    - Set up I2S for audio input/output
    - _Requirements: 9.1_
  - [ ] 17.2 Implement wake word detection
    - Integrate wake word model
    - Trigger listening mode on detection
    - _Requirements: 1.1_
  - [ ] 17.3 Implement audio capture with silence detection
    - Capture audio until 2s silence
    - Buffer audio for transmission
    - _Requirements: 1.2_
  - [ ]\* 17.4 Write property test for silence detection
    - **Property 2: Silence Detection Terminates Capture**
    - **Validates: Requirements 1.2**

- [ ] 18. Implement device communication

  - [ ] 18.1 Implement TLS client for API communication
    - Configure TLS 1.3
    - Implement device authentication
    - _Requirements: 9.1, 9.2_
  - [ ] 18.2 Implement request queue for offline mode
    - Queue requests when disconnected
    - Retry on reconnection
    - _Requirements: 9.3_
  - [ ] 18.3 Implement timeout handling
    - Play waiting message on timeout
    - Handle retry logic
    - _Requirements: 9.4_
  - [ ]\* 18.4 Write property test for TLS encryption
    - **Property 20: TLS Encryption Required**
    - **Validates: Requirements 9.1**
  - [ ]\* 18.5 Write property test for request queue on disconnect
    - **Property 22: Request Queue on Disconnect**
    - **Validates: Requirements 9.3**
  - [ ]\* 18.6 Write property test for timeout notification
    - **Property 23: Timeout Notification**
    - **Validates: Requirements 9.4**

- [ ] 19. Implement power management

  - [ ] 19.1 Implement battery monitoring
    - Read battery level from ADC
    - Trigger notifications at thresholds
    - _Requirements: 8.2, 8.3_
  - [ ] 19.2 Implement sleep mode
    - Enter sleep after 5 minutes idle
    - Wake on button press or wake word
    - _Requirements: 8.4, 8.5_
  - [ ]\* 19.3 Write property test for battery notification thresholds
    - **Property 18: Battery Notification Thresholds**
    - **Validates: Requirements 8.2, 8.3**
  - [ ]\* 19.4 Write property test for idle timeout sleep mode
    - **Property 19: Idle Timeout Sleep Mode**
    - **Validates: Requirements 8.4**

- [ ] 20. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Phase 14: Deployment Configuration

- [ ] 21. Create production deployment configuration

  - [ ] 21.1 Create production Docker Compose
    - Configure Nginx reverse proxy with TLS
    - Set up service health checks
    - Configure resource limits
    - _Requirements: 10.1, 9.1_
  - [ ] 21.2 Create deployment documentation
    - Write VPS setup instructions
    - Document environment variables
    - Create backup and restore procedures
    - _Requirements: 10.1_
  - [ ]\* 21.3 Write property test for API backward compatibility
    - **Property 31: API Backward Compatibility**
    - **Validates: Requirements 12.4**

- [ ] 22. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
