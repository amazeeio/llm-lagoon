# lagoon-llama2
lagoon going llama2

# local run on mac M1
```sh
docker build --platform linux/amd64 .
docker run -it --platform linux/amd64

docker run --rm -it --platform linux/amd64 -v '/Users/marco/Downloads:/data' $(docker build --platform linux/amd64 -q .)
```