
build:
    @echo "TODO: docker build all images by default"
    @echo "TODO: docker build specific if given"

deploy profile:
    docker compose -f "{{ profile }}" up -d --build

profiles:
    @echo "TODO: list available profiles"
