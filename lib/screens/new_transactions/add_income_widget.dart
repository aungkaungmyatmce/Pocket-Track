import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/decoration.dart';
import '../../models/income.dart';
import '../../provider/categories_provider.dart';
import '../../provider/transactions_provider.dart';

class AddIncomeWidget extends StatefulWidget {
  final DateTime date;
  const AddIncomeWidget({super.key, required this.date});

  @override
  State<AddIncomeWidget> createState() => _AddIncomeWidgetState();
}

class _AddIncomeWidgetState extends State<AddIncomeWidget> {
  final _form = GlobalKey<FormState>();
  final _incomeNameController = TextEditingController();
  final _incomeAmountController = TextEditingController();
  final _incomeNoteController = TextEditingController();
  final _incomeCategoryController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _noteFocusNode = FocusNode();
  bool _isLoading = false;
  List<String> sugNames = [];
  List<String> categoryNames = [];
  List<Income> incomeList = [];
  late String _categoryName;

  @override
  void dispose() {
    _incomeNameController.dispose();
    _incomeAmountController.dispose();
    _incomeNoteController.dispose();
    _incomeCategoryController.dispose();
    _amountFocusNode.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final isValid = _form.currentState?.validate();
    if (!isValid! || _incomeAmountController.text.isEmpty) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    });
    Income income = Income(
        category: _incomeCategoryController.text,
        amount: int.parse(_incomeAmountController.text),
        note: _incomeNoteController.text.isNotEmpty
            ? _incomeNoteController.text
            : null,
        date: widget.date);

    await Provider.of<TransactionsProvider>(context, listen: false)
        .addIncome(income, widget.date);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context);
  }

  void addSugNames() {
    //sugNames = Provider.of<TransactionProvider>(context).inSugNames();
    // incomeList = Provider.of<AllProvider>(context).allIncome;
    // incomeList.forEach((income) {
    //   if (!sugNames.contains(income.name)) {
    //     sugNames.add(income.name);
    //   }
    // });
  }

  @override
  void initState() {
    List<String> list = Provider.of<CategoriesProvider>(context, listen: false)
        .incomeCategories;

    categoryNames = list;
    _categoryName = categoryNames.first;
    _incomeCategoryController.text = list.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    addSugNames();
    return Form(
      key: _form,
      child: ListView(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 5),
            //padding: EdgeInsets.only(top: 10, bottom: 14, left: 7, right: 7),
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: Colors.white60,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                SizedBox(
                  height: 60,
                  child: DropdownButtonFormField(
                    isDense: false,
                    itemHeight: 60,
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(0, 5.5, 0, 0),
                        labelStyle: TextStyle(fontSize: 14),
                        labelText: 'Category'),
                    isExpanded: true,
                    items: categoryNames.map((String name) {
                      return DropdownMenuItem(
                          value: name,
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ));
                    }).toList(),
                    onChanged: (newValue) {
                      // do other stuff with _category
                      setState(() {
                        _categoryName = newValue!;
                        _incomeCategoryController.text = _categoryName;
                        FocusScope.of(context).requestFocus(_amountFocusNode);
                      });
                    },
                    value: _categoryName,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: TextFormField(
                    focusNode: _amountFocusNode,
                    controller: _incomeAmountController,
                    decoration: const InputDecoration(
                        labelStyle: TextStyle(fontSize: 14),
                        labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: TextFormField(
                    controller: _incomeNoteController,
                    focusNode: _noteFocusNode,
                    decoration: const InputDecoration(
                        labelStyle: TextStyle(fontSize: 14), labelText: 'Note'),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
              onPressed: _onSave,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Text(
                      'Save',
                    ))
        ],
      ),
    );
  }
}
