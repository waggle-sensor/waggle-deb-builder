FROM buildpack-deps:18.04
COPY entrypoint.sh /entrypoint.sh
RUN git config --global --add safe.directory /repo
ENTRYPOINT [ "/entrypoint.sh" ]
