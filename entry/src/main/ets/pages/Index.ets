import SmartCalendarPicker from '../components/SmartCalendarPicker';
import PermissionHandler from '../services/PermissionHandler';

@Entry
@Component
struct Index {
  aboutToAppear(): void {
    PermissionHandler.getInstance().checkPermissionGrant();
  }
  build() {
    RelativeContainer() {
      SmartCalendarPicker()
    }
    .height('100%')
    .width('100%')
  }
}