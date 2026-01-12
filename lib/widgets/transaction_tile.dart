import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../screens/transaction_detail_screen.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel txn;
  final VoidCallback? onChanged;
  const TransactionTile({Key? key, required this.txn, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isGave = txn.type == TransactionType.gave;
    final color = isGave ? Colors.red : Colors.green;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(txn: txn),
          ),
        );
        if (result == true && onChanged != null) {
          onChanged!();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(.15),
                child: Icon(isGave ? Icons.north_east : Icons.south_west,
                    color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (isGave ? 'You Gave ' : 'You Got ') +
                          txn.amount.toStringAsFixed(2),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM, yyyy – hh:mm a').format(txn.date),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (txn.note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        txn.note,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
