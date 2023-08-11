# lagoon-llama2
lagoon going llama2

# local run on mac M1
```sh
docker build --platform linux/amd64 .
docker run -it --platform linux/amd64
```

```sh
docker run --rm -it --platform linux/amd64 -v '/Users/marco/Downloads:/data' -p '8000:8000' $(docker build --platform linux/amd64 -q .)
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