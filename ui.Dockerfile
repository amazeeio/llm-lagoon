FROM ghcr.io/mckaywrigley/chatbot-ui:main

ENV OPENAI_API_KEY=not-needed \
    OPENAI_API_HOST=http://llama2-api:8000