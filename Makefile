cwd := $(shell pwd)
es_dir := /usr/share/elasticsearch
es_version := 5.3.0
network := internal-tls

.PHONY: prepare
prepare: network-create certs-generate

.PHONY: clean
clean: network-clean certs-clean data-clean



certs-generate: instances.yaml
	@ mkdir -p certificates
	@ docker run -it --rm \
		-v '$(cwd)/instances.yaml:$(es_dir)/config/x-pack/instances.yaml' \
		-v '$(cwd)/certificates:$(es_dir)/config/x-pack/certificates' \
		-w $(es_dir) \
		'docker.elastic.co/elasticsearch/elasticsearch:$(es_version)' \
		bin/x-pack/certgen -in instances.yaml -out $(es_dir)/config/x-pack/certificates/bundle.zip
	@ unzip certificates/bundle.zip -d certificates
	@ find certificates -type f | xargs chmod 600
	@ find certificates -type d | xargs chmod 700

.PHONY: certs-clean
certs-clean:
	@ rm -rf certificates



.PHONY: network-create
network-create:
	@ docker network create $(network)

.PHONY: network-clean
network-clean:
	@ docker network rm $(network) || echo "Network already deleted"


data-clean:
	@ rm -rf data-*


.PHONY: es1-run
es1-run:
	@ docker run -it --name elasticsearch-1 --rm \
		--memory=1g \
		-p 9200:9200 \
		-e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
		--network $(network) \
		-v `pwd`/data-1:$(es_dir)/data \
		-v `pwd`/elasticsearch-1.yml:$(es_dir)/config/elasticsearch.yml \
		-v `pwd`/certificates/ca/ca.crt:$(es_dir)/config/x-pack/tls/ca/ca.crt \
		-v `pwd`/certificates/node-0001:$(es_dir)/config/x-pack/tls/node-0001 \
		'docker.elastic.co/elasticsearch/elasticsearch:5.3.0'

.PHONY: es2-run
es2-run:
	@ docker run -it --name elasticsearch-2 --rm \
		--memory=1g \
		-e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
		--network $(network) \
		-v `pwd`/data-2:$(es_dir)/data \
		-v `pwd`/elasticsearch-2.yml:$(es_dir)/config/elasticsearch.yml \
		-v `pwd`/certificates/ca/ca.crt:$(es_dir)/config/x-pack/tls/ca/ca.crt \
		-v `pwd`/certificates/node-0002:$(es_dir)/config/x-pack/tls/node-0002 \
		'docker.elastic.co/elasticsearch/elasticsearch:5.3.0'
