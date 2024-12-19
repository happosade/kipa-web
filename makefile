SHELL := /bin/bash

.PHONY: prepare up clean all passwords

prepare:
	openssl rand -hex 32 > config/authelia/secrets/jwt_secret.txt
	openssl rand -hex 32 > config/authelia/secrets/session_secret.txt
	openssl rand -hex 32 > config/authelia/secrets/storage_encryption_key.txt
	echo $$smtp_password > config/authelia/secrets/smtp_password.txt # smtp_password is an environment variable

up:
	docker compose up -d

clean:
	docker compose down

passwords:
	@echo "users:" > users.yml
	@for user in $$(yq -r '.users[] | select(.clear_password != null) | .name' users_example.yml); do \
		password=$$(yq -r ".users[] | select(.name == \"$$user\") | .clear_password" users_example.yml); \
		hash=$$(docker compose run --rm authelia authelia crypto hash generate argon2 --password "$$password" | grep Digest: | awk '{print $$2}'); \
		email=$$(yq -r ".users[] | select(.name == \"$$user\") | .email" users_example.yml); \
		echo "  $$user:" >> users.yml; \
		echo "    displayname: $$user" >> users.yml; \
		echo "    password: $$hash" >> users.yml; \
		echo "    email: $$email" >> users.yml; \
		echo "    groups: []" >> users.yml; \
	done

init: prepare passwords
	@echo "Please copy the output of the 'print-authelia-users' target and paste it into the 'users.yml' file."
	@echo "Then run 'make up' to start"