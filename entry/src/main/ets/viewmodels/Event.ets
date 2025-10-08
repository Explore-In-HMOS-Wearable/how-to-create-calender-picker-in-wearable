import { calendarManager } from '@kit.CalendarKit';
import { formatDate, formatTime } from '../lib/utils';

export default class Event {
  constructor(event: calendarManager.Event) {
    this._event = event;
  }

  private _event: calendarManager.Event;

  get event(): calendarManager.Event {
    return this._event;
  }

  private _color: ResourceColor = Color.Green;

  get color(): ResourceColor {
    if (this._event.type === calendarManager.EventType.IMPORTANT) {
      return Color.Brown;
    }
    return this._color;
  }

  get title(): string {
    return this._event.title ?? '';
  }

  get startTime(): string {
    return formatTime(this._event.startTime);
  }

  get startDate(): string {
    return formatDate(this._event.startTime);
  }

  get endDate(): string {
    return formatDate(this._event.endTime);
  }

  get endTime(): string {
    return formatTime(this._event.endTime);
  }
}