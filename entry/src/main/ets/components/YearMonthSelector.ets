import { MONTHS } from '../lib/constants';
import { YearDataSource } from '../models/YearDataSource';
import { YearItem } from '../models/YearItem';

@Component
export struct YearMonthSelector {
  onYearMonthSelected?: (year: number, month: number) => void;
  onClose?: () => void;
  @Prop year: number;
  @Prop month: number;
  @State selectedYear: number = this.year;
  @State selectedMonth: string = MONTHS[this.month];
  @State dataSource: YearDataSource = new YearDataSource(1900, new Date().getFullYear() + 50);
  @State isMonthView: boolean = false;
  private minYear: number = 2000;
  private maxYear: number = new Date().getFullYear() + 50;
  private scroller: Scroller = new Scroller;

  aboutToAppear(): void {
    this.dataSource = new YearDataSource(this.minYear, this.maxYear);
  }

  @Builder
  yearGridBuilder() {
    Grid(this.scroller) {
      LazyForEach(
        this.dataSource,
        (yearItem: YearItem) => {
          GridItem() {
            this.builderYearListItem(yearItem.year)
          }
        },
        (yearItem: YearItem) => yearItem.year.toString()
      )
    }
    .columnsTemplate('1fr 1fr 1fr')
    .rowsGap(5)
    .columnsGap(5)
    .width('100%')
    .height('100%')
    .cachedCount(12)
    .scrollBar(BarState.On)
    .width('100%')
    .height(100)
    .onAppear(() => {
      this.scrollToYear();
    })
  }

  @Builder
  monthGridBuilder() {
    Grid() {
      ForEach(
        MONTHS,
        (month: string) => {
          GridItem() {
            this.builderMonthListItem(month)
          }
        },
        (month: string) => month,
      )
    }
    .columnsTemplate('1fr 1fr 1fr')
    .rowsGap(5)
    .columnsGap(5)
    .width('100%')
    .height('100%')
  }

  build() {
    Column() {
      Row() {
        Button('-10')
          .width(40)
          .height(30)
          .padding(0)
          .margin({ right: 10 })
          .fontSize(16)
          .onClick(() => {
            this.navigateYears(-10);
          })

        Text(`${this.isMonthView ? this.selectedMonth : this.selectedYear}`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .margin({ bottom: 10 })
        Button('+10')
          .width(40)
          .height(30)
          .margin({ left: 10 })
          .padding(0)
          .fontSize(16)
          .onClick(() => {
            this.navigateYears(10);
          })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 20 })

      if (this.isMonthView) {
        this.monthGridBuilder();
      } else {
        this.yearGridBuilder()
      }

    }
    .padding({ bottom: 20 })
    .width('100%')
    .height('100%')

  }

  @Builder
  builderMonthListItem(month: string) {
    Row() {
      Text(month)
        .fontSize(18)
        .fontWeight(month === this.selectedMonth ? FontWeight.Bold : FontWeight.Normal)
        .layoutWeight(1)
        .height(20)
    }
    .borderRadius(10)
    .borderColor(month === this.selectedMonth ? Color.White : Color.Transparent)
    .borderWidth(month === this.selectedMonth ? 2 : 0)
    .onClick(() => {
      this.selectedMonth = month;
      const monthIndex = MONTHS.indexOf(this.selectedMonth);
      if (this.onYearMonthSelected) {
        this.onYearMonthSelected(this.selectedYear, monthIndex);
      }
      if (this.onClose) {
        this.onClose();
      }
    })
  }

  @Builder
  builderYearListItem(year: number) {
    Row() {
      Text(`${year}`)
        .fontSize(18)
        .fontWeight(year === this.selectedYear ? FontWeight.Bold : FontWeight.Normal)
        .layoutWeight(1)
        .height(20)
    }
    .borderRadius(10)
    .borderColor(year === this.selectedYear ? Color.White : Color.Transparent)
    .borderWidth(year === this.selectedYear ? 2 : 0)
    .onClick(() => {
      this.selectedYear = year;
      this.isMonthView = true;
    })
  }

  private scrollToYear(value: number = 5): void {
    const selectedYearIndex = this.dataSource.getIndexByYear(this.selectedYear);
    if (selectedYearIndex === -1) {
      return;
    }
    this.scroller.scrollToIndex(selectedYearIndex + value);
  }

  private navigateYears(offset: number) {
    let newYear = this.selectedYear + offset;
    if (newYear >= this.minYear && newYear < this.maxYear) {
      this.selectedYear = newYear;
      this.scrollToYear(offset > 0 ? 5 : -5);
    }
  }
}