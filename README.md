This is a companion repo for
the
[_Encrypt the traffic between nodes in your elasticsearch cluster_](https://kupczynski.info/2017/04/02/elasticsearch-fun-with-tls.html) blogpost. Please
check the post first.

If you want to follow along with the post, make sure that you have
installed [docker-compose](https://kupczynski.info/2017/04/02/elasticsearch-fun-with-tls.html) or
[docker for mac](https://docs.docker.com/docker-for-mac/) and GNU Make and unzip tools.

The internal tls playbook

```sh
# Generate the certificates
$ make certs-generate

# Run the first node
docker-compose up elasticsearch-1

# Check the cluster configuration
watch -n 1 "curl -s --cacert certificates/ca/ca.crt -u 'elastic:changeme' https://localhost:9200/_cat/nodes"

# Run the second node
docker-compose up elasticsearch-2 

# Notice how it joins the cluster

# Run the third node
docker-compose up elasticsearch-3

# Notice how it is rejected due to its alien certificate
```



