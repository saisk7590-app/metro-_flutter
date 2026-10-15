import 'package:flutter/foundation.dart';
import '../../data/checklist_default_data.dart';
import '../../models/checklist/checklist_model.dart';
import '../../services/api_service.dart';

/// Mixin managing Master Checklist configuration filters, queries, and backend catalog searches.
mixin ChecklistConfigMixin on ChangeNotifier {
  ApiService get apiService;

  List<JobPlanChecklistModel> configChecklists = [];
  JobPlanChecklistModel? selectedConfigChecklist;
  bool isLoadingConfigChecklists = false;

  String selectedCategory = '';
  String selectedJobPlan = '';
  String selectedChecklistName = '';
  String selectedStatus = '';
  String configSearchQuery = '';

  List<ChecklistCategoryItem> categoryItems = [];
  List<ChecklistJobPlanItem> jobPlanItems = [];
  List<ChecklistNameItem> checklistNameItems = [];
  bool isLoadingFilters = false;

  static const List<Map<String, String>> statusItems = [
    {'code': '', 'value': 'ALL'},
    {'code': '1', 'value': 'Active'},
    {'code': '2', 'value': 'InActive'},
  ];

  List<JobPlanChecklistModel> get filteredConfigChecklists {
    return configChecklists.where((c) {
      if (selectedCategory.isNotEmpty &&
          c.jpcCategory.toString() != selectedCategory &&
          c.assetCategoryCode != selectedCategory) {
        return false;
      }
      if (selectedJobPlan.isNotEmpty &&
          c.jobplanId.toString() != selectedJobPlan) {
        return false;
      }
      if (selectedChecklistName.isNotEmpty &&
          c.jpcChecklistName != selectedChecklistName) {
        return false;
      }
      if (selectedStatus.isNotEmpty &&
          c.jpcStatus.toString() != selectedStatus) {
        return false;
      }
      if (configSearchQuery.isNotEmpty) {
        final q = configSearchQuery.toLowerCase();
        final match = c.jpcChecklistName.toLowerCase().contains(q) ||
            c.jobplanName.toLowerCase().contains(q) ||
            c.assetCategoryCode.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();
  }

  Future<void> loadFilterOptions() async {
    isLoadingFilters = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        apiService.getAssetCategories(),
        apiService.getJobPlans(),
        apiService.getJobPlanChecklistNames(),
      ]);

      final categories = results[0] as List<ChecklistCategoryItem>;
      final jobPlans = results[1] as List<ChecklistJobPlanItem>;
      final checklistNames = results[2] as List<ChecklistNameItem>;

      categoryItems = categories.isNotEmpty
          ? categories
          : ChecklistDefaultData.defaultCategoryItems;
      jobPlanItems = jobPlans.isNotEmpty
          ? jobPlans
          : ChecklistDefaultData.defaultJobPlanItems;
      checklistNameItems = checklistNames.isNotEmpty
          ? checklistNames
          : ChecklistDefaultData.defaultChecklistNameItems;
    } catch (e) {
      debugPrint('Error loading filter options: $e');
      categoryItems = ChecklistDefaultData.defaultCategoryItems;
      jobPlanItems = ChecklistDefaultData.defaultJobPlanItems;
      checklistNameItems = ChecklistDefaultData.defaultChecklistNameItems;
    } finally {
      isLoadingFilters = false;
      notifyListeners();
    }
  }

  Future<void> loadConfigChecklists({bool refresh = false}) async {
    if (isLoadingConfigChecklists && !refresh) return;

    isLoadingConfigChecklists = true;
    notifyListeners();

    try {
      final apiList = await apiService.getScheduleChecklists(
        categoryId: selectedCategory,
        jobPlanId: selectedJobPlan,
        checklistName: selectedChecklistName,
        status: selectedStatus,
      );

      if (apiList.isNotEmpty) {
        configChecklists = apiList;
      } else {
        configChecklists = ChecklistDefaultData.generateDefaultConfigChecklists();
      }
    } catch (e) {
      debugPrint('Error loading config checklists: $e');
      configChecklists = ChecklistDefaultData.generateDefaultConfigChecklists();
    } finally {
      isLoadingConfigChecklists = false;
      notifyListeners();
    }
  }

  Future<void> searchConfigChecklists({
    String? categoryId,
    String? jobPlanId,
    String? checklistName,
    String? status,
  }) async {
    if (categoryId != null) selectedCategory = categoryId;
    if (jobPlanId != null) selectedJobPlan = jobPlanId;
    if (checklistName != null) selectedChecklistName = checklistName;
    if (status != null) selectedStatus = status;

    await loadConfigChecklists(refresh: true);
  }

  Future<void> resetSearch() async {
    selectedCategory = '';
    selectedJobPlan = '';
    selectedChecklistName = '';
    selectedStatus = '';
    configSearchQuery = '';
    await loadConfigChecklists(refresh: true);
  }

  Future<void> resetConfigFilters() async {
    await resetSearch();
  }

  void setCategoryFilter(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void setJobPlanFilter(String jobPlan) {
    selectedJobPlan = jobPlan;
    notifyListeners();
  }

  void setChecklistNameFilter(String name) {
    selectedChecklistName = name;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    selectedStatus = status;
    notifyListeners();
  }

  void setConfigSearchQuery(String query) {
    configSearchQuery = query;
    notifyListeners();
  }
}
