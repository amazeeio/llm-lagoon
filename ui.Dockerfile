FROM ghcr.io/mckaywrigley/chatbot-ui:main

ENV OPENAI_API_KEY=not-needed \
    OPENAI_API_HOST=http://llm-api:8000 \
    NPM_CONFIG_CACHE=/tmp