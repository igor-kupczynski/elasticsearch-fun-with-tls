cwd := $(shell pwd)
es_dir := /usr/share/elasticsearch
es_version := 5.3.0
network := internal-tls


.PHONY: clean
clean: compose-clean certs-clean data-clean


certs-generate: instances.yaml
	@ mkdir -p certificates
	@ docker run -it --rm \
		-v '$(cwd)/instances.yaml:$(es_dir)/config/x-pack/instances.yaml' \
		-v '$(cwd)/certificates:$(es_dir)/config/x-pack/certificates' \
		-w $(es_dir) \
		'docker.elastic.co/elasticsearch/elasticsearch:$(es_version)' \
		bin/x-pack/certgen -in instances.yaml -out $(es_dir)/config/x-pack/certificates/bundle.zip
	@ unzip certificates/bundle.zip -d certificates


.PHONY: certs-clean
certs-clean:
	@ rm -rf certificates


.PHONY: compose-clean
compose-clean:
	@ docker-compose down
	@ docker-compose rm -f


data-clean:
	@ rm -rf data-*
