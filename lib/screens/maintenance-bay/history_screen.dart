import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/maintenance_bay_model.dart';
import '../../models/train_model.dart';
import '../../providers/login_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/common/custom_header.dart';

class HistoryScreen extends StatefulWidget {
  final String initialDepot;

  const HistoryScreen({super.key, this.initialDepot = ''});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _api = ApiService();

  String depot = '';
  String slot = '';
  String trainSet = '';
  String dateFrom = '';
  String dateTo = '';

  List<MaintenanceBayModel> bays = [];
  List<TrainModel> trains = [];
  List<Map<String, dynamic>> records = [];
  bool loadingOptions = false;
  bool loadingHistory = false;
  String? error;

  @override
  void initState() {
    super.initState();
    depot = widget.initialDepot == 'Uppal'
        ? '633'
        : widget.initialDepot == 'Miyapur'
        ? '9373'
        : '';
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    setState(() => loadingOptions = true);
    try {
      final loginData = context.read<LoginProvider>().loginData;
      final roleId = context.read<LoginProvider>().selectedRoleId ??
          loginData?.roleIds.split(',').first.trim() ??
          '1';

      trains = await _api.getTrainSets(
        token: loginData?.token,
        userSession: loginData?.encodedUserSession,
        roleId: roleId,
      );
      if (depot.isNotEmpty) {
        bays = await _api.getMaintenanceBay(int.parse(depot));
      }
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) setState(() => loadingOptions = false);
    }
  }

  Future<void> _selectDepot(String value) async {
    setState(() {
      depot = value;
      slot = '';
      bays = [];
    });
    try {
      bays = await _api.getMaintenanceBay(int.parse(value));
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  Future<void> _pickDate(bool from) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;
    final value =
        '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
    setState(() {
      if (from) {
        dateFrom = value;
      } else {
        dateTo = value;
      }
    });
  }

  Future<void> _search() async {
    if (depot.isEmpty) {
      setState(() => error = 'Select a depot first.');
      return;
    }
    setState(() {
      loadingHistory = true;
      error = null;
    });
    try {
      records = await _api.getMaintenanceBayHistory(
        depot: depot,
        slot: slot,
        trainSet: trainSet,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
    } catch (e) {
      error = e.toString();
      records = [];
    } finally {
      if (mounted) setState(() => loadingHistory = false);
    }
  }

  String _value(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      final value = row[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '—';
  }

  String _depotName(String value) => value == '633' ? 'UPPAL' : 'MIYAPUR';

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const CustomHeader(
            title: 'Allocation History',
            subtitle: 'Maintenance Bay Allocation Records',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 180,
                          child: DropdownButtonFormField<String>(
                            initialValue: depot.isEmpty ? null : depot,
                            decoration: const InputDecoration(
                              labelText: 'Depot',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: '633',
                                child: Text('UPPAL'),
                              ),
                              DropdownMenuItem(
                                value: '9373',
                                child: Text('MIYAPUR'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) _selectDepot(value);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 220,
                          child: DropdownButtonFormField<String>(
                            initialValue: slot.isEmpty ? null : slot,
                            decoration: const InputDecoration(
                              labelText: 'Bay',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('All'),
                              ),
                              ...bays.map(
                                (bay) => DropdownMenuItem(
                                  value: bay.slot.toString(),
                                  child: Text(bay.slotName),
                                ),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => slot = value ?? ''),
                          ),
                        ),
                        SizedBox(
                          width: 220,
                          child: DropdownButtonFormField<String>(
                            initialValue: trainSet.isEmpty ? null : trainSet,
                            decoration: const InputDecoration(
                              labelText: 'Trainset',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('All'),
                              ),
                              ...trains.map(
                                (train) => DropdownMenuItem(
                                  value: train.id.toString(),
                                  child: Text(train.no),
                                ),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => trainSet = value ?? ''),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _pickDate(true),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            dateFrom.isEmpty ? 'Date From' : dateFrom,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _pickDate(false),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(dateTo.isEmpty ? 'Date To' : dateTo),
                        ),
                        FilledButton.icon(
                          onPressed: loadingHistory ? null : _search,
                          icon: loadingHistory
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.search),
                          label: const Text('Search'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (loadingOptions) const LinearProgressIndicator(),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (!loadingHistory && records.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('No allocation history records found.'),
                    ),
                  ),
                if (records.isNotEmpty)
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Bay')),
                          DataColumn(label: Text('Trainset')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Purpose')),
                          DataColumn(label: Text('Allocated On')),
                          DataColumn(label: Text('Remarks')),
                        ],
                        rows: records.map((row) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  _value(row, [
                                    'mbh_slot_name',
                                    'mbaSlotName',
                                    'slotName',
                                    'mbSlotName',
                                  ]),
                                ),
                              ),
                              DataCell(
                                Text(
                                  _value(row, [
                                    'mbh_train_set_name',
                                    'mbaTrainSetName',
                                    'trainSetName',
                                  ]),
                                ),
                              ),
                              DataCell(
                                Text(
                                  _value(row, [
                                    'mbh_status_name',
                                    'mbaStatusName',
                                    'statusName',
                                  ]),
                                ),
                              ),
                              DataCell(
                                Text(
                                  _value(row, [
                                    'mbh_purpose_name',
                                    'mbaPurposeName',
                                    'purposeName',
                                  ]),
                                ),
                              ),
                              DataCell(
                                Text(
                                  _value(row, [
                                    'mbh_inward',
                                    'created_on',
                                    'mbaAllocatedOn',
                                  ]),
                                ),
                              ),
                              DataCell(
                                Text(
                                  _value(row, [
                                    'mbh_remarks',
                                    'mbaRemarks',
                                    'remarks',
                                  ]),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                if (depot.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Depot: ${_depotName(depot)}'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
