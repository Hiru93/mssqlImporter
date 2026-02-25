import { Inject, Injectable } from '@nestjs/common';
import { Knex } from 'knex';
import {
  agendaQuery,
  dentistiQuery,
  FATTURE_DETTAGLI_QUERY,
  fattureQuery,
  fornitoriQuery,
  LAVORI_DETTAGLI_QUERY,
  lavoriQuery,
  magazzinoQuery,
  pazientiQuery,
  PREVENTIVI_DETTAGLI_QUERY,
  preventiviQuery,
  richiamiQuery,
  tableStructureQuery,
} from './utils/constants';
import { TableListObject } from './utils/types';

interface DbQueryStructure {
  current: Array<object>;
  storico?: Array<any>;
  currentTableStructure: Array<string>;
  storicoTableStructure?: Array<string>;
}

@Injectable()
export class AppService {
  constructor(
    @Inject('DbDent') private DbDent: Knex,
    @Inject('DbStorico') private DbStorico: Knex,
    @Inject('DbEsercizio') private DbEsercizio: Knex,
  ) {}

  private fetchQuery(tableName: string, storico: boolean = false) {
    switch (tableName) {
      case 'Agenda':
        return agendaQuery(storico);
      case 'Pazienti':
        return pazientiQuery(storico);
      case 'Dentisti':
        return dentistiQuery(storico);
      case 'Fornitori':
        return fornitoriQuery(storico);
      case 'Magazzino':
        return magazzinoQuery(storico);
      case 'Lavori':
        return lavoriQuery(storico);
      case 'LavoriDettagli':
        return LAVORI_DETTAGLI_QUERY;
      case 'Preventivi':
        return preventiviQuery();
      case 'PreventiviDettagli':
        return PREVENTIVI_DETTAGLI_QUERY;
      case 'Fatture':
        return fattureQuery();
      case 'FattureDettagli':
        return FATTURE_DETTAGLI_QUERY;
      case 'Richiami':
        return storico ? richiamiQuery(storico) : richiamiQuery();
      default:
        return '';
    }
  }

  async getData(table: TableListObject): Promise<DbQueryStructure> {
    console.log('-------------------------------------------------');
    const { tableName, hasStorico, targetDb, targetStorico } = table;
    console.log('tableName: ', tableName);
    const dbConnector = this[targetDb];
    const storicoConnector = hasStorico ? this[targetStorico] : null;

    if (hasStorico) {
      const data = {
        current: null,
        storico: null,
        currentTableStructure: null,
        storicoTableStructure: null,
      };

      const promises = [
        dbConnector.raw(this.fetchQuery(tableName)),
        storicoConnector.raw(this.fetchQuery(tableName, hasStorico)),
        dbConnector.raw(tableStructureQuery(tableName)),
        storicoConnector.raw(tableStructureQuery(tableName)),
      ];

      return Promise.all(promises).then(
        ([current, storico, currentTableStructure, storicoTableStructure]) => {
          data.current = current;
          data.storico = storico;
          data.currentTableStructure = currentTableStructure;
          data.storicoTableStructure = storicoTableStructure;
          console.log('================== DATA ==================');
          console.log('current: ', data.current);
          console.log('storico: ', data.storico);
          console.log('currentTableStructure: ', data.currentTableStructure);
          console.log('storicoTableStructure: ', data.storicoTableStructure);
          console.log('==========================================');

          // Parsing data to convert dates into strings
          data.current.forEach((row: any) => {
            Object.keys(row).forEach((key: string) => {
              if (row[key] instanceof Date) {
                row[key] = row[key].toISOString();
              }
            });
          });

          data.storico.forEach((row: any) => {
            Object.keys(row).forEach((key: string) => {
              if (row[key] instanceof Date) {
                row[key] = row[key].toISOString();
              }
            });
          });

          return data;
        },
      );
    } else {
      const data = {
        current: null,
        currentTableStructure: null,
      };

      const promises = [
        dbConnector.raw(this.fetchQuery(tableName)),
        dbConnector.raw(tableStructureQuery(tableName)),
      ];

      return Promise.all(promises).then(([current, currentTableStructure]) => {
        data.current = current;
        data.currentTableStructure = currentTableStructure;
        console.log('================== DATA ==================');
        console.log('current: ', data.current);
        console.log('currentTableStructure: ', data.currentTableStructure);
        console.log('==========================================');

        // Parsing data to convert dates into strings
        data.current.forEach((row: any) => {
          Object.keys(row).forEach((key: string) => {
            if (row[key] instanceof Date) {
              row[key] = row[key].toISOString();
            }
          });
        });

        return data;
      });
    }
  }
}
