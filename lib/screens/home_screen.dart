// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/holding.dart';
import '../services/portfolio_service.dart';
import '../theme.dart';
import '../widgets/holdings_panel.dart';
import '../widgets/overview_tab.dart';
import '../widgets/insights_tab.dart';
import '../widgets/charts_tab.dart';

const _samplePortfolio = [
  {'ticker': 'AAPL', 'shares': 10.0, 'avgPrice': 150.0},
  {'ticker': 'TSLA', 'shares': 5.0, 'avgPrice': 200.0},
  {'ticker': 'NVDA', 'shares': 8.0, 'avgPrice': 400.0},
  {'ticker': 'SPY', 'shares': 3.0, 'avgPrice': 450.0},
  {'ticker': 'AMZN', 'shares': 4.0, 'avgPrice': 180.0},
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late List<Holding> _holdings;
  List<Holding>? _enriched;
  PortfolioAnalysis? _analysis;
  bool _loading = false;
  String? _error;
  int _tab = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _holdings = _samplePortfolio
        .map((m) => Holding(
              ticker: m['ticker'] as String,
              shares: m['shares'] as double,
              avgPrice: m['avgPrice'] as double,
            ))
        .toList();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() => _tab = _tabController.index));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    setState(() { _loading = true; _error = null; });
    try {
      final enriched = PortfolioService.enrichHoldings(_holdings);
      final analysis = await PortfolioService.analyzeWithClaude(enriched);
      setState(() {
        _enriched = enriched;
        _analysis = analysis;
        _loading = false;
      });
      _tabController.animateTo(0);
    } catch (e) {
      setState(() { _loading = false; _error = 'Analysis failed. Check connection.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: kBorder)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          colors: [kGold, kGoldDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(child: Text('📈', style: TextStyle(fontSize: 16))),
                    ),
                    const SizedBox(width: 10),
                    Text('PortfolioIQ',
                        style: GoogleFonts.playfairDisplay(fontSize: 22, color: kGold)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF333333)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('BETA',
                          style: TextStyle(fontSize: 9, color: kMuted, letterSpacing: 1)),
                    ),
                    const Spacer(),
                    Text(
                      _dateString(),
                      style: TextStyle(fontSize: 11, color: kMuted, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero text
                    Text('The house always wins.',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 28, color: Colors.white, height: 1.2)),
                    Text('Until you know your edge.',
                        style: GoogleFonts.playfairDisplay(fontSize: 28, color: kGold, height: 1.2)),
                    const SizedBox(height: 10),
                    Text(
                      'Enter your holdings, get an AI-powered risk grade,\ndiversification score, and 3 moves to sharpen your portfolio.',
                      style: TextStyle(fontSize: 13, color: kMuted, height: 1.5),
                    ),

                    const SizedBox(height: 24),

                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 320,
                            child: _buildLeftPanel(),
                          ),
                          const SizedBox(width: 24),
                          Expanded(child: _buildRightPanel()),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildLeftPanel(),
                          const SizedBox(height: 20),
                          _buildRightPanel(),
                        ],
                      ),

                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(_error!,
                            style: const TextStyle(color: kRed, fontSize: 12)),
                      ),

                    const SizedBox(height: 32),
                    const Divider(color: kBorder),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('PortfolioIQ',
                            style: GoogleFonts.playfairDisplay(fontSize: 16, color: kGold)),
                        const Text('For informational purposes only. Not financial advice.',
                            style: TextStyle(fontSize: 10, color: Color(0xFF555555))),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftPanel() {
    return HoldingsPanel(
      holdings: _holdings,
      onAdd: (h) => setState(() => _holdings.add(h)),
      onRemove: (i) => setState(() => _holdings.removeAt(i)),
      onAnalyze: _analyze,
      loading: _loading,
    );
  }

  Widget _buildRightPanel() {
    if (_loading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 60),
        decoration: BoxDecoration(
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: kGold, strokeWidth: 2),
            const SizedBox(height: 16),
            Text('Claude is reading your portfolio…',
                style: TextStyle(color: kGold, fontSize: 14)),
            const SizedBox(height: 4),
            Text('Calculating risk, diversification & moves',
                style: TextStyle(color: kMuted, fontSize: 12)),
          ],
        ),
      );
    }

    if (_analysis == null || _enriched == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
        decoration: BoxDecoration(
          border: Border.all(color: kBorder, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(16),
          color: kGold.withOpacity(0.02),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎰', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('Ready to see your edge?',
                style: GoogleFonts.playfairDisplay(fontSize: 20, color: kGold)),
            const SizedBox(height: 8),
            Text(
              'Add your holdings and hit Analyze to get your AI-powered portfolio report card.',
              style: TextStyle(color: kMuted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Tab bar
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: kGold,
              borderRadius: BorderRadius.circular(7),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: kBg,
            unselectedLabelColor: kMuted,
            labelStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700),
            unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 13),
            tabs: const [Tab(text: 'Overview'), Tab(text: 'Insights'), Tab(text: 'Charts')],
          ),
        ),
        const SizedBox(height: 16),
        [
          OverviewTab(enriched: _enriched!, analysis: _analysis!),
          InsightsTab(analysis: _analysis!),
          ChartsTab(enriched: _enriched!),
        ][_tab],
      ],
    );
  }

  String _dateString() {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}
