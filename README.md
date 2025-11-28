# ToToyAI - AI-Powered Plush Toys Platform

**The First AI-Powered Plush Toy Platform in Sweden and EU**

ToToyAI brings artificial intelligence to traditional plush toys, creating interactive companions that can talk, tell stories, answer questions, and engage with children through natural conversation. This project aims to be the pioneering AI toy platform in the Swedish and European markets.

## 🎯 Vision

Transform ordinary plush toys into intelligent, educational companions by embedding AI capabilities that enable:

- Natural voice conversations with children
- Educational content delivery (math, science, general knowledge)
- Interactive storytelling and singing
- Weather information and daily assistance
- Safe, GDPR-compliant, child-appropriate interactions

## 🏗️ Architecture

### Hardware

- **Motherboard**: ESP32-S3 with WiFi and audio support
- **Audio**: I2S microphone and speaker
- **Power**: Dual 18650 batteries (4+ hours active use)
- **Wake Word**: Local wake word detection for privacy

### Backend (Self-Hosted VPS)

- **API**: FastAPI with JWT authentication
- **STT**: OpenAI Whisper for speech recognition
- **LLM**: Flexible integration (Ollama, Groq, Alibaba Qwen, MiniMax)
- **TTS**: Microsoft Edge TTS for natural speech
- **Session**: Redis for conversation context
- **Weather**: Open-Meteo API integration
- **Deployment**: Docker Compose for easy deployment

## 🚀 Features

### Core Capabilities

- ✅ Voice-activated conversations (wake word detection)
- ✅ Speech-to-text with Whisper
- ✅ LLM-powered responses (child-safe content filtering)
- ✅ Text-to-speech with natural voices
- ✅ Session management with conversation history
- ✅ Weather information with child-friendly descriptions

### Educational Features

- 📚 Math problem solving with explanations
- 🌍 General knowledge Q&A
- 📖 Interactive storytelling
- 🎵 Singing songs
- 🌤️ Weather updates

### Safety & Privacy

- 🔒 GDPR compliant (EU regulations)
- 🛡️ Content filtering for child safety
- 🔐 Secure TLS 1.3 communication
- 🚫 No audio storage beyond session
- 👨‍👩‍👧 Parental data deletion controls

## 📦 Project Structure

```
ToToyAI-LLM-TTS-VPS/
├── backend/                    # Backend services
│   ├── src/totoyai/
│   │   ├── api/               # REST API endpoints
│   │   ├── models/            # Data models
│   │   ├── services/          # Core services (STT, LLM, TTS, etc.)
│   │   └── main.py            # FastAPI application
│   ├── tests/                 # Test suite
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── pyproject.toml
├── .kiro/specs/               # Feature specifications
│   └── ai-toy-platform/
│       ├── requirements.md    # EARS requirements
│       ├── design.md          # Technical design
│       └── tasks.md           # Implementation tasks
└── README.md
```

## 🛠️ Quick Start

### Prerequisites

- Python 3.9+
- Docker & Docker Compose
- VPS with Ubuntu (for deployment)

### Local Development

1. **Clone the repository**

```bash
git clone https://github.com/bluehawana/ToToyAI-LLM-TTS-VPS.git
cd ToToyAI-LLM-TTS-VPS
```

2. **Install backend dependencies**

```bash
cd backend
pip install -e ".[dev]"
```

3. **Run tests**

```bash
pytest -v
```

4. **Start services with Docker**

```bash
docker-compose up -d
```

5. **Access API**

- API: http://localhost:8000
- Health check: http://localhost:8000/api/v1/health
- API docs: http://localhost:8000/docs

### VPS Deployment

1. **Setup VPS** (Ubuntu 22.04+)

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose-plugin -y
```

2. **Deploy application**

```bash
# Clone repository
git clone https://github.com/bluehawana/ToToyAI-LLM-TTS-VPS.git
cd ToToyAI-LLM-TTS-VPS/backend

# Start services
docker-compose up -d

# Check logs
docker-compose logs -f
```

## 🔧 Configuration

### LLM Provider Options

The platform supports multiple LLM providers:

**Ollama (Local)**

```python
# Default configuration in services/llm.py
ollama_url = "http://localhost:11434"
model = "llama3.1"
```

**Groq (Cloud)**

```python
# Fast inference with Groq
ollama_url = "https://api.groq.com/openai/v1"
# Add API key in environment
```

**Alibaba Qwen / MiniMax**

```python
# Configure for Chinese market
# Update endpoint and authentication
```

### Environment Variables

Create `.env` file:

```bash
# API Configuration
SECRET_KEY=your-secret-key-here
REDIS_URL=redis://localhost:6379

# LLM Configuration
OLLAMA_URL=http://ollama:11434
LLM_MODEL=llama3.1

# Optional: External API keys
GROQ_API_KEY=your-groq-key
```

## 📡 API Endpoints

### Authentication

- `POST /api/v1/auth/device` - Device authentication

### Conversation

- `POST /api/v1/conversation` - Process voice conversation
- `GET /api/v1/weather` - Get weather information

### Health

- `GET /api/v1/health` - Service health check

## 🧪 Testing

```bash
# Run all tests
pytest -v

# Run with coverage
pytest --cov=totoyai --cov-report=html

# Run specific test
pytest tests/test_health.py -v
```

## 🤝 Contributing

This is a pioneering project to bring AI-powered toys to Sweden and the EU market. Contributions are welcome!

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

Copyright © 2024 ToToyAI Project

This project is proprietary software. All rights reserved.

## 🌟 Roadmap

- [x] Backend API with authentication
- [x] STT, LLM, TTS integration
- [x] Weather service
- [ ] Storytelling feature
- [ ] Singing feature
- [ ] ESP32 firmware
- [ ] Mobile app for parents
- [ ] Multi-language support (Swedish, English)
- [ ] Cloud deployment guide

## 📞 Contact

- **Project**: https://github.com/bluehawana/ToToyAI-LLM-TTS-VPS
- **Author**: bluehawana

---

**Made with ❤️ in Sweden - Pioneering AI Toys in the EU**
