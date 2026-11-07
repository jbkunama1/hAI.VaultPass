<div align="center">

# hAI.VaultPass

### Dein Tresor. Dein Server. Deine Kontrolle.

[![Build](https://img.shields.io/github/actions/workflow/status/jbkunama1/hAI.VaultPass/build.yml?branch=main&style=for-the-badge&label=GHCR%20Build)](https://github.com/jbkunama1/hAI.VaultPass/actions/workflows/build.yml)
![Portainer](https://img.shields.io/badge/Portainer-ready-13BEF9?style=for-the-badge)
![Network](https://img.shields.io/badge/Network-highfishNetwork-50f2c2?style=for-the-badge)

</div>

## Konzept

Selfhosting-Paket fuer [Vaultwarden](https://github.com/dani-garcia/vaultwarden): schlankes Deployment-Image, GitHub Actions, GHCR, persistenter Portainer-Stack und statische Projektseite. Vaultwarden ist ein unabhaengiges Community-Projekt und kein offizieller Bitwarden-Server. Offizielle Bitwarden-Clients lassen sich mit der eigenen Server-URL verbinden. Keine eigene Kryptografie, kein veraenderter Login und kein KI-Zugriff auf Passwoerter.

## Dateien

| Datei | Aufgabe |
| --- | --- |
| Dockerfile | Duennes Wrapper-Image auf vaultwarden/server:latest; kein Quellcode-Neubau |
| .github/workflows/build.yml | Build und Push nach GHCR |
| portainer-stack.yml | Portainer-Deployment ohne lokalen Build |
| .env.example | Beispielwerte fuer Portainer |
| docs/index.html | Statische Projektseite fuer GitHub Pages |

## Portainer-Schnellstart

1. Erfolgreichen Actions-Build abwarten. Der Commit allein bestaetigt keinen erfolgreichen Build.
2. GHCR-Package auf Public setzen oder in Portainer GHCR-Zugang mit read:packages hinterlegen. Ein oeffentliches Repo bedeutet nicht automatisch ein oeffentliches Package.
3. Vorhandenes externes Docker-Netzwerk highfishNetwork sicherstellen.
4. Stack aus Repository https://github.com/jbkunama1/hAI.VaultPass anlegen: Referenz refs/heads/main, Compose-Pfad portainer-stack.yml.
5. VAULTPASS_DOMAIN auf die vollstaendige HTTPS-Adresse setzen, z.B. https://vault.example.com. Keine echten Secrets in GitHub hinterlegen.
6. Bestehenden Reverse Proxy an highfishNetwork anschliessen und fuer die gewaehlte Domain auf http://hai-vaultpass:80 weiterleiten. WebSocket-Upgrades unterstuetzen; HTTPS mit gueltigem Zertifikat bereitstellen. Der Stack veroeffentlicht absichtlich keinen Host-Port. Ein ausserhalb dieses Docker-Netzwerks laufender Proxy erreicht diesen Namen nicht direkt.
7. Stack deployen und die HTTPS-Adresse oeffnen. Der Web-Tresor benoetigt HTTPS fuer die Web-Crypto-API; blosses HTTP ueber eine LAN-IP reicht nicht.

### Erstes Konto

Standardmaessig sind Registrierungen und Einladungen deaktiviert. Fuer das erste Konto: Zugang zunaechst am Proxy auf dein vertrauenswuerdiges Geraet beschraenken, SIGNUPS_ALLOWED=true setzen und neu deployen. Konto anlegen, danach sofort SIGNUPS_ALLOWED=false setzen und erneut deployen. Ohne Zugriffsbeschraenkung koennten waehrenddessen andere Personen Konten registrieren.

ADMIN_TOKEN ist optional und leer bedeutet: Admin-Oberflaeche deaktiviert. Fuer die Administration lokal mit dem Upstream-Befehl docker run --rm -it vaultwarden/server:latest /vaultwarden hash einen Argon2-Hash erzeugen und als Portainer-Umgebungsvariable ADMIN_TOKEN eintragen. Das zugehoerige Passwort sicher verwahren. Bei direkter Eintragung eines Hashs in Compose muessen Dollarzeichen als $$ maskiert werden; bei Portainer-Variablen den unveraenderten Wert verwenden. /admin nur eingeschraenkt erreichbar machen. Einstellungen aus der Admin-Oberflaeche werden in /data/config.json gespeichert und koennen Umgebungsvariablen uebersteuern.

## Konfiguration

| Variable | Standard | Zweck |
| --- | --- | --- |
| VAULTPASS_DOMAIN | Pflicht | Externe HTTPS-Basisadresse |
| IMAGE_TAG | latest | Alternativ run-ID-Tag fuer gezielte Version |
| TZ | Europe/Berlin | Zeitzone |
| SIGNUPS_ALLOWED | false | Nur kurzzeitig zur kontrollierten Ersteinrichtung true |
| INVITATIONS_ALLOWED | false | Einladungen |
| ADMIN_TOKEN | leer | Admin deaktiviert; optional Argon2-Hash |
| SHOW_PASSWORD_HINT | false | Keine Passwort-Hinweise anzeigen |

Volume: hai-vaultpass-data, im Container /data. Netzwerk: highfishNetwork. SMTP ist in diesem Minimalstack nicht konfiguriert; nicht auf E-Mail-Zustellung oder E-Mail-Wiederherstellung verlassen. Master-Passwort und 2FA-Wiederherstellungscode offline sicher verwahren.

## Google und NordPass importieren

1. Google/Chrome: Passwortmanager-Einstellungen oeffnen, Passwoerter als CSV exportieren.
2. NordPass: Daten ueber die Exportfunktion als CSV exportieren.
3. Im selbst gehosteten Web-Tresor Werkzeuge / Daten importieren oeffnen. Je Datei das passende Format waehlen: Chrome (csv) bzw. NordPass (csv).
4. Beide Quellen getrennt importieren und wichtige Eintraege stichprobenartig testen. Wiederholte Importe koennen Duplikate erzeugen; es handelt sich nicht um eine laufende Synchronisation.
5. CSV-Dateien enthalten Klartext-Geheimnisse: nicht hochladen, nicht committen und nicht in synchronisierten Cloudordnern liegen lassen. Nach erfolgreicher Pruefung entfernen; eventuell vorhandene Kopien und Backups beachten.

Anleitungen: [Chrome](https://bitwarden.com/help/import-from-chrome/), [Import](https://bitwarden.com/help/import-data/). CSV-Passwortimport ist kein allgemeiner Passkey- oder Anhangtransfer. Originaldaten erst nach erfolgreicher Pruefung aufgeben.

## Apps

Bitwarden-App oder Browser-Erweiterung installieren und vor der Anmeldung unter selbst gehostetem Server die VAULTPASS_DOMAIN eintragen. Nicht versehentlich einen separaten Cloud-Tresor anlegen. Danach Autofill und Synchronisation auf jedem Geraet testen. 2FA fuer den Tresor aktivieren und Wiederherstellungscode getrennt aufbewahren.

## Build und Updates

Image: ghcr.io/jbkunama1/hai.vaultpass:latest

GitHub Actions baut bei Dockerfile-/Workflow-Aenderungen, manuell und taeglich um 03:41 UTC fuer linux/amd64. Jeder Lauf zieht den aktuellen Upstream-Tag vaultwarden/server:latest und veroeffentlicht latest sowie run-RUN_ID-RUN_ATTEMPT. Das ist ein Wrapper-Build, kein eigener Vaultwarden-Quellcode-Build und kein Release-SHA-Vergleich. Taegliche Laeufe bauen auch ohne Upstream-Aenderung; GitHub kann Zeitplaene verzoegern oder deaktivieren. GITHUB_TOKEN mit packages:write genuegt fuer den Push. Der Upstream-Tag ist beweglich, der Build daher nicht vollstaendig reproduzierbar. Fuer kontrollierte Deployments den eindeutigen run-Tag statt latest verwenden.

Kein automatischer Redeploy auf deinem Server. Vor Updates Backup erstellen, Upstream-Release-Hinweise lesen und erst dann in Portainer neu pullen und bereitstellen. Ein Image-Rollback allein kann nach Datenbankmigrationen unzureichend sein: passende Datensicherung benoetigen. Build-/Laufzeitbetrieb sind erst nach tatsaechlicher Pruefung bestaetigt.

## Backup und Wiederherstellung

Stack stoppen, damit SQLite und die zugehoerigen Dateien konsistent gesichert werden. Auf dem Docker-Host:

```bash
mkdir -p backups
chmod 700 backups
docker run --rm -v hai-vaultpass-data:/data:ro -v "$PWD/backups:/backup" alpine:3.20 tar czf /backup/vaultpass-data.tar.gz -C /data .
chmod 600 backups/vaultpass-data.tar.gz
```

Anschliessend Stack starten. Gesamtes Volume sichern, nicht nur die Datenbank: dazu gehoeren u.a. Anhaenge, Konfiguration und Schluessel. Sicherungen verschluesselt, getrennt vom Host und zugriffsgeschuetzt lagern.

Restore nur bei gestopptem Stack: gesicherten Inhalt in ein leeres Zielvolume hai-vaultpass-data zurueckspielen und mit passender Image-Version starten. Vorher vorhandenes Volume separat sichern; nicht blind ueberschreiben. Wiederherstellung regelmaessig in isolierter Testumgebung pruefen. Volume beim Entfernen des Stacks nicht loeschen.

## Sicherheit und Troubleshooting

- highfishNetwork ist ein gemeinsames Netzwerk, keine Isolation zwischen seinen Containern. Nur vertrauenswuerdige Dienste anschliessen.
- Keine Docker-Socket-Mounts und kein privileged-Modus. Reverse Proxy, Host und Vaultwarden aktuell halten.
- /admin am Proxy gesondert einschraenken; keine oeffentliche Dokumentationsseite mit Passwortdateien mischen.
- Unhealthy: Logs und Upstream-Healthcheck pruefen. restart: unless-stopped startet einen nur ungesunden Container nicht automatisch neu.
- Image nicht gefunden: Buildstatus, Package-Sichtbarkeit und Registry-Login pruefen.
- Netzwerk fehlt: highfishNetwork auf dem gewaehlten Docker-Host anlegen.
- Web-Tresor laedt nicht: Zertifikat, HTTPS, DOMAIN, Proxy und WebSocket-Konfiguration pruefen.
- Registrierung blockiert: kontrollierten Bootstrap oben verwenden; anschliessend wieder sperren.

## Projektseite

In GitHub Settings / Pages: Deploy from a branch, main, /docs waehlen. Vorgesehene Adresse nach Aktivierung: https://jbkunama1.github.io/hAI.VaultPass/. Die Datei allein aktiviert Pages nicht. Die Seite ist Dokumentation, kein Tresor und keine Passwort-Uploadseite.

## Upstream und Lizenz

Vaultwarden: https://github.com/dani-garcia/vaultwarden (AGPL-3.0). Dessen Lizenz-, Quellcode- und Weitergabeanforderungen gelten fuer die enthaltene Software; dieses Repository beansprucht keine Urheberschaft daran. Das Wrapper-Image veraendert die Anwendung nicht. Fuer Fehler am Community-Server die Vaultwarden-Kanaele verwenden, nicht den offiziellen Bitwarden-Support.
