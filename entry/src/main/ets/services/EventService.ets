import { calendarManager } from '@kit.CalendarKit';

export default class EventService {
  private static instance: EventService;

  static getInstance(): EventService {
    if (!EventService.instance) {
      EventService.instance = new EventService();
    }

    return EventService.instance;
  }

  async getAllEventsByCalendar(calendar: calendarManager.Calendar): Promise<calendarManager.Event[]> {
    try {
      return await calendar.getEvents();
    } catch (error) {
      console.error(`Error: ${error.code} ${error.message}`)
    }
    return [];
  }

  async getEventById(calendar: calendarManager.Calendar, id: number): Promise<calendarManager.Event | undefined> {
    try {
      const events = await calendar.getEvents();
      const event = events?.find((event) => event.id === id);
      if (event) {
        return event;
      }
    } catch (err) {
      console.error(`Failed to get calendar. Code: ${err.code}, message: ${err.message}`);
    }
    return undefined;
  }
}