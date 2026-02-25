FROM mcr.microsoft.com/mssql/server:2019-latest
# FROM --platform=linux/amd64 mcr.microsoft.com/mssql/server:2019-latest
ARG dent=DbDent
ARG storico=DbStorico
ARG esercizio=DbEsercizio
ENV ACCEPT_EULA=Y
ENV DENT=$dent
ENV STORICO=$storico
ENV ESERCIZIO=$esercizio
EXPOSE 1433

WORKDIR /src

# Switch to root user
USER root
COPY --chown=1001 ./db/scripts/attach_db.sh /DBimport/
COPY --chown=1001 ./db/scripts/wrapper_script.sh /DBimport/
# Elencare di seguito i file .mdf e .ldf che si vuole caricare per inizializzare il db
# UPDATE - added wildcard on copy command to find both .ldf and .log files
# --------------- DENT ---------------
COPY --chown=1001 ./db/dumps/$dent.* /DBimport/

# --------------- STORICO ---------------
COPY --chown=1001 ./db/dumps/$storico.* /DBimport/

# --------------- ESERCIZIO ---------------
COPY --chown=1001 ./db/dumps/$esercizio.* /DBimport/

RUN chmod +x /DBimport/attach_db.sh
RUN chmod +x /DBimport/wrapper_script.sh

# Switch back to non-root user
USER 1001
RUN (/opt/mssql/bin/sqlservr --accept-eula & ) | grep -q "Service Broker manager has started"

ENTRYPOINT /DBimport/wrapper_script.sh
