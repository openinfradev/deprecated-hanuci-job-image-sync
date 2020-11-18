FROM alpine/git:v2.26.2
COPY docker /bin/

ENTRYPOINT ["docker"]
CMD ["-v"]
