import 'package:app_in_snap_task/upload/presentation/manager/home_page_view_model.dart';
import 'package:app_in_snap_task/upload/presentation/widgets/avatar.dart';
import 'package:app_in_snap_task/upload/presentation/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomePageViewModel _viewModel;

  final TextEditingController _nameController = TextEditingController();
  final String _nameLabelText = 'Name';
  final String _nameValidationString = 'Name cannot be empty';
  final TextInputType _nameKeyboardType = TextInputType.name;

  final TextEditingController _ageController = TextEditingController();
  final String _ageLabelText = 'Age';
  final String _ageValidationString = 'Age cannot be empty';
  final TextInputType _ageKeyboardType = TextInputType.number;
  final FocusNode _ageFocusNode = FocusNode();

  @override
  void initState() {
    _viewModel = HomePageViewModel();
    _viewModel.getCounter();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _viewModel.watchExistingData(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AppInSnap Task'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: _viewModel.isLoading.value ? const Center(child: Text('Loading...')) : _buildUi(),
          ),
        ),
      ),
    );
  }

  _buildUi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.center,
          child: Avatar(viewModel: _viewModel),
        ),
        const SizedBox(height: 44),
        ValueListenableBuilder(
          valueListenable: _viewModel.name,
          builder: (_, String name, __) {
            return Text(
              'Name: ${name.isEmpty ? 'N/A' : name}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headline4,
            );
          },
        ),
        const SizedBox(height: 12),
        CustomTextFormField(
          controller: _nameController,
          labelText: _nameLabelText,
          keyboardType: _nameKeyboardType,
          validationString: _nameValidationString,
          onChanged: _viewModel.onNameChanged,
          onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_ageFocusNode),
        ),
        const SizedBox(height: 44),
        ValueListenableBuilder(
          valueListenable: _viewModel.age,
          builder: (_, String age, __) {
            return Text(
              'Age: ${age.isEmpty ? 'N/A' : age}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headline4,
            );
          },
        ),
        const SizedBox(height: 12),
        CustomTextFormField(
          controller: _ageController,
          labelText: _ageLabelText,
          keyboardType: _ageKeyboardType,
          validationString: _ageValidationString,
          focusNode: _ageFocusNode,
          onChanged: _viewModel.onAgeChanged,
          onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(FocusNode()),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 44),
        ElevatedButton(
          onPressed: () async {
            await _viewModel.submit(context);
            _ageController.text = '';
            _nameController.text = '';
          },
          child: const Text('Upload'),
        ),
        const SizedBox(height: 44),
        ValueListenableBuilder(
          valueListenable: _viewModel.timer,
          builder: (_, int value, __) {
            return Align(
              alignment: Alignment.center,
              child: Text(
                'Next API Call for Firestore in $value',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          },
        ),
      ],
    );
  }
}
