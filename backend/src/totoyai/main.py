"""FastAPI application entry point."""

import logging

from fastapi import FastAPI

from totoyai.api.errors import setup_error_handlers
from totoyai.api.routes import router

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)

app = FastAPI(
    title="ToToyAI",
    description="AI-powered plush toy backend services",
    version="0.1.0",
)

app.include_router(router)
setup_error_handlers(app)
