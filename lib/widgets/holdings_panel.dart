// lib/widgets/holdings_panel.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/holding.dart';
import '../theme.dart';

class HoldingsPanel extends StatefulWidget {
  final List<Holding> holdings;
  final void Function(Holding) onAdd;
  final void Function(int) onRemove;
  final VoidCallback onAnalyze;
  final bool loading;

  const HoldingsPanel({
    super.key,
    required this.holdings,
    required this.onAdd,
    required this.onRemove,
    required this.onAnalyze,
    required this.loading,
  });

  @override
  State<HoldingsPanel> createState() => _HoldingsPanelState();
}

class _HoldingsPanelState extends State<HoldingsPanel> {
  final _tickerCtrl = TextEditingController();
  final _sharesCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  void _add() {
    final ticker = _tickerCtrl.text.trim().toUpperCase();
    final shares = double.tryParse(_sharesCtrl.text);
    if (ticker.isEmpty || shares == null) return;
    widget.onAdd(Holding(
      ticker: ticker,
      shares: shares,
      avgPrice: double.tryParse(_priceCtrl.text) ?? 0,
    ));
    _tickerCtrl.clear();
    _sharesCtrl.clear();
    _priceCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(16),
        color: kSurface.withOpacity(0.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: kBorder)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOUR HOLDINGS',
                    style: TextStyle(fontSize: 10, color: kGold, letterSpacing: 2)),
                const SizedBox(height: 2),
                Text('${widget.holdings.length} position${widget.holdings.length != 1 ? 's' : ''}',
                    style: TextStyle(fontSize: 12, color: kMuted)),
              ],
            ),
          ),

          // Holdings list
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: widget.holdings.length,
              itemBuilder: (ctx, i) {
                final h = widget.holdings[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: kGold.withOpacity(0.04),
                    border: Border.all(color: kGold.withOpacity(0.15)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.ticker,
                                style: GoogleFonts.dmMono(
                                    fontSize: 14, fontWeight: FontWeight.w700, color: kGold)),
                            const SizedBox(height: 2),
                            Text('${h.shares} shares · \$${h.avgPrice > 0 ? h.avgPrice.toStringAsFixed(0) : '—'}',
                                style: TextStyle(fontSize: 11, color: kMuted)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => widget.onRemove(i),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.close, color: Color(0xFF555555), size: 18),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Add inputs
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                const Divider(color: kBorder, height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _tickerCtrl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(hintText: 'TICKER'),
                        style: GoogleFonts.dmMono(fontSize: 13, color: kText),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _sharesCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Shares'),
                        style: const TextStyle(fontSize: 13, color: kText),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Avg \$'),
                        style: const TextStyle(fontSize: 13, color: kText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _add,
                    icon: const Icon(Icons.add, size: 16, color: kGold),
                    label: const Text('Add Position', style: TextStyle(color: kGold, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Analyze button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.loading || widget.holdings.isEmpty ? null : widget.onAnalyze,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGold,
                  disabledBackgroundColor: kGold.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: widget.loading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: kBg),
                      )
                    : Text(
                        '⚡  Analyze My Portfolio',
                        style: GoogleFonts.dmSans(
                          fontSize: 14, fontWeight: FontWeight.w700, color: kBg,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
