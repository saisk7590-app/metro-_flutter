import '../models/auth/login_model.dart';
import '../models/checklist/checklist_model.dart';
import '../models/maintenance_bay/maintenance_bay_model.dart';
import '../models/maintenance_bay/maintenance_purpose_model.dart';
import '../models/notifications/notification_model.dart';
import '../models/auth/profile_model.dart';
import '../models/maintenance_bay/status_model.dart';
import '../models/maintenance_bay/train_model.dart';
import '../models/meter/trainset_meter_reading_model.dart';
import '../models/wheel/wheel_measurement_model.dart';

import 'auth/auth_api_service.dart';
import 'base_api_service.dart';
import 'checklist/checklist_api_service.dart';
import 'maintenance_bay/lookups_api_service.dart';
import 'maintenance_bay/maintenance_bay_api_service.dart';
import 'meter/meter_reading_api_service.dart';
import 'notifications/notification_api_service.dart';
import 'auth/staff_profile_api_service.dart';
import 'wheel/wheel_measurement_api_service.dart';

export 'auth/auth_api_service.dart';
export 'base_api_service.dart';
export 'checklist/checklist_api_service.dart';
export 'maintenance_bay/lookups_api_service.dart';
export 'maintenance_bay/maintenance_bay_api_service.dart';
export 'meter/meter_reading_api_service.dart';
export 'notifications/notification_api_service.dart';
export 'auth/staff_profile_api_service.dart';
export 'wheel/wheel_measurement_api_service.dart';

/// Unified API facade that delegates to domain-specific modular services.
/// Provides 100% backward compatibility for all existing repositories and screens.
class ApiService {
  final AuthApiService auth;
  final MeterReadingApiService meterReading;
  final MaintenanceBayApiService maintenanceBay;
  final LookupsApiService lookups;
  final WheelMeasurementApiService wheelMeasurement;
  final ChecklistApiService checklist;
  final NotificationApiService notifications;
  final StaffProfileApiService staffProfile;

  ApiService({
    AuthApiService? auth,
    MeterReadingApiService? meterReading,
    MaintenanceBayApiService? maintenanceBay,
    LookupsApiService? lookups,
    WheelMeasurementApiService? wheelMeasurement,
    ChecklistApiService? checklist,
    NotificationApiService? notifications,
    StaffProfileApiService? staffProfile,
  })  : auth = auth ?? AuthApiService(),
        meterReading = meterReading ?? MeterReadingApiService(),
        maintenanceBay = maintenanceBay ?? MaintenanceBayApiService(),
        lookups = lookups ?? LookupsApiService(),
        wheelMeasurement = wheelMeasurement ?? WheelMeasurementApiService(),
        checklist = checklist ?? ChecklistApiService(),
        notifications = notifications ?? NotificationApiService(),
        staffProfile = staffProfile ?? StaffProfileApiService();

  // Static endpoints and token state
  static const String baseUrl = BaseApiService.baseUrl;
  static const String assetConfigBase = BaseApiService.assetConfigBase;
  static const String maintenanceConfigBase = BaseApiService.maintenanceConfigBase;
  static const String workOrderBase = BaseApiService.workOrderBase;
  static const String messagingBase = BaseApiService.messagingBase;
  static const String adminBase = BaseApiService.adminBase;

  static String? get currentToken => BaseApiService.currentToken;
  static set currentToken(String? value) => BaseApiService.currentToken = value;

  static String? get currentUserSession => BaseApiService.currentUserSession;
  static set currentUserSession(String? value) => BaseApiService.currentUserSession = value;

  static String? get currentRoleId => BaseApiService.currentRoleId;
  static set currentRoleId(String? value) => BaseApiService.currentRoleId = value;

  static String sanitizeToken(String raw) => BaseApiService.sanitizeToken(raw);
  static bool isTokenExpired(String? token) => BaseApiService.isTokenExpired(token);

