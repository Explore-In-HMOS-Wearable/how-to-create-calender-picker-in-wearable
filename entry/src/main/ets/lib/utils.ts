import dayjs from 'dayjs';
import { MonthDay } from './types';

export function formatTime(timestamp: number): string {
  return dayjs(timestamp).format('HH:mm');
}

export function formatDay(timestamp: number): string {
  return dayjs(timestamp).format('MMM DD')
}

export function getMonth(timestamp: number): string {
  return dayjs(timestamp).format('MMM')
}

export function getYear(timestamp: number): string {
  return dayjs(timestamp).format('YYYY')
}

export function formatDayAsKey(timestamp: number): string {
  return dayjs(timestamp).format('YYYYMMDD')
}

export function getPreviousDate(timestamp: number): Date {
  return dayjs(timestamp).subtract(1, 'M').toDate();
}

export function getNextDate(timestamp: number): Date {
  return dayjs(timestamp).add(1, 'M').toDate();
}

export function formatDate(timestamp: number): string {
  return dayjs(timestamp).format('DD.MM.YYYY');
}

export function formatOnlyDay(timestamp: number): string {
  return dayjs(timestamp).format('dddd');
}