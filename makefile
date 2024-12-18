prepare:
	openssl rand -hex 32 > authelia/secrets/jwt_secret.txt
	openssl rand -hex 32 > authelia/secrets/session_secret.txt
	openssl rand -hex 32 > authelia/secrets/storage_encryption_key.txt
	echo $$smtp_password > authelia/secrets/smtp_password.txt # smtp_password is an environment variable

up:
	docker-compose up -d

clean:
	docker-compose down

all: prepare up