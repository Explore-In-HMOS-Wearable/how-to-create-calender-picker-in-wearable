import { CustomContentDialog } from '@kit.ArkUI';
import { MonthDay } from '../lib/types';
import { formatDate, formatDay, getMonth, getNextDate, getPreviousDate, getYear } from '../lib/utils';
import { YearMonthSelector } from './YearMonthSelector';
import { WEEK_DAYS } from '../lib/constants';
import CalendarService from '../services/CalendarService';
import ListDataSource from '../viewmodels/ListDataSource';

@Component
export default struct SmartCalendarPicker {
  @State loading: boolean = true;
  @State currentDate: Date = new Date()
  @State month: string = getMonth(this.currentDate.getTime());
  @State year: string = getYear(this.currentDate.getTime());
  @State showPopup: boolean = false;
  @State selectedDate: Date = new Date();
  private days: ListDataSource<MonthDay> = new ListDataSource<MonthDay>()
  private calendarManager: CalendarService = CalendarService.getInstance()
  private context: UIContext = this.getUIContext();
  private dialogController: CustomDialogController = new CustomDialogController({
    cornerRadius: '50%',
    width: '100%',
    height: '100%',
    builder: CustomContentDialog({
      primaryTitle: 'Select Year',
      contentBuilder: () => {
        this.buildContent();
      },
    }),
  });

  aboutToAppear(): void {
    this.computedDays(this.currentDate).then((days) => {
      this.loading = false;
      days.forEach((day) => {
        this.days.pushData(day);
      })
    });
  }

  @Builder
  buildContent(): void {
    Column() {
      YearMonthSelector({
        year: this.currentDate.getFullYear(),
        month: this.currentDate.getMonth(),
        onYearMonthSelected: (year: number, month: number) => {
          let currentDate = new Date();
          currentDate.setTime(this.currentDate.getTime());
          currentDate.setFullYear(year, month)
          this.currentDate = currentDate;
          this.month = getMonth(currentDate.getTime())
          this.year = getYear(currentDate.getTime());
          this.loading = true;
          this.computedDays(currentDate).then((days) => {
            this.loading = false;
            this.days.resetData();
            days.forEach((day) => {
              this.days.pushData(day);
            })
          });
        },
        onClose: () => {
          this.dialogController.close();
        },
      })
    }
  }

  // Popup builder
  @Builder popupBuilder() {
    Row({ space: 2 }) {
      Text(formatDate(this.selectedDate.getTime())).fontSize(10)
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width(100)
    .height(30)
    .padding(5)
  }

  @Builder
  monthDayBuilder(monthDay: MonthDay) {
    GridItem() {
      Column() {
        Text(`${monthDay.index}`)
          .fontSize(12)
          .width('100%')
          .height('100%')
          .fontColor(monthDay.isNotCurrent ? Color.Gray : (
            monthDay.dayIndex == 6 || monthDay.dayIndex == 0 ? Color.Red : Color.White
          ))

          .borderWidth({
            top: 0,
            right: 0,
            bottom: monthDay.hasEvents ? 4 : 0,
            left: 0,
          })
          .borderColor(Color.Orange)
          .textAlign(TextAlign.Center)
      }
      .padding(2)
    }
    .onClick(() => {
      this.selectedDate = monthDay.date;
      this.showPopup = !this.showPopup;
    })
  }

  async computedDays(date: Date): Promise<MonthDay[]> {
    const currentMonthDays = await this.calendarManager.getDaysInMonth(date);
    const previousMonth = getPreviousDate(date.getTime());
    const previousMonthDays = await this.calendarManager.getDaysInMonth(previousMonth, true);
    const firstDayIndex = currentMonthDays[0].dayIndex;
    const previousSlicedLast = previousMonthDays.slice(previousMonthDays.length - firstDayIndex);

    const lastDayIndex = 6 - currentMonthDays[currentMonthDays.length - 1].dayIndex;
    const nextMonth = getNextDate(date.getTime());
    const nextMonthDays = await this.calendarManager.getDaysInMonth(nextMonth, true);
    const nextSlicedFirst = nextMonthDays.slice(0, lastDayIndex);

    return [...previousSlicedLast, ...currentMonthDays, ...nextSlicedFirst];
  }

  build() {
    Column() {
      Text(`${this.month}, ${this.year}`)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .padding({ bottom: '5vp' })
        .onClick(() => {
          this.dialogController.open()
        })

      if (this.loading) {
        LoadingProgress()
          .width('50vp')
          .height('50vp')
      } else {

        Grid() {
          ForEach(
            WEEK_DAYS,
            (day: string, index: number) => {
              GridItem() {
                Text(day)
                  .fontColor(index == WEEK_DAYS.length - 1 || index == 0 ? Color.Red : Color.White)
              }
            },
            (day: string) => day
          )

          LazyForEach(
            this.days,
            (monthDay: MonthDay) => this.monthDayBuilder(monthDay),
            (monthDay: MonthDay, index: number) => `${monthDay}${index}`
          )
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
        .columnsGap(1)
        .rowsGap(1)
        .width('80%')
        .height('65%')
      }
    }
    .padding({
      left: this.context.getWindowWidthBreakpoint() / 4.5,
      top: 0,
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .bindPopup(this.showPopup, {
      builder: this.popupBuilder,
      placement: Placement.Top,
      enableArrow: false,
      keyboardAvoidMode: KeyboardAvoidMode.DEFAULT,
      showInSubWindow: false,
      onStateChange: (e) => {
        if (!e.isVisible) {
          this.showPopup = false;
        }
      }
    })
    .gesture(
      SwipeGesture({ direction: SwipeDirection.All })
        .onAction((event: GestureEvent) => {
          const currentDateTimestamp = this.currentDate.getTime();
          let newDate = new Date();
          if (event.angle > 0) {
            newDate = getPreviousDate(currentDateTimestamp);
          } else {
            newDate = getNextDate(currentDateTimestamp);
          }
          this.currentDate = newDate;
          this.loading = true;
          this.computedDays(newDate).then((days) => {
            this.loading = false;
            this.days.resetData();
            days.forEach((day) => {
              this.days.pushData(day);
            })
          })
          this.month = getMonth(newDate.getTime());
          this.year = getYear(newDate.getTime());
        })
    )
  }
}