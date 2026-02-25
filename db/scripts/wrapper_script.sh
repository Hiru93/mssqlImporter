#!/bin/bash
dent=$DENT
storico=$STORICO
esercizio=$ESERCIZIO
# Run the attach_db script
/DBimport/attach_db.sh $dent $storico $esercizio &
# Then start sqlservr
/opt/mssql/bin/sqlservr