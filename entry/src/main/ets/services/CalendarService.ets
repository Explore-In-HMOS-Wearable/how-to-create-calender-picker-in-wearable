import { calendarManager } from '@kit.CalendarKit';
import dayjs from 'dayjs';
import { MonthDay } from '../lib/types';
import { formatDayAsKey } from '../lib/utils';
import GlobalContext from '../models/GlobalContext';
import EventService from './EventService';

export default class CalendarService {
  private static instance: CalendarService;
  private calendarManager: calendarManager.CalendarManager | null = null;
  private eventService: EventService = EventService.getInstance();

  constructor(calendarManager: calendarManager.CalendarManager) {
    this.calendarManager = calendarManager;
  }

  static getInstance(): CalendarService {
    if (!CalendarService.instance) {
      const context = GlobalContext.getInstance().getAppContext();
      let manager = calendarManager.getCalendarManager(context);
      CalendarService.instance = new CalendarService(manager);
    }

    return CalendarService.instance;
  }

  async getCalendar(): Promise<calendarManager.Calendar | undefined> {
    try {
      return await this.calendarManager?.getCalendar();
    } catch (err) {
      console.error(`Failed to get calendar. Code: ${err.code}, message: ${err.message}`);
    }
    return undefined;
  }

  async getDefaultCalendarEvents(): Promise<calendarManager.Event[]> {
    let calendar = await this.getCalendar();
    if (calendar) {
      return await this.eventService.getAllEventsByCalendar(calendar);
    }
    return [];
  }

  async isEventExistsByDate(date: Date): Promise<boolean> {
    const dateFormatted = formatDayAsKey(date.getTime());
    const calendar = await this.getCalendar();
    if (calendar) {
      const events = await this.eventService.getAllEventsByCalendar(calendar);
      if (events) {
        const filteredEvents = events.filter(event => {
          const formatted = formatDayAsKey(event.startTime);
          return dateFormatted === formatted;
        })
        return filteredEvents.length > 0;
      }
    }

    return false;
  }

  async getDaysInMonth(date: Date = new Date, isNotCurrent: boolean = false): Promise<MonthDay[]> {
    let days: MonthDay[] = [];
    const dayjsDate = dayjs(date);
    const daysInMonth = dayjsDate.daysInMonth();

    for (let index = 1; index <= daysInMonth; index++) {
      date.setDate(index);
      const hasEvents = await this.isEventExistsByDate(date);
      days.push({
        day: dayjs(date).format('DD'),
        index,
        dayIndex: dayjs(date).day(),
        isNotCurrent,
        date: dayjs(date).toDate(),
        hasEvents,
      })
    }

    return days;

  }

  async addEvent(): Promise<number | undefined> {
    try {
      let date = new Date();
      let event: calendarManager.Event = {
        title: 'Event',
        type: calendarManager.EventType.NORMAL,
        startTime: date.getTime(),
        endTime: date.getTime() + 60 * 60 * 1000,
        reminderTime: [10],
        recurrenceRule: {
          recurrenceFrequency: calendarManager.RecurrenceFrequency.DAILY,
          count: 100,
          interval: 2,
          expire: date.getTime() + 60 * 60 * 1000 * 3,
          excludedDates: [date.getTime() + 60 * 60 * 1000 * 2]
        },
        service: {
          type: calendarManager.ServiceType.TRIP,
          uri: 'xxx://xxx.xxx.com/xxx',
          description: 'One-click service'
        }
      }

      return await this.calendarManager?.editEvent(event);
    } catch (error) {
    }
    return 0;
  }


  async getCalendars(): Promise<calendarManager.Calendar[] | undefined> {
    try {
      return await this.calendarManager?.getAllCalendars();
    } catch (err) {
      console.error(`Failed to get calendar. Code: ${err.code}, message: ${err.message}`);
    }
    return undefined;
  }
}