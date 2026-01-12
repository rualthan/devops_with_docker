FROM docker:25-git
WORKDIR /app
COPY --chmod=0755 builder.sh .
ENTRYPOINT [ "./builder.sh" ]