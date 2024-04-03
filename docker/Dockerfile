ARG base=coredns/coredns

FROM $base

WORKDIR /

ADD coredns /coredns
ADD Corefile /Corefile

ENTRYPOINT ["/coredns"]
