import { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import GlobalContext from '../models/GlobalContext';

const CALENDAR_PERMISSIONS: Permissions[] = [
  'ohos.permission.READ_CALENDAR',
  'ohos.permission.READ_WHOLE_CALENDAR',
  'ohos.permission.WRITE_CALENDAR',
  'ohos.permission.WRITE_WHOLE_CALENDAR',
]

export default class PermissionHandler {
  private static instance: PermissionHandler;
  private context?: Context;

  constructor(context?: Context) {
    this.context = context;
  }

  static getInstance(): PermissionHandler {
    if (!PermissionHandler.instance) {
      let context = GlobalContext.getInstance().getAppContext();
      PermissionHandler.instance = new PermissionHandler(context);
    }

    return PermissionHandler.instance;
  }

  checkPermissionGrant(): void {
    let hasPermission = false;
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(0x0000, 'Index',
        `Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    try {
      let atManager = abilityAccessCtrl.createAtManager();
      let writeCalendar = atManager.checkAccessTokenSync(tokenId, 'ohos.permission.WRITE_CALENDAR');
      let writeWholeCalendar = atManager.checkAccessTokenSync(tokenId, 'ohos.permission.WRITE_WHOLE_CALENDAR');
      let readCalendar = atManager.checkAccessTokenSync(tokenId, 'ohos.permission.READ_CALENDAR');
      let readWholeCalendar = atManager.checkAccessTokenSync(tokenId, 'ohos.permission.READ_WHOLE_CALENDAR');
      hasPermission = writeCalendar === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED &&
        readCalendar === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED &&
        writeWholeCalendar === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED &&
        readWholeCalendar === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(0x0000, 'Index', `Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }
    if (!hasPermission) {
      this.requestPermissions();
    }
  }

  requestPermissions(): void {

    let atManager = abilityAccessCtrl.createAtManager();
    try {
      atManager.requestPermissionsFromUser(
        this.context,
        CALENDAR_PERMISSIONS
      ).then((data) => {
        if (data.authResults[0] === -1 || data.authResults[1] === -1) {
          if (data.dialogShownResults && (data.dialogShownResults[0] || data.dialogShownResults[1])) {
            console.info('Permissions granted')
          } else {
            this.openPermissionsSetting();
            return;
          }
        }
        if (data.authResults[0] !== 0) {
          return;
        }
      }).catch((err: Error) => {
        hilog.error(0x0000, 'Index', 'requestPermissionsFromUser err:' + JSON.stringify(err));
      });
    } catch (err) {
      hilog.error(0x0000, 'Index', 'requestPermissionsFromUser err:' + JSON.stringify(err));
    }
  }

  // The permission setting dialog box is displayed.
  private openPermissionsSetting(): void {
    let atManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionOnSetting(
      this.context,
      CALENDAR_PERMISSIONS
    )
      .then((data: Array<abilityAccessCtrl.GrantStatus>) => {
        console.info('Permission Granted')
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, 'Index', 'data:' + JSON.stringify(err));
      });
  }
}