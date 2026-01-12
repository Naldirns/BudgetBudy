import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/db_helper.dart';
import '../models/transaction_model.dart';

class TransactionDetailScreen extends StatefulWidget {
  final TransactionModel txn;
  const TransactionDetailScreen({Key? key, required this.txn})
      : super(key: key);

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late TransactionModel txn;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    txn = widget.txn;
  }

  String _formatAmountForInput(double amount) {
    if (amount % 1 == 0) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }

  Future<void> _edit() async {
    final noteController = TextEditingController(text: txn.note);
    final amountController =
        TextEditingController(text: _formatAmountForInput(txn.amount));
    DateTime date = txn.date;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Enter Details'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.event),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    DateFormat('dd MMM, yyyy – hh:mm a').format(date),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        date = DateTime(picked.year, picked.month, picked.day,
                            date.hour, date.minute);
                      });
                    }
                  },
                  child: const Text('Change'),
                )
              ],
            )
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA80852),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () async {
              final amount = double.tryParse(amountController.text.trim());
              if (amount == null || amount <= 0) return;
              final updated = TransactionModel(
                id: txn.id,
                partyId: txn.partyId,
                amount: amount,
                type: txn.type,
                date: date,
                note: noteController.text.trim(),
              );
              await DBHelper.updateTransaction(updated);
              if (!mounted) return;
              setState(() => txn = updated);
              _changed = true;
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  Future<void> _delete() async {
    if (txn.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA80852),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await DBHelper.deleteTransaction(txn.id!);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGave = txn.type == TransactionType.gave;
    final color = isGave ? Colors.red : Colors.green;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_changed);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Entry Details')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        CircleAvatar(
                            backgroundColor: color.withOpacity(.15),
                            child: Icon(
                                isGave ? Icons.north_east : Icons.south_west,
                                color: color)),
                        const SizedBox(width: 12),
                        const Text('Entry',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 18)),
                      ]),
                      Text('₹ ${txn.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              color: color)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(DateFormat('dd MMM yy · hh:mm a').format(txn.date)),
                  const SizedBox(height: 16),
                  const Text('Details',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(txn.note.isEmpty ? '-' : txn.note),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _delete,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA80852),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _edit,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Entry'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
