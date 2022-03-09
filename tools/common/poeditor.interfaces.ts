export interface Language {
  name: string;
  code: string;
  translations: number;
  percentage: number;
  updated: string;
}

export interface TranslationRecord {
  term: string;
  definition: string | null;
  context: string;
  term_plural: string;
  reference: string;
  comment: string;
}
