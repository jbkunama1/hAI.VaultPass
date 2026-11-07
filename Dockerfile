ARG VAULTWARDEN_IMAGE=vaultwarden/server:latest
FROM ${VAULTWARDEN_IMAGE}
LABEL org.opencontainers.image.title="hAI.VaultPass" \
      org.opencontainers.image.description="Vaultwarden deployment image for highfishAI" \
      org.opencontainers.image.source="https://github.com/jbkunama1/hAI.VaultPass"
