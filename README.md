# Generate Root CA
```openssl req -config openssl.conf -newkey rsa:2048 -x509 -keyout "private/ca.key" -out "certs/ca.crt" -nodes -subj "/C=AU/ST=NSW/L=Sydney/O=Test/CN=Root CA" -extensions v3_ca -days 3650```

# Generate Intermediate CA Request
```openssl req -config openssl.conf -newkey rsa:2048 -keyout "private/intermediate.key" -out "csr/intermediate.csr" -nodes -subj "/C=AU/ST=NSW/L=Sydney/O=Test/CN=Intermediate CA" -extensions v3_intermediate_ca```

# Issue Intermediate CA Certificate
```openssl x509 -req -CA "certs/ca.crt" -CAkey "private/ca.key" -in "csr/intermediate.csr" -out "certs/intermediate.crt" -set_serial $(openssl rand 10 | od -DAn | tr -d ' ' | tr -d '\n') -extfile openssl.conf -extensions v3_intermediate_ca -days 365```

# Generate Server Request
```openssl req -newkey rsa:2048 -keyout "private/server.key" -out "csr/server.csr" -nodes -subj "/C=AU/ST=NSW/L=Sydney/O=Test/CN=localhost"```
 
# Sign with Intermediate CA certificate
```openssl x509 -req -CA "certs/intermediate.crt" -CAkey "private/intermediate.key" -in "csr/server.csr" -out "certs/server.crt" -set_serial $(openssl rand 10 | od -DAn | tr -d ' ' | tr -d '\n') -extfile openssl.conf -extensions server_cert -days 30```

# Generate Client Request
```openssl req -newkey rsa:2048 -keyout "private/client.key" -out "csr/client.csr" -nodes -subj "/C=AU/ST=NSW/L=Sydney/O=Test/CN=client"```

# Sign with Intermediate CA certificate
```openssl x509 -req -CA "certs/intermediate.crt" -CAkey "private/intermediate.key" -in "csr/client.csr" -out "certs/client.crt" -set_serial $(openssl rand 10 | od -DAn | tr -d ' ' | tr -d '\n') -extfile openssl.conf -extensions usr_cert -days 30```
