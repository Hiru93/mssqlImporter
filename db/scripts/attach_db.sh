sleep 15s
DENT=${1:-"DbDent"}
STORICO=${2:-"DbStorico"}
ESERCIZIO=${3:-"DbEsercizio"}

# UPDATE 11/12/2024
# As of today, looks like Docker changed the name of the mssql directory needed to run sqlcmd in 'mssql-tools18' instead of 'mssql-tools'.
# On top of that, now the flag -C is needed to trust the certificate.

# Due to the mutating nature of the Docker image, we need to find the correct directory where the mssql-tools are located.
MSSQLTOOLSDIR=$(find /opt -type d -name 'mssql-tools18' || find /opt -type d -name 'mssql-tools')

echo "+++++++++++++++++++++++ IMPORTING $DENT +++++++++++++++++++++++"
$MSSQLTOOLSDIR/bin/sqlcmd -C -S . -U sa -P StrongPassword123% \
-Q "CREATE DATABASE [${1}] ON (FILENAME ='/DBimport/${1}.mdf'),(FILENAME = '/DBimport/${1}.ldf') FOR ATTACH"

echo "+++++++++++++++++++++++ IMPORTING $STORICO +++++++++++++++++++++++"
$MSSQLTOOLSDIR/bin/sqlcmd -C -S . -U sa -P StrongPassword123% \
-Q "CREATE DATABASE [${2}] ON (FILENAME ='/DBimport/${2}.mdf'),(FILENAME = '/DBimport/${2}.ldf') FOR ATTACH"

echo "+++++++++++++++++++++++ IMPORTING $ESERCIZIO +++++++++++++++++++++++"
$MSSQLTOOLSDIR/bin/sqlcmd -C -S . -U sa -P StrongPassword123% \
-Q "CREATE DATABASE [${3}] ON (FILENAME ='/DBimport/${3}.mdf'),(FILENAME = '/DBimport/${3}.ldf') FOR ATTACH"

echo "+++++++++++++++++++++++ IMPORTING SUCCESS +++++++++++++++++++++++"
echo "+++++++++++++++++++++++ DB READY TO EXPORT DATA +++++++++++++++++++++++"