  // 1. Auth & Recovery
  Future<LoginModel> login({
    required String userName,
    required String password,
    required String timeStamp,
    String captchaId = '',
    String captchaValue = '',
  }) =>
      auth.login(
        userName: userName,
        password: password,
        timeStamp: timeStamp,
        captchaId: captchaId,
        captchaValue: captchaValue,
      );

  Future<bool> logout({
    String userSession = '',
    String userSessionId = '',
    String remarks = 'User Logout',
  }) =>
      auth.logout(
        userSession: userSession,
        userSessionId: userSessionId,
        remarks: remarks,
      );

  Future<Map<String, dynamic>> generateCaptcha() => auth.generateCaptcha();

  Future<bool> validateCaptcha({
    required String captchaId,
    required String captchaValue,
  }) =>
      auth.validateCaptcha(
        captchaId: captchaId,
        captchaValue: captchaValue,
      );

  Future<Map<String, dynamic>> requestPasswordReset({
    required String username,
    required String mobileNumber,
  }) =>
      auth.requestPasswordReset(
        username: username,
        mobileNumber: mobileNumber,
      );

  Future<Map<String, dynamic>> validateOtp({
    required int userId,
    required String mfaReference,
    required String otp,
  }) =>
      auth.validateOtp(
        userId: userId,
        mfaReference: mfaReference,
        otp: otp,
      );

  Future<Map<String, dynamic>> resendOtp({required int userId}) =>
      auth.resendOtp(userId: userId);

  Future<Map<String, dynamic>> updateForgottenPassword({
    required int userId,
    required String otpReference,
    required String otp,
    required String newPassword,
  }) =>
      auth.updateForgottenPassword(
        userId: userId,
        otpReference: otpReference,
        otp: otp,
        newPassword: newPassword,
      );

  Future<Map<String, dynamic>> resetPassword({
    required int userId,
    required String newPassword,
    required int updatedBy,
  }) =>
      auth.resetPassword(
        userId: userId,
        newPassword: newPassword,
        updatedBy: updatedBy,
      );

  // 2. Meter Readings
  Future<TrainsetMeterReadingPage> getTrainsetMeterReadings({
    required String date,
    required int pageNo,
    required int pageSize,
    required int pagination,
    required String token,
    required String userSession,
    required String roleId,
  }) =>
      meterReading.getTrainsetMeterReadings(
        date: date,
        pageNo: pageNo,
        pageSize: pageSize,
        pagination: pagination,
        token: token,
        userSession: userSession,
        roleId: roleId,
      );

  Future<List<Map<String, dynamic>>> getTrainsetMeterDetails({
    required int trainsetId,
    required String location,
    required String date,
    required String token,
    required String userSession,
    required String roleId,
  }) =>
      meterReading.getTrainsetMeterDetails(
        trainsetId: trainsetId,
        location: location,
        date: date,
        token: token,
        userSession: userSession,
        roleId: roleId,
      );

  Future<Map<String, dynamic>> addTrainsetMeterReadings({
    required List<Map<String, dynamic>> readings,
    required String token,
    required String userSession,
    required String roleId,
  }) =>
      meterReading.addTrainsetMeterReadings(
        readings: readings,
        token: token,
        userSession: userSession,
        roleId: roleId,
      );

  // 3. Maintenance Bay
  Future<List<MaintenanceBayModel>> getMaintenanceBay(int depotId) =>
      maintenanceBay.getMaintenanceBay(depotId);

  Future<Map<String, dynamic>> getMaintenanceBayById(int mbId) =>
      maintenanceBay.getMaintenanceBayById(mbId);

