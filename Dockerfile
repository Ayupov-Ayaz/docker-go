FROM golang:alpine as builder

# Install SSL ca certificates
RUN apk update && apk add git && apk add ca-certificates

# create new user
RUN adduser -D -g '' tommy

WORKDIR /app
COPY . .
RUN go get -d -v

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /app/my-app

FROM scratch
ENV GO111MODULE=on
WORKDIR /app
# copy ssl certificates
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# copy out user
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /app/my-app .
USER tommy
EXPOSE 8080
ENTRYPOINT ["./my-app"]