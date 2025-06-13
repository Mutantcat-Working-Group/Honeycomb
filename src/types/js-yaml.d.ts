declare module 'js-yaml' {
  export function load(input: string, options?: any): any;
  export function dump(input: any, options?: any): string;
} 