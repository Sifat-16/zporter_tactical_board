import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/admin/model/version_config_model.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/version_control/version_config_controller.dart';
import 'app_version_docs_screen.dart';

class AppVersionManagementScreen extends ConsumerStatefulWidget {
  const AppVersionManagementScreen({super.key});

  @override
  ConsumerState<AppVersionManagementScreen> createState() =>
      _AppVersionManagementScreenState();
}

class _AppVersionManagementScreenState
    extends ConsumerState<AppVersionManagementScreen> {
  late VersionConfig _localConfig;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _localConfig = ref.read(versionConfigProvider).config;
  }

  Future<void> _onSaveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSaving = true);
    final success =
        await ref.read(versionConfigProvider.notifier).saveConfig(_localConfig);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Settings saved successfully!'
              : 'Failed to save settings.'),
          backgroundColor: success ? ColorManager.green : ColorManager.red,
        ),
      );
    }
    setState(() => _isSaving = false);
  }

  void _showRuleEditor({UpdateRule? rule}) {
    final isEditing = rule != null;
    showDialog(
      context: context,
      builder: (_) => _RuleEditorDialog(
        rule: rule,
        onSave: (editedRule) {
          setState(() {
            if (isEditing) {
              final index = _localConfig.rules.indexWhere((r) => r == rule);
              if (index != -1) _localConfig.rules[index] = editedRule;
            } else {
              final newName = editedRule.ruleName;
              int count = 1;
              String finalName = newName;
              while (_localConfig.rules.any((r) => r.ruleName == finalName)) {
                finalName = '$newName (${++count})';
              }
              _localConfig.rules.add(editedRule.copyWith(ruleName: finalName));
            }
          });
        },
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.dark2,
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: ColorManager.yellow),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(content,
            style: const TextStyle(color: ColorManager.grey, height: 1.5)),
        actions: [
          TextButton(
            child: const Text('Got it'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(versionConfigProvider, (_, next) {
      if (next.config != _localConfig)
        setState(() => _localConfig = next.config);
    });
    final state = ref.watch(versionConfigProvider);

    return Scaffold(
      backgroundColor: ColorManager.black,
      appBar: AppBar(
        title: const Text('App Version Management',
            style: TextStyle(color: ColorManager.white)),
        backgroundColor: ColorManager.black,
        iconTheme: const IconThemeData(color: ColorManager.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: 'Open Documentation',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AppVersionDocsScreen()),
              );
            },
          ),
        ],
      ),
      body: state.isLoading && _localConfig == VersionConfig.empty()
          ? const Center(
              child: CircularProgressIndicator(color: ColorManager.yellow))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildSectionHeader("Master Switch"),
                  SwitchListTile(
                    title: const Text('Force Update Enabled',
                        style: TextStyle(color: ColorManager.white)),
                    secondary: IconButton(
                      icon: const Icon(Icons.info_outline,
                          color: ColorManager.grey, size: 20),
                      onPressed: () => _showInfoDialog('Force Update Enabled',
                          'This is the main on/off switch for the entire system. If this is turned off, no users will ever see an update prompt, regardless of the rules.'),
                    ),
                    value: _localConfig.isForceUpdateEnabled,
                    onChanged: (value) => setState(() => _localConfig =
                        _localConfig.copyWith(isForceUpdateEnabled: value)),
                    activeColor: ColorManager.yellow,
                    tileColor: ColorManager.dark1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Default Settings"),
                  _buildTextField(
                      label: 'Default Minimum Android Version',
                      initialValue: _localConfig.defaultMinAndroidVersion,
                      onSaved: (value) => _localConfig = _localConfig.copyWith(
                          defaultMinAndroidVersion: value),
                      helpText:
                          'The app version users must have on Android if they don\'t match any specific rule. Format: X.Y.Z'),
                  const SizedBox(height: 16),
                  _buildTextField(
                      label: 'Default Minimum iOS Version',
                      initialValue: _localConfig.defaultMinIosVersion,
                      onSaved: (value) => _localConfig =
                          _localConfig.copyWith(defaultMinIosVersion: value),
                      helpText:
                          'The app version users must have on iOS if they don\'t match any specific rule. Format: X.Y.Z'),
                  const SizedBox(height: 16),
                  _buildTextField(
                      label: 'Update Dialog Title',
                      initialValue: _localConfig.updateTitle,
                      onSaved: (value) => _localConfig =
                          _localConfig.copyWith(updateTitle: value),
                      helpText:
                          'The main title of the pop-up dialog shown to users.'),
                  const SizedBox(height: 16),
                  _buildTextField(
                      label: 'Update Dialog Message',
                      initialValue: _localConfig.updateMessage,
                      maxLines: 3,
                      onSaved: (value) => _localConfig =
                          _localConfig.copyWith(updateMessage: value),
                      helpText:
                          'The descriptive text shown in the pop-up dialog.'),
                  const SizedBox(height: 16),
                  _buildTextField(
                      label: 'Android Play Store URL',
                      initialValue: _localConfig.androidStoreUrl,
                      onSaved: (value) => _localConfig =
                          _localConfig.copyWith(androidStoreUrl: value),
                      helpText:
                          'The full URL to your app on the Google Play Store.'),
                  const SizedBox(height: 16),
                  _buildTextField(
                      label: 'iOS App Store URL',
                      initialValue: _localConfig.iosStoreUrl,
                      onSaved: (value) => _localConfig =
                          _localConfig.copyWith(iosStoreUrl: value),
                      helpText:
                          'The full URL to your app on the Apple App Store.'),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Targeting Rules"),
                  if (_localConfig.rules.isEmpty)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text('No targeting rules created yet.',
                                style: TextStyle(color: ColorManager.grey)))),
                  ..._localConfig.rules.map((rule) => Card(
                        color: ColorManager.dark1,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(rule.ruleName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              'Type: ${rule.updateType} | Rollout: ${rule.rolloutPercentage}%',
                              style: const TextStyle(color: ColorManager.grey)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      color: ColorManager.blueAccent),
                                  onPressed: () => _showRuleEditor(rule: rule)),
                              IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: ColorManager.red),
                                  onPressed: () => setState(
                                      () => _localConfig.rules.remove(rule))),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    icon: const Icon(Icons.add, color: ColorManager.yellow),
                    label: const Text('Add New Rule',
                        style: TextStyle(color: ColorManager.yellow)),
                    onPressed: _showRuleEditor,
                    style: TextButton.styleFrom(
                        side: const BorderSide(color: ColorManager.yellow),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _onSaveChanges,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.green,
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _isSaving
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Save Changes',
                              style: TextStyle(
                                  color: ColorManager.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 24.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: ColorManager.grey,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Function(String?) onSaved,
    int maxLines = 1,
    String? helpText,
  }) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      style: const TextStyle(color: ColorManager.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: ColorManager.grey),
        filled: true,
        fillColor: ColorManager.dark1,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
        suffixIcon: helpText != null
            ? IconButton(
                icon: const Icon(Icons.info_outline,
                    color: ColorManager.grey, size: 20),
                onPressed: () => _showInfoDialog(label, helpText),
                tooltip: 'More information',
              )
            : null,
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'This field cannot be empty' : null,
      onSaved: onSaved,
    );
  }
}

