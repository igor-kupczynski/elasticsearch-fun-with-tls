cwd := $(shell pwd)
es_dir := /usr/share/elasticsearch
es_version := 5.3.0

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

