import { Controller, Get } from '@nestjs/common';
import * as Excel from 'exceljs';
import * as path from 'path';
import { AppService } from './app.service';
import { tableList } from './utils/constants';
import { convertKeysToUpperCase } from './utils/functions';

const fileCreation = async (fileList: Array<object>): Promise<any> => {
  fileList.forEach((file: any) => {
    const isStorico = file.tableName.includes('_storico');

    const workbook = new Excel.Workbook();
    const worksheet = workbook.addWorksheet('My Sheet');

    const headers = isStorico
      ? (file.data.storicoTableStructure || []).map((column: any) => {
          return column['COL_NAME'].toUpperCase();
        })
      : (file.data.currentTableStructure || []).map((column: any) => {
          return column['COL_NAME'].toUpperCase();
        });

    const records = isStorico
      ? (file.data.storico || []).map((row: any) => {
          const record: Array<any> = [];
          (file.data.storicoTableStructure || []).forEach((column: any) => {
            record.push(row[column['COL_NAME'].toUpperCase()]);
          });
          return record;
        })
      : (file.data.current || []).map((row: any) => {
          const record: Array<any> = [];
          (file.data.currentTableStructure || []).forEach((column: any) => {
            record.push(row[column['COL_NAME'].toUpperCase()]);
          });
          return record;
        });

    worksheet.addRows(records);

    worksheet.columns = headers.map((header) => ({ header, key: header }));

    // Write to file
    workbook.csv
      .writeFile(path.resolve('./exports/', file.tableName + '.csv'), {
        formatterOptions: {
          delimiter: ';',
          quote: true,
        },
      })
      .then(() => {
        console.log('..........writing ', file.tableName);
        console.log('...Done');
      })
      .catch((err) => {
        console.log('..........err writing ', file.tableName);
        console.log('err: ', err);
        return JSON.stringify('Error :(', null, 2);
      });
  });
};

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get('/db-dump')
  async getDbDump(): Promise<any> {
    const filesToCreate: Array<object> = [];

    for (const table of tableList) {
      if (table.hasStorico) {
        const {
          current,
          storico,
          currentTableStructure,
          storicoTableStructure,
        } = await this.appService.getData(table);
        filesToCreate.push({
          data: {
            current: convertKeysToUpperCase(current),
            currentTableStructure: convertKeysToUpperCase(
              currentTableStructure,
            ),
          },
          tableName: table.tableName,
        });

        filesToCreate.push({
          data: {
            storico: convertKeysToUpperCase(storico),
            storicoTableStructure: convertKeysToUpperCase(
              storicoTableStructure,
            ),
          },
          tableName: table.tableName + '_storico',
        });
      } else {
        const { current, currentTableStructure } =
          await this.appService.getData(table);
        filesToCreate.push({
          data: {
            current: convertKeysToUpperCase(current),
            currentTableStructure: convertKeysToUpperCase(
              currentTableStructure,
            ),
          },
          tableName: table.tableName,
        });
      }
    }

    await fileCreation(filesToCreate);
    return JSON.stringify('Completed :D', null, 2);
  }
}