  Future<Map<String, dynamic>> saveMaintenanceBay({
    required int mbId,
    required int mbDepot,
    required int mbSlot,
    required int mbTrainSet,
    required int mbStatus,
    required int mbPurpose,
    required String mbInward,
    required String mbOutward,
    required String mbRemark,
    bool isOutward = false,
    int? userId,
  }) =>
      maintenanceBay.saveMaintenanceBay(
        mbId: mbId,
        mbDepot: mbDepot,
        mbSlot: mbSlot,
        mbTrainSet: mbTrainSet,
        mbStatus: mbStatus,
        mbPurpose: mbPurpose,
        mbInward: mbInward,
        mbOutward: mbOutward,
        mbRemark: mbRemark,
        isOutward: isOutward,
        userId: userId,
      );

  Future<Map<String, dynamic>> saveMaintenanceBayAllocation({
    required int mbaMbId,
    required int mbaDepot,
    required int mbaSlot,
    required int mbaTrainSet,
    required int mbaPurpose,
    required int mbaStatus,
    required String mbaAllocatedOn,
    required String mbaAllocatedBy,
    required String mbaRemarks,
    int? userId,
  }) =>
      maintenanceBay.saveMaintenanceBayAllocation(
        mbaMbId: mbaMbId,
        mbaDepot: mbaDepot,
        mbaSlot: mbaSlot,
        mbaTrainSet: mbaTrainSet,
        mbaPurpose: mbaPurpose,
        mbaStatus: mbaStatus,
        mbaAllocatedOn: mbaAllocatedOn,
        mbaAllocatedBy: mbaAllocatedBy,
        mbaRemarks: mbaRemarks,
        userId: userId,
      );

