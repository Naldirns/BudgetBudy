import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/db_helper.dart';
import '../models/party.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_tile.dart';

class PartyProfileScreen extends StatefulWidget {
  final Party party;
  const PartyProfileScreen({Key? key, required this.party}) : super(key: key);

  @override
  State<PartyProfileScreen> createState() => _PartyProfileScreenState();
}

class _PartyProfileScreenState extends State<PartyProfileScreen> {
  late Future<List<TransactionModel>> _futureTxns;
  double _balance = 0;
  bool _hasTransactions = false;
  late Party _currentParty;

  @override
  void initState() {
    super.initState();
    _currentParty = widget.party;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _futureTxns = DBHelper.getTransactionsByPartyId(_currentParty.id!);
    });
    final bal = await DBHelper.getPartyBalance(_currentParty.id!);
    final txns = await DBHelper.getTransactionsByPartyId(_currentParty.id!);
    setState(() {
      _balance = bal;
      _hasTransactions = txns.isNotEmpty;
    });
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  Color _getColorFromName(String name) {
    final colors = [
      Colors.blue.shade400,
      Colors.purple.shade400,
      Colors.pink.shade400,
      Colors.teal.shade400,
      Colors.orange.shade400,
      Colors.indigo.shade400,
      Colors.cyan.shade400,
      Colors.deepOrange.shade400,
    ];
    final index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  void _showPartyDetails() {
    final hasPhone = _currentParty.phone.isNotEmpty;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _getColorFromName(_currentParty.name),
                  child: Text(
                    _getInitials(_currentParty.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _currentParty.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            // Phone number section
            hasPhone
                ? ListTile(
                    leading: const Icon(Icons.phone, color: Colors.blue),
                    title: const Text('Phone Number'),
                    subtitle: Text(_currentParty.phone),
                    trailing: IconButton(
                      icon: const Icon(Icons.call, color: Colors.green),
                      onPressed: () async {
                        // Clean phone number and add Indian country code
                        String phone = _currentParty.phone
                            .replaceAll(RegExp(r'[\s\-\(\)]'), '');
                        // Add +91 if not already present
                        if (!phone.startsWith('+91') &&
                            !phone.startsWith('91')) {
                          phone = '+91$phone';
                        } else if (phone.startsWith('91') &&
                            !phone.startsWith('+')) {
                          phone = '+$phone';
                        }
                        final Uri phoneUri = Uri.parse('tel:$phone');
                        try {
                          await launchUrl(phoneUri);
                        } catch (e) {
                          // Silently fail - phone functionality not available on emulator
                        }
                      },
                    ),
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 16),
            // Edit Party button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA80852),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _showEditPartyDialog();
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text(
                    'Edit Party',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Delete button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.grey[50],
                        title: const Text('Delete Party'),
                        content: const Text(
                            'Delete this party and all its entries? This cannot be undone.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel')),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Delete')),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await DBHelper.deleteParty(widget.party.id!);
                      if (!mounted) return;
                      Navigator.of(context).pop(true);
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text(
                    'Delete Party',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showEditPartyDialog() {
    final nameController = TextEditingController(text: _currentParty.name);
    final phoneController = TextEditingController(
      text: _currentParty.phone.isNotEmpty ? _currentParty.phone : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[50],
        title: const Text('Edit Party'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter party name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixText: '+91 ',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA80852),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();

              // Validate name
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a name'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              // Validate and clean phone number
              String cleanPhone = '';
              if (phone.isNotEmpty) {
                cleanPhone = phone.replaceAll(RegExp(r'[\s\-\+]'), '');

                // Remove country code if present
                if (cleanPhone.startsWith('91') && cleanPhone.length == 12) {
                  cleanPhone = cleanPhone.substring(2);
                }

                // Validate Indian phone number
                if (cleanPhone.length != 10 ||
                    !RegExp(r'^[6-9]\d{9}$').hasMatch(cleanPhone)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please enter a valid 10-digit Indian phone number'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
              }

              try {
                final updatedParty = Party(
                  id: _currentParty.id,
                  name: name,
                  phone: cleanPhone,
                );

                final result = await DBHelper.updateParty(updatedParty);

                if (result > 0) {
                  setState(() {
                    _currentParty = updatedParty;
                  });

                  Navigator.of(ctx).pop();

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Party updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  Navigator.of(ctx).pop();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to update party'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                Navigator.of(ctx).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addTransaction(TransactionType type) async {
    final noteController = TextEditingController();
    final amountController = TextEditingController();
    DateTime date = DateTime.now();

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.grey[50],
              title:
                  Text(type == TransactionType.gave ? 'You Gave' : 'You Got'),
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
                    decoration:
                        const InputDecoration(labelText: 'Enter Details'),
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
                            setDialogState(() {
                              date = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                date.hour,
                                date.minute,
                              );
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
                  ),
                  onPressed: () async {
                    final amount =
                        double.tryParse(amountController.text.trim());
                    if (amount == null || amount <= 0) return;
                    await DBHelper.insertTransaction(
                      TransactionModel(
                        partyId: widget.party.id!,
                        amount: amount,
                        type: type,
                        date: date,
                        note: noteController.text.trim(),
                      ),
                    );
                    if (!mounted) return;
                    Navigator.of(ctx).pop();
                    await _load();
                  },
                  child: const Text('Save'),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isGive =
        _balance > 0; // positive => you will give; negative => you will get
    final bool isZero = _balance == 0;
    final Color balColor =
        isGive ? const Color(0xFFDF1837) : const Color(0xFF029856);
    final String summaryLabel = isGive ? 'You will give' : 'You will get';
    final double displayAmount = _balance.abs();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: _getColorFromName(_currentParty.name),
              child: Text(
                _getInitials(_currentParty.name),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentParty.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  InkWell(
                    onTap: _showPartyDetails,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        'View settings',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Modern Header Card - only show if has transactions
          if (_hasTransactions)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: (isZero && _hasTransactions)
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle,
                                color: Colors.green, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Settled Up',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            summaryLabel,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '₹ ${displayAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              color: balColor,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          Expanded(
            child: FutureBuilder<List<TransactionModel>>(
              future: _futureTxns,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final txns = snapshot.data ?? [];
                if (txns.isEmpty) {
                  return const SizedBox.shrink();
                }

                // Group transactions by date
                final groupedItems = <Object>[];
                for (int i = 0; i < txns.length; i++) {
                  final txn = txns[i];
                  bool showHeader = false;
                  if (i == 0) {
                    showHeader = true;
                  } else {
                    final prevTxn = txns[i - 1];
                    if (!_isSameDay(txn.date, prevTxn.date)) {
                      showHeader = true;
                    }
                  }

                  if (showHeader) {
                    groupedItems.add(txn.date);
                  }
                  groupedItems.add(txn);
                }

                return ListView.separated(
                  itemCount: groupedItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 0),
                  itemBuilder: (context, index) {
                    final item = groupedItems[index];
                    if (item is DateTime) {
                      return _DateHeader(date: item);
                    } else if (item is TransactionModel) {
                      return TransactionTile(
                        txn: item,
                        onChanged: _load,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          )
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_hasTransactions) ...[
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    Text(
                      'Start adding transactions with ${widget.party.name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const _BouncingArrow(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _addTransaction(TransactionType.gave),
                    child: const Text(
                      'YOU GAVE ₹',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _addTransaction(TransactionType.got),
                    child: const Text(
                      'YOU GOT ₹',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    String suffix = '';
    if (checkDate == today) {
      suffix = ' • Today';
    } else if (checkDate == yesterday) {
      suffix = ' • Yesterday';
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Text(
          DateFormat('dd MMM yy').format(date) + suffix,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class _BouncingArrow extends StatefulWidget {
  const _BouncingArrow({Key? key}) : super(key: key);

  @override
  State<_BouncingArrow> createState() => _BouncingArrowState();
}

class _BouncingArrowState extends State<_BouncingArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: const Icon(
        Icons.arrow_downward,
        size: 32,
        color: Colors.blue,
      ),
    );
  }
}
