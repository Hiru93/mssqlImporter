import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { KnexModule } from 'nest-knexjs';
import { dbList, dbConfig, connectionConfig } from './utils/constants';
import { ConfigModule } from '@nestjs/config';

const dbConnectionList: Array<any> = dbList.map((dbName: string) => {
  return KnexModule.forRoot(
    {
      config: {
        ...dbConfig,
        connection: {
          ...connectionConfig,
          database: dbName,
        },
      },
    },
    dbName,
  );
});

@Module({
  imports: [...dbConnectionList, ConfigModule.forRoot()],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