class _RuleEditorDialog extends StatefulWidget {
  final UpdateRule? rule;
  final Function(UpdateRule) onSave;

  const _RuleEditorDialog({this.rule, required this.onSave});

  @override
  State<_RuleEditorDialog> createState() => _RuleEditorDialogState();
}

class _RuleEditorDialogState extends State<_RuleEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _ruleName;
  late String _updateType;
  late String _minAndroidVersion;
  late String _minIosVersion;
  late int _rolloutPercentage;
  late List<String> _targetAppVersions;
  late List<String> _targetCountries;
  late List<String> _targetUserIds;
  late List<String> _targetPlatforms;

  @override
  void initState() {
    super.initState();
    _ruleName = widget.rule?.ruleName ?? 'New Rule';
    _updateType = widget.rule?.updateType ?? 'hard';
    _minAndroidVersion = widget.rule?.minAndroidVersion ?? '1.0.0';
    _minIosVersion = widget.rule?.minIosVersion ?? '1.0.0';
    _rolloutPercentage = widget.rule?.rolloutPercentage ?? 100;
    _targetAppVersions =
        List<String>.from(widget.rule?.targetAppVersions ?? []);
    _targetCountries = List<String>.from(widget.rule?.targetCountries ?? []);
    _targetUserIds = List<String>.from(widget.rule?.targetUserIds ?? []);
    _targetPlatforms = List<String>.from(widget.rule?.targetPlatforms ?? []);
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final newRule = UpdateRule(
      ruleName: _ruleName,
      updateType: _updateType,
      minAndroidVersion: _minAndroidVersion,
      minIosVersion: _minIosVersion,
      rolloutPercentage: _rolloutPercentage,
      targetAppVersions: _targetAppVersions,
      targetCountries: _targetCountries,
      targetUserIds: _targetUserIds,
      targetPlatforms: _targetPlatforms,
    );

    widget.onSave(newRule);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorManager.dark2,
      title: Text(widget.rule == null ? 'Add New Rule' : 'Edit Rule',
          style: const TextStyle(color: Colors.white)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.4,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                    label: 'Rule Name',
                    initialValue: _ruleName,
                    onSaved: (v) => _ruleName = v!),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _updateType,
                  items: ['hard', 'soft']
                      .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type,
                              style: const TextStyle(color: Colors.white))))
                      .toList(),
                  onChanged: (value) => setState(() => _updateType = value!),
                  decoration: _buildInputDecoration('Update Type'),
                  dropdownColor: ColorManager.dark1,
                ),
                const SizedBox(height: 20),
                Text("Platforms (Leave blank for all)",
                    style: TextStyle(color: ColorManager.grey)),
                CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title:
                        Text("Android", style: TextStyle(color: Colors.white)),
                    value: _targetPlatforms.contains('android'),
                    onChanged: (val) => setState(() => val!
                        ? _targetPlatforms.add('android')
                        : _targetPlatforms.remove('android')),
                    activeColor: ColorManager.yellow),
                CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text("iOS", style: TextStyle(color: Colors.white)),
                    value: _targetPlatforms.contains('ios'),
                    onChanged: (val) => setState(() => val!
                        ? _targetPlatforms.add('ios')
                        : _targetPlatforms.remove('ios')),
                    activeColor: ColorManager.yellow),
                const SizedBox(height: 10),
                _buildTextField(
                    label: 'Min Android Version',
                    initialValue: _minAndroidVersion,
                    onSaved: (v) => _minAndroidVersion = v!),
                const SizedBox(height: 20),
                _buildTextField(
                    label: 'Min iOS Version',
                    initialValue: _minIosVersion,
                    onSaved: (v) => _minIosVersion = v!),
                const SizedBox(height: 20),
                _buildTextField(
                    label: 'Rollout Percentage (0-100)',
                    initialValue: _rolloutPercentage.toString(),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSaved: (v) =>
                        _rolloutPercentage = int.tryParse(v!) ?? 100,
                    validator: (v) => (int.tryParse(v ?? '0') ?? 0) > 100
                        ? 'Cannot exceed 100'
                        : null),
                const SizedBox(height: 20),
                _buildTextField(
                    label: 'Target App Versions (comma-separated)',
                    initialValue: _targetAppVersions.join(','),
                    onSaved: (v) => _targetAppVersions = v!
                        .split(',')
                        .where((s) => s.trim().isNotEmpty)
                        .toList()),
                const SizedBox(height: 20),
                _buildTextField(
                    label: 'Target Country Codes (comma-separated)',
                    initialValue: _targetCountries.join(','),
                    onSaved: (v) => _targetCountries = v!
                        .toUpperCase()
                        .split(',')
                        .where((s) => s.trim().isNotEmpty)
                        .toList()),
                const SizedBox(height: 20),
                _buildTextField(
                    label: 'Target User IDs (comma-separated)',
                    initialValue: _targetUserIds.join(','),
                    maxLines: 2,
                    onSaved: (v) => _targetUserIds = v!
                        .split(',')
                        .where((s) => s.trim().isNotEmpty)
                        .toList()),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        ElevatedButton(onPressed: _onSave, child: const Text('Save Rule')),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String label) => InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: ColorManager.grey),
      filled: true,
      fillColor: ColorManager.dark1,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none));
  Widget _buildTextField(
          {required String label,
          required String initialValue,
          int maxLines = 1,
          required Function(String?) onSaved,
          TextInputType? keyboardType,
          List<TextInputFormatter>? inputFormatters,
          String? Function(String?)? validator}) =>
      TextFormField(
          initialValue: initialValue,
          maxLines: maxLines,
          style: const TextStyle(color: ColorManager.white),
          decoration: _buildInputDecoration(label),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator ??
              (value) => (value == null || value.trim().isEmpty)
                  ? 'This field cannot be empty'
                  : null,
          onSaved: onSaved);
}
