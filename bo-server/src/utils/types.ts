export interface DbConfig {
  client: string;
  version: string;
  useNullAsDefault: boolean;
  connection?: ConnectionConfig | undefined;
}

export interface ConnectionConfig {
  host: string;
  user: string;
  password: string;
  database?: string;
  timezone?: string;
  dateStrings?: boolean;
  typeCast: (field: any, next: any) => string;
}

export interface TableListObject {
  tableName: string;
  hasStorico: boolean;
  targetDb: string;
  targetStorico?: string;
}
