import 'package:flutter/material.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';
import 'package:my_order_pro/data/services/party_service.dart';

enum PartyType { customer, supplier }

class Party {
  final String id;
  final String name;
  final String phone;
  final PartyType type;
  final String? gstin;
  final double balance;

  Party({
    required this.id,
    required this.name,
    required this.phone,
    required this.type,
    this.gstin,
    this.balance = 0.0,
  });
}

String _capitalize(String s) {
  if (s.isEmpty) return s;
  return "${s[0].toUpperCase()}${s.substring(1).toLowerCase()}";
}

class PartiesScreen extends StatefulWidget {
  const PartiesScreen({super.key});

  @override
  State<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  PartyType _selectedFilter = PartyType.customer;

  // Real parties loaded from PartyService (Supabase-or-local), incl. auto-added from bills.
  List<Party> _parties = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadParties();
  }

  Future<void> _loadParties() async {
    if (mounted) setState(() => _loading = true);
    try {
      final rows = await PartyService().listParties();
      if (!mounted) return;
      setState(() {
        _parties = rows
            .map((r) => Party(
                  id: r['id']?.toString() ?? '',
                  name: (r['name'] ?? '').toString(),
                  phone: (r['phone'] ?? '').toString(),
                  type: (r['type']?.toString() == 'supplier') ? PartyType.supplier : PartyType.customer,
                  gstin: r['gstin']?.toString(),
                  balance: (r['balance'] as num?)?.toDouble() ?? 0.0,
                ))
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load parties. Pull down to refresh.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Party> get _filteredParties {
    return _parties.where((party) {
      final matchesType = party.type == _selectedFilter;
      final matchesSearch = party.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          party.phone.contains(_searchQuery);
      return matchesType && matchesSearch;
    }).toList();
  }

  void _showAddPartySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const _AddPartyForm(),
      ),
    ).then((newParty) async {
      if (newParty != null && newParty is Party) {
        await PartyService().addParty(
          name: newParty.name,
          phone: newParty.phone,
          type: newParty.type.name,
          gstin: newParty.gstin ?? '',
        );
        if (!mounted) return;
        await _loadParties();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newParty.name} added successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredParties;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Parties',
          style: robotoBold.copyWith(color: AppColors.textDark, fontSize: Dimensions.fontSizeLarge),
        ),
        backgroundColor: AppColors.card,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPartySheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: Text('Add Party', style: robotoMedium.copyWith(color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.fromLTRB(
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeSmall,
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeDefault,
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or phone...',
                    hintStyle: robotoRegular.copyWith(color: AppColors.textLight),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textLight),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: Dimensions.paddingSizeDefault),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<PartyType>(
                    segments: const [
                      ButtonSegment(
                        value: PartyType.customer,
                        label: Text('Customers'),
                        icon: Icon(Icons.group_outlined),
                      ),
                      ButtonSegment(
                        value: PartyType.supplier,
                        label: Text('Suppliers'),
                        icon: Icon(Icons.local_shipping_outlined),
                      ),
                    ],
                    selected: {_selectedFilter},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _selectedFilter = selection.first;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.primaryLight.withValues(alpha: 0.3);
                        }
                        return AppColors.card;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.primary;
                        }
                        return AppColors.textMedium;
                      }),
                      side: WidgetStateProperty.all(
                        BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_off_outlined,
                            size: 64,
                            color: AppColors.textLight.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          Text(
                            _searchQuery.isNotEmpty ? 'No results found' : 'No parties yet',
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Text(
                            _searchQuery.isNotEmpty
                                ? "We couldn't find any parties matching '$_searchQuery'."
                                : "Add your first ${_selectedFilter.name} to get started.",
                            textAlign: TextAlign.center,
                            style: robotoRegular.copyWith(color: AppColors.textMedium),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                          if (_searchQuery.isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear Search'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(
                                  color: AppColors.primary.withValues(alpha: 0.5),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                ),
                              ),
                            )
                          else
                            ElevatedButton.icon(
                              onPressed: _showAddPartySheet,
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: Text('Add ${_capitalize(_selectedFilter.name)}', style: const TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: Dimensions.paddingSizeSmall),
                    itemBuilder: (context, index) {
                      final party = filtered[index];
                      return _PartyCard(party: party);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PartyCard extends StatelessWidget {
  final Party party;

  const _PartyCard({required this.party});

  @override
  Widget build(BuildContext context) {
    final isReceivable = party.balance > 0;
    final isPayable = party.balance < 0;
    final balanceColor = isReceivable
        ? Colors.green
        : isPayable
            ? Colors.red
            : AppColors.textMedium;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to party details/ledger
          },
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryLight.withValues(alpha: 0.3),
                  foregroundColor: AppColors.primary,
                  radius: 24,
                  child: Text(
                    party.name.isNotEmpty ? party.name[0].toUpperCase() : '?',
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        party.name,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone_outlined, size: 14, color: AppColors.textMedium),
                          const SizedBox(width: 4),
                          Text(
                            party.phone,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                      if (party.gstin != null && party.gstin!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            'GST: ${party.gstin}',
                            style: robotoMedium.copyWith(
                              fontSize: 10,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${party.balance.abs().toStringAsFixed(2)}',
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: balanceColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isReceivable
                          ? 'To Collect'
                          : isPayable
                              ? 'To Pay'
                              : 'Settled',
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: balanceColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddPartyForm extends StatefulWidget {
  const _AddPartyForm();

  @override
  State<_AddPartyForm> createState() => _AddPartyFormState();
}

class _AddPartyFormState extends State<_AddPartyForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phone = '';
  String? _gstin;
  PartyType _type = PartyType.customer;
  double _balance = 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add New Party', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: AppColors.textDark)),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMedium),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Party Name *',
                labelStyle: robotoRegular.copyWith(color: AppColors.textMedium),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter party name' : null,
              onSaved: (v) => _name = v!.trim(),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                labelStyle: robotoRegular.copyWith(color: AppColors.textMedium),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter phone number' : null,
              onSaved: (v) => _phone = v!.trim(),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            DropdownButtonFormField<PartyType>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: 'Party Type',
                labelStyle: robotoRegular.copyWith(color: AppColors.textMedium),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                prefixIcon: const Icon(Icons.category_outlined),
              ),
              items: PartyType.values.map((t) => DropdownMenuItem(
                value: t,
                child: Text(_capitalize(t.name)),
              )).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _type = v);
                }
              },
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'GSTIN (Optional)',
                labelStyle: robotoRegular.copyWith(color: AppColors.textMedium),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                prefixIcon: const Icon(Icons.receipt_long_outlined),
              ),
              textCapitalization: TextCapitalization.characters,
              onSaved: (v) => _gstin = v?.trim(),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Opening Balance (₹)',
                labelStyle: robotoRegular.copyWith(color: AppColors.textMedium),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                helperText: 'Positive for receivable, negative for payable',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              onSaved: (v) => _balance = double.tryParse(v ?? '0') ?? 0.0,
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Navigator.pop(context, Party(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _name,
                    phone: _phone,
                    type: _type,
                    gstin: _gstin,
                    balance: _balance,
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
              ),
              child: Text('Save Party', style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],
        ),
      ),
    );
  }
}