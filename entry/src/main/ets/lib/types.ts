export interface MonthDay {
  day: string;
  index: number;
  isNotCurrent: boolean;
  dayIndex: 0 | 1 | 2 | 3 | 4 | 5 | 6;
  date: Date;
  hasEvents: boolean;
}