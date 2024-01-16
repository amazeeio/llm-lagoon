# LLM Lagoon

lagoon going open source LLMs

# local run on mac M1

Prefer to use the shell script `mac-local.sh` instead of using docker due to the support of using `METAL` GPU when running locally without docker.

Otherwise if you really need to:

```sh
docker-compose up -d
```

# curl test openai api

```sh
curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
     "model": "gpt-3.5-turbo",
     "messages": [{"role": "user", "content": "What do you think about when nobody is watching?"}],
     "temperature": 0.7,
     "max_tokens": 2000
   }'
```
