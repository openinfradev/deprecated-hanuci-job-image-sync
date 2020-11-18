FROM alpine/git:v2.26.2
COPY docker /bin/
COPY helm /bin/

ENTRYPOINT ["docker"]
CMD ["-v"]
