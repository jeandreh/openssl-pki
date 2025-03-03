all: pki

pki: root intermediate client-john@test.com

.PHONY: root
root:
	openssl req -config root/openssl.conf -newkey rsa:2048 -x509 -keyout "root/private/ca.key" -out "root/certs/ca.crt" -nodes -subj "/C=AU/ST=NSW/L=Sydney/O=Test/CN=Root CA" -extensions v3_ca -days 3650

.PHONY: intermediate
intermediate:
	openssl req -config intermediate/openssl.conf -newkey rsa:2048 -keyout "intermediate/private/ca.key" -out "intermediate/csr/ca.csr" -nodes -subj "/C=AU/ST=NSW/L=Sydney/O=Test/CN=Intermediate CA" -extensions v3_intermediate_ca
	openssl x509 -req -CA "root/certs/ca.crt" -CAkey "root/private/ca.key" -in "intermediate/csr/ca.csr" -out "intermediate/certs/ca.crt" -set_serial $$(openssl rand 10 | od -DAn | tr -d ' ' | tr -d '\n') -extfile root/openssl.conf -extensions v3_intermediate_ca -days 365

server-%:
	openssl req -newkey rsa:2048 -keyout "intermediate/private/server-$*.key" -out "intermediate/csr/server-$*.csr" -nodes -subj "/C=AU/ST=NSW/L=Sydney/O=Test/CN=$*" -addext "subjectAltName = DNS:$*, DNS:localhost"
	openssl x509 -req -CA "intermediate/certs/ca.crt" -CAkey "intermediate/private/ca.key" -in "intermediate/csr/server-$*.csr" -out "intermediate/certs/server-$*.crt" -set_serial $$(openssl rand 10 | od -DAn | tr -d ' ' | tr -d '\n') -extfile intermediate/openssl.conf -extensions server_cert -copy_extensions copy -days 180

client-%:
	openssl req -newkey rsa:2048 -keyout "intermediate/private/client-$*.key" -out "intermediate/csr/client-$*.csr" -nodes -subj "/C=AU/ST=NSW/L=Sydney/O=Test/CN=$*" -addext "subjectAltName = email:$*, DNS:MYDEVICEID"
	openssl x509 -req -CA "intermediate/certs/ca.crt" -CAkey "intermediate/private/ca.key" -in "intermediate/csr/client-$*.csr" -out "intermediate/certs/client-$*.crt" -set_serial $$(openssl rand 10 | od -DAn | tr -d ' ' | tr -d '\n') -extfile intermediate/openssl.conf -extensions client_cert -copy_extensions copy -days 180

clean:
	rm -f root/private/*.key root/certs/*.crt
	rm -f intermediate/private/*.key intermediate/csr/*.csr intermediate/certs/*.crt
