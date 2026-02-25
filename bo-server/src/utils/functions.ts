export function convertKeysToUpperCase(obj: any): any {
  if (Array.isArray(obj)) {
    return obj.map((item) => convertKeysToUpperCase(item));
  } else if (typeof obj === 'object' && obj !== null) {
    const upperCaseObj = {};
    for (const key in obj) {
      if (obj.hasOwnProperty(key)) {
        upperCaseObj[key.toUpperCase()] = convertKeysToUpperCase(obj[key]);
      }
    }
    return upperCaseObj;
  }
  return obj;
}
