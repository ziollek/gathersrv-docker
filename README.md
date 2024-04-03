# Purpose

It shows how to automate building your own docker with CoreDNS + gathersrv plugin


# Building your docker image:

```
make
```

It will build image `gathersrv-demo:latest`. You can control the name and version by variables:

```
make IMAGE=your-name IMAGE_VERSION=0.0.1
```
will build image `your-name:version`

Similarly, you can overwrite default base image: `coredns/coredns`

```
make BASE_IMAGE=ubuntu:latest
```

# Running container locally

```
make run DNS_PORT=5300 METRICS_PORT=9253
```

Please bear in mind, if you build a container with a custom name, you will have to pass image related variables:

```
make run DNS_PORT=5300 METRICS_PORT=9253 IMAGE=your-name IMAGE_VERSION=0.0.1
```

# Testing

Sample configuration that emulates gathering srv records from three k8s clusters, can be found in [here](./docker/Corefile)

```
dig  -t SRV _service._tcp.my-service-headless.my-namespace.svc.cluster.all -p5300 @127.0.0.1

; <<>> DiG 9.18.20 <<>> -t SRV _service._tcp.my-service-headless.my-namespace.svc.cluster.all -p5300 @127.0.0.1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 9053
;; flags: qr aa rd; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 086e7cce0c4a8bf1 (echoed)
;; QUESTION SECTION:
;_service._tcp.my-service-headless.my-namespace.svc.cluster.all.	IN SRV

;; ANSWER SECTION:
_service._tcp.my-service-headless.my-namespace.svc.cluster.all.	10 IN SRV 0 100 2379 c3-my-service-headless.my-namespace.svc.cluster.all.
_service._tcp.my-service-headless.my-namespace.svc.cluster.all.	10 IN SRV 0 100 2379 c1-my-service-headless.my-namespace.svc.cluster.all.
_service._tcp.my-service-headless.my-namespace.svc.cluster.all.	10 IN SRV 0 100 2379 c2-my-service-headless.my-namespace.svc.cluster.all.

;; Query time: 2 msec
;; SERVER: 127.0.0.1#5300(127.0.0.1) (UDP)
;; WHEN: Wed Apr 03 18:19:51 CEST 2024
;; MSG SIZE  rcvd: 502
```