  Future<List<Map<String, dynamic>>> getMaintenanceBayHistory({
    required String depot,
    String slot = '',
    String trainSet = '',
    String dateFrom = '',
    String dateTo = '',
  }) =>
      maintenanceBay.getMaintenanceBayHistory(
        depot: depot,
        slot: slot,
        trainSet: trainSet,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

  // 4. Lookups & Asset Config
  Future<List<StatusModel>> getMaintenanceStatus() =>
      lookups.getMaintenanceStatus();

  Future<List<MaintenancePurposeModel>> getMaintenancePurposes() =>
      lookups.getMaintenancePurposes();

  Future<List<TrainModel>> getTrainSets({
    String? token,
    String? userSession,
    String? roleId,
  }) =>
      lookups.getTrainSets(
        token: token,
        userSession: userSession,
        roleId: roleId,
      );

  // 5. Wheel Measurements
  Future<List<WheelMeasurementListItem>> getWheelMeasurementsList({
    String trainSet = '0',
    String schedule = '0',
    String from = '',
    String to = '',
    int pageNo = 1,
    int pageSize = 20,
  }) =>
      wheelMeasurement.getWheelMeasurementsList(
        trainSet: trainSet,
        schedule: schedule,
        from: from,
        to: to,
        pageNo: pageNo,
        pageSize: pageSize,
      );

  Future<WheelMeasurementData?> getWheelMeasurementDetails({
    required int woId,
    required int tsId,
  }) =>
      wheelMeasurement.getWheelMeasurementDetails(
        woId: woId,
        tsId: tsId,
      );

  Future<bool> saveWheelMeasurementDetails(WheelMeasurementData data) =>
      wheelMeasurement.saveWheelMeasurementDetails(data);

  // 6. Checklists
  Future<List<ChecklistWorkOrder>> getWorkOrdersForChecklist({
    String woNo = '',
    String unit = '0',
    String status = '0',
  }) =>
      checklist.getWorkOrdersForChecklist(
        woNo: woNo,
        unit: unit,
        status: status,
      );

  Future<List<CheckGroupModel>> getWorkOrderChecklistDetails(int workOrderId) =>
      checklist.getWorkOrderChecklistDetails(workOrderId);

  Future<bool> updateWorkOrderChecksheetItem({
    required int id,
    required int compliance,
    required String remarks,
  }) =>
      checklist.updateWorkOrderChecksheetItem(
        id: id,
        compliance: compliance,
        remarks: remarks,
      );

  Future<bool> saveWorkOrderChecksheet({
    required List<CheckGroupModel> groups,
  }) =>
      checklist.saveWorkOrderChecksheet(groups: groups);

  Future<List<ChecklistCategoryItem>> getAssetCategories() =>
      checklist.getAssetCategories();

  Future<List<ChecklistJobPlanItem>> getJobPlans() =>
      checklist.getJobPlans();

  Future<List<ChecklistNameItem>> getJobPlanChecklistNames() =>
      checklist.getJobPlanChecklistNames();

  Future<List<JobPlanChecklistModel>> getScheduleChecklists({
    String categoryId = '0',
    String jobPlanId = '0',
    String checklistName = '',
    String status = '0',
  }) =>
      checklist.getScheduleChecklists(
        categoryId: categoryId,
        jobPlanId: jobPlanId,
        checklistName: checklistName,
        status: status,
      );

  Future<List<CheckGroupModel>> getChecklistDetails(int checkListId) =>
      checklist.getChecklistDetails(checkListId);

  Future<bool> saveChecklist({
    required int jobPlanId,
    required String checklistName,
    required int categoryId,
    int status = 1,
  }) =>
      checklist.saveChecklist(
        jobPlanId: jobPlanId,
        checklistName: checklistName,
        categoryId: categoryId,
        status: status,
      );

  Future<bool> saveChecklistGroup({
    required int checkListId,
    required String groupName,
  }) =>
      checklist.saveChecklistGroup(
        checkListId: checkListId,
        groupName: groupName,
      );

  Future<bool> saveChecklistGroupItem({
    required int groupId,
    required String subGroup,
    required String checkDescription,
  }) =>
      checklist.saveChecklistGroupItem(
        groupId: groupId,
        subGroup: subGroup,
        checkDescription: checkDescription,
      );

  Future<bool> updateChecklistName({
    required int jpcId,
    required String checklistName,
    int? jobPlanId,
    int? categoryId,
    int? status,
  }) =>
      checklist.updateChecklistName(
        jpcId: jpcId,
        checklistName: checklistName,
        jobPlanId: jobPlanId,
        categoryId: categoryId,
        status: status,
      );

  Future<bool> deleteChecklist({required int jpcId}) =>
      checklist.deleteChecklist(jpcId: jpcId);

  Future<bool> deleteChecklistItem({required int checkItemId}) =>
      checklist.deleteChecklistItem(checkItemId: checkItemId);

  Future<bool> updateChecklistGroup({
    required int groupId,
    required String groupName,
  }) =>
      checklist.updateChecklistGroup(
        groupId: groupId,
        groupName: groupName,
      );

  Future<bool> deleteChecklistGroup({required int groupId}) =>
      checklist.deleteChecklistGroup(groupId: groupId);

  Future<bool> updateChecklistGroupItem({
    required int checkItemId,
    required String subGroup,
    required String checkDescription,
  }) =>
      checklist.updateChecklistGroupItem(
        checkItemId: checkItemId,
        subGroup: subGroup,
        checkDescription: checkDescription,
      );

  // 7. Notifications
  Future<List<NotificationModel>> getNotifications({
    String? unitId,
    String? roleId,
  }) =>
      notifications.getNotifications(unitId: unitId, roleId: roleId);

  Future<int> getNotificationsCount({String? userId}) =>
      notifications.getNotificationsCount(userId: userId);

  Future<bool> updateNotificationReadStatus({required int messageRecipientId}) =>
      notifications.updateNotificationReadStatus(
        messageRecipientId: messageRecipientId,
      );

  // 8. Staff & Profile
  Future<StaffProfileModel?> getStaffDetails({required String staffId}) =>
      staffProfile.getStaffDetails(staffId: staffId);

  Future<bool> updateStaffProfile({required Map<String, dynamic> staff}) =>
      staffProfile.updateStaffProfile(staff: staff);
}
