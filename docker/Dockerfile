ARG base=coredns/coredns

FROM $base

ADD coredns /coredns
ADD Corefile /etc/coredns/Corefile

ENTRYPOINT ["/coredns"]
