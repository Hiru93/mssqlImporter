# MSSQL Db importer

## About

During one of my professional collaborations, the need arose to migrate data from several legacy Microsoft SQL Server installations. The only available environment capable of opening the database dumps was a single desktop machine running Windows with multiple SQL Server versions installed — an impractical and fragile setup for repeated exports.

To address this, I developed a containerized solution that provisions a Microsoft SQL Server instance, automatically restores the provided database dumps, and exports the data as a structured set of CSV files. This approach eliminates the dependency on dedicated legacy hardware and makes the data extraction process reproducible and portable.

#### Prerequisites
The importer, in order to work, needs a set of files which will be read during the bootstrap-scripts execution.

Those should be files provided as couples of ".mdf" and "ldf" files, both of which needs to be named the same; those couples of files should be also named as follows:

- "DbDent.mdf" & "DbDent.ldf"
- "DbStorico.mdf" & "DbStorico.ldf"
- "DbEsercizio.mdf" & "DbEsercizio.ldf"

The wrong use of the above naming standard will result in a failed launch of the project and will not be possible to perform any data export.

Each couple of files needs to be placed inside the directory "/db/dumps/", which is where the docker container looks for the files to attach the db to.

It is also required to create a `.env` file in the root directory of the project containing the following variables:

```
DB_PASSWORD=
MSSQL_PORT=
DB_HOST=
SERVER_PORT=
DECRYPT_PASSPHRASE=
```

These variables are crucial for the correct execution of the containers. See the [Environment Variables](#environment-variables) section below for a description of each.

---

#### FOR LOCAL DEVELOPMENT ONLY

Create a `.env` file inside `bo-server/` containing:

```
DECRYPT_PASSPHRASE=
```

See the [Environment Variables](#environment-variables) section for details on this value.

---

#### Environment Variables

| Variable | Description |
|---|---|
| `DB_PASSWORD` | The SA (system administrator) password for the SQL Server instance. |
| `MSSQL_PORT` | The port on which SQL Server listens (default: `1433`). |
| `DB_HOST` | The hostname of the SQL Server container, as seen from the backend service (e.g. `importer_db`). |
| `SERVER_PORT` | The port exposed by the NestJS backend service. |
| `DECRYPT_PASSPHRASE` | **Required.** The passphrase used by SQL Server's `DECRYPTBYPASSPHRASE()` function to decrypt sensitive encrypted columns (e.g. patient names, fiscal codes) stored in the source databases. This value must match exactly the passphrase that was used when the data was originally encrypted — providing a wrong or missing value will result in `NULL` being returned for all encrypted fields. |

---
#### How to start the exporter

To execute the exporter, just launch the script "export.sh" from the root directory with the following command
```
./export.sh
```

---
#### How to start and stop the project (docker-compose version)

Launch the project using the following command
```
docker-compose up -d db bo
```

To stop the project, use the following command
```
docker-compose down --rmi local
```

# .CSV Parser

#### Prerequisites
The parser, in order to work, needs a set of files which will be read during the execution of the parsing script.

Those files should be provided in the form of a .zip archive and it needs to be placed inside the directory "archives", which can be found at the path
```
/csv-parser/archives
```

The Misplacing of the archive file will result in a wrong execution of the parsing script and in a subsequent error thrown by it.

---
#### How to start the .csv parser

To execute the parser, just launch the script "parse.sh" from the root directory with the following command
```
./parse.sh
```

#### How to start and stop the project (docker-compose version)

Launch the project using the following command
```
docker-compose up -d csv-parser
```

To stop the project, use the following command
```
docker-compose down --rmi local
```