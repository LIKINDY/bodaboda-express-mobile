import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_copy.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

enum EarningsPeriod { today, week, month }

class _EarningsScreenState extends State<EarningsScreen> {
  EarningsPeriod _selectedPeriod = EarningsPeriod.week;
  int? _selectedBarIndex;

  // Mock data for each period
  final Map<EarningsPeriod, Map<String, dynamic>> _earningsData = {
    EarningsPeriod.today: {
      'total': 'TZS 48,500',
      'growth': '+12.4%',
      'trips': '14',
      'hours': '6.8 hrs',
      'avgPerTrip': 'TZS 3,460',
      'acceptanceRate': '94%',
      'gross': 'TZS 53,800',
      'tips': 'TZS 4,500',
      'bonus': 'TZS 2,000',
      'fees': '-TZS 11,800',
      'chartLabels': ['08:00', '10:00', '12:00', '14:00', '16:00', '18:00', '20:00'],
      'chartValues': [4500, 7500, 11000, 6000, 9500, 13000, 7000],
      'tripsList': [
        {
          'id': 'TRP-1098',
          'passenger': 'Hamisi Bakari',
          'route': 'Kariakoo Sokoni ➔ Posta Mpya',
          'time': '19:42',
          'amount': 'TZS 4,500',
          'payment': 'M-Pesa',
          'status': 'Imekamilika',
        },
        {
          'id': 'TRP-1097',
          'passenger': 'Fatma Rashid',
          'route': 'Kinondoni Mkwajuni ➔ Morocco',
          'time': '18:15',
          'amount': 'TZS 3,500',
          'payment': 'Cash',
          'status': 'Imekamilika',
        },
        {
          'id': 'TRP-1096',
          'passenger': 'Daudi Mussa',
          'route': 'Mwenge TRA ➔ Sinza Mori',
          'time': '16:30',
          'amount': 'TZS 5,000',
          'payment': 'Tigo Pesa',
          'status': 'Imekamilika',
        },
        {
          'id': 'TRP-1095',
          'passenger': 'Amina Salum',
          'route': 'Ubungo Maji ➔ Shekilango',
          'time': '14:10',
          'amount': 'TZS 3,000',
          'payment': 'M-Pesa',
          'status': 'Imekamilika',
        },
      ],
    },
    EarningsPeriod.week: {
      'total': 'TZS 294,000',
      'growth': '+18.2%',
      'trips': '86',
      'hours': '41.5 hrs',
      'avgPerTrip': 'TZS 3,420',
      'acceptanceRate': '96%',
      'gross': 'TZS 326,500',
      'tips': 'TZS 18,500',
      'bonus': 'TZS 15,000',
      'fees': '-TZS 66,000',
      'chartLabels': ['Jtt', 'Jnn', 'Tnn', 'Alh', 'Ijm', 'Jms', 'Jpl'],
      'chartValues': [34000, 42000, 39000, 46000, 52000, 48500, 32500],
      'tripsList': [
        {
          'id': 'TRP-1094',
          'passenger': 'Grace Mallya',
          'route': 'Oysterbay ➔ Masaki Peninsula',
          'time': 'Jana, 17:20',
          'amount': 'TZS 6,500',
          'payment': 'Airtel Money',
          'status': 'Imekamilika',
        },
        {
          'id': 'TRP-1093',
          'passenger': 'Baraka John',
          'route': 'Magomeni Mapipa ➔ City Mall',
          'time': 'Jana, 15:45',
          'amount': 'TZS 4,000',
          'payment': 'M-Pesa',
          'status': 'Imekamilika',
        },
        {
          'id': 'TRP-1092',
          'passenger': 'Kelvin Shayo',
          'route': 'Mlimani City ➔ Kijitonyama',
          'time': 'Juzi, 12:10',
          'amount': 'TZS 4,500',
          'payment': 'Cash',
          'status': 'Imekamilika',
        },
      ],
    },
    EarningsPeriod.month: {
      'total': 'TZS 1,245,000',
      'growth': '+24.5%',
      'trips': '362',
      'hours': '168 hrs',
      'avgPerTrip': 'TZS 3,440',
      'acceptanceRate': '95%',
      'gross': 'TZS 1,380,000',
      'tips': 'TZS 72,000',
      'bonus': 'TZS 65,000',
      'fees': '-TZS 272,000',
      'chartLabels': ['Wiki 1', 'Wiki 2', 'Wiki 3', 'Wiki 4'],
      'chartValues': [285000, 310000, 356000, 294000],
      'tripsList': [
        {
          'id': 'TRP-1080',
          'passenger': 'Emanuel Temba',
          'route': 'Tabata Relini ➔ Kisutu',
          'time': 'Okt 04, 11:30',
          'amount': 'TZS 5,500',
          'payment': 'M-Pesa',
          'status': 'Imekamilika',
        },
        {
          'id': 'TRP-1072',
          'passenger': 'Zuhura Ali',
          'route': 'Tegeta Nyuki ➔ Mwenge Bus Stand',
          'time': 'Okt 01, 09:20',
          'amount': 'TZS 7,500',
          'payment': 'Tigo Pesa',
          'status': 'Imekamilika',
        },
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentData = _earningsData[_selectedPeriod]!;
    final List<int> values = List<int>.from(currentData['chartValues']);
    final List<String> labels = List<String>.from(currentData['chartLabels']);
    final int maxValue = values.reduce((curr, next) => curr > next ? curr : next);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          appCopy(context, 'Earnings & Reports', 'Mapato na Takwimu'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            tooltip: appCopy(context, 'Wallet', 'Pochi'),
            onPressed: () => context.push('/fuel-wallet'),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: appCopy(context, 'Tariff details', 'Maelezo ya ushuru'),
            onPressed: () => _showFeeInfoDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector Tabs
            _buildPeriodSelector(context),
            const SizedBox(height: 16),

            // Hero Earnings Card
            _buildHeroEarningsCard(context, currentData, isDark),
            const SizedBox(height: 20),

            // Metrics Grid
            _buildMetricsGrid(context, currentData, isDark),
            const SizedBox(height: 24),

            // Chart Section
            _buildChartSection(context, currentData, labels, values, maxValue, isDark),
            const SizedBox(height: 24),

            // Financial Breakdown Card
            _buildFinancialBreakdownCard(context, currentData, isDark),
            const SizedBox(height: 24),

            // Recent Trips List
            _buildTripsListSection(context, currentData, isDark),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildPeriodTab(EarningsPeriod.today, appCopy(context, 'Today', 'Leo')),
          _buildPeriodTab(EarningsPeriod.week, appCopy(context, 'This Week', 'Wiki Hii')),
          _buildPeriodTab(EarningsPeriod.month, appCopy(context, 'This Month', 'Mwezi Huu')),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(EarningsPeriod period, String title) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
            _selectedBarIndex = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroEarningsCard(BuildContext context, Map<String, dynamic> data, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF132247), const Color(0xFF0F1B38)]
              : [const Color(0xFF0A2E80), const Color(0xFF1845A8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(isDark ? 0.3 : 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background graphic elements
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.trending_up,
              size: 150,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appCopy(context, 'Net Total Earnings', 'Jumla ya Mapato Halisi'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.ecoGreen.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.ecoGreen.withOpacity(0.6)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_upward, color: Colors.greenAccent, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            data['growth'],
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  data['total'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appCopy(
                    context,
                    'Available for withdrawal immediately',
                    'Inapatikana kutoa muda wowote',
                  ),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showWithdrawModal(context, data['total']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.payments_outlined, size: 18),
                        label: Text(
                          appCopy(context, 'Cash Out (Withdraw)', 'Toa Pesa Haraka'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.local_gas_station, color: Colors.white),
                        tooltip: appCopy(context, 'Fuel Top-up', 'Hamisha kwa Mafuta'),
                        onPressed: () => context.push('/fuel-wallet'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, Map<String, dynamic> data, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appCopy(context, 'Key Performance', 'Vipimo vya Utendaji'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                title: appCopy(context, 'Trips Completed', 'Safari Zilizofanyika'),
                value: data['trips'],
                icon: Icons.two_wheeler,
                color: const Color(0xFF2196F3),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                title: appCopy(context, 'Time Online', 'Muda Mtandaoni'),
                value: data['hours'],
                icon: Icons.access_time_filled,
                color: const Color(0xFFFF9800),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                title: appCopy(context, 'Avg. per Trip', 'Wastani / Safari'),
                value: data['avgPerTrip'],
                icon: Icons.analytics_outlined,
                color: const Color(0xFF9C27B0),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                title: appCopy(context, 'Acceptance Rate', 'Kiwango cha Kukubali'),
                value: data['acceptanceRate'],
                icon: Icons.thumb_up_alt_rounded,
                color: AppTheme.ecoGreen,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C3E) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(
    BuildContext context,
    Map<String, dynamic> data,
    List<String> labels,
    List<int> values,
    int maxValue,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C3E) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appCopy(context, 'Income Graph', 'Grafu ya Mapato'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedBarIndex != null
                        ? '${labels[_selectedBarIndex!]}: TZS ${values[_selectedBarIndex!]}'
                        : appCopy(context, 'Tap on a bar to inspect', 'Bonyeza nguzo kuona kiwango'),
                    style: TextStyle(
                      fontSize: 12,
                      color: _selectedBarIndex != null
                          ? AppTheme.primaryBlue
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: _selectedBarIndex != null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appCopy(context, 'TZS (Shilingi)', 'TZS (Shilingi)'),
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Custom Interactive Bar Chart
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(values.length, (index) {
                final double heightRatio = maxValue > 0 ? (values[index] / maxValue) : 0;
                final bool isSelected = _selectedBarIndex == index;
                final bool isPeak = values[index] == maxValue;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBarIndex = (_selectedBarIndex == index) ? null : index;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Value indicator when selected
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${(values[index] / 1000).toStringAsFixed(1)}k',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else if (isPeak)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: const Icon(Icons.star, color: Colors.amber, size: 12),
                        )
                      else
                        const SizedBox(height: 18),

                      // Animated Bar
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: values.length > 5 ? 24 : 36,
                        height: (120 * heightRatio).clamp(12.0, 120.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: isSelected
                                ? [AppTheme.primaryBlue, const Color(0xFF2979FF)]
                                : isPeak
                                    ? [const Color(0xFF0D47A1), const Color(0xFF42A5F5)]
                                    : isDark
                                        ? [const Color(0xFF2A2A40), const Color(0xFF3F3F60)]
                                        : [const Color(0xFFD1D5DB), const Color(0xFF9CA3AF)],
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primaryBlue.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Label
                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialBreakdownCard(BuildContext context, Map<String, dynamic> data, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C3E) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: AppTheme.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                appCopy(context, 'Income Statement & Fees', 'Mchanganuo wa Mapato na Makato'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBreakdownRow(
            context,
            title: appCopy(context, 'Gross Trip Fares', 'Jumla ya Nauli za Safari'),
            amount: data['gross'],
            isPositive: null,
          ),
          const Divider(height: 18),
          _buildBreakdownRow(
            context,
            title: appCopy(context, 'Passenger Tips', 'Vidokezo vya Abiria (Tips)'),
            amount: '+${data['tips']}',
            isPositive: true,
          ),
          const Divider(height: 18),
          _buildBreakdownRow(
            context,
            title: appCopy(context, 'Weekly Drive Bonus', 'Bonasi za Utendaji'),
            amount: '+${data['bonus']}',
            isPositive: true,
          ),
          const Divider(height: 18),
          _buildBreakdownRow(
            context,
            title: appCopy(context, 'Platform Fee (15%)', 'Gharama ya Mfumo (15%)'),
            amount: data['fees'],
            isPositive: false,
          ),
          const Divider(height: 22, thickness: 1.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appCopy(context, 'Net Payout', 'Kiasi Halisi cha Kulipwa'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                data['total'],
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppTheme.ecoGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    BuildContext context, {
    required String title,
    required String amount,
    required bool? isPositive,
  }) {
    Color color;
    if (isPositive == true) {
      color = AppTheme.ecoGreen;
    } else if (isPositive == false) {
      color = AppTheme.accentRed;
    } else {
      color = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textDark;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTripsListSection(BuildContext context, Map<String, dynamic> data, bool isDark) {
    final List<Map<String, dynamic>> trips = List<Map<String, dynamic>>.from(data['tripsList']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              appCopy(context, 'Recent Trip Receipts', 'Stakabadhi za Safari za Hivi Karibuni'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.pushNamed('history'),
              child: Text(
                appCopy(context, 'View All', 'Ona Zote'),
                style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trips.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final trip = trips[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF2C2C3E) : const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppTheme.primaryBlue.withOpacity(0.12),
                            child: const Icon(Icons.person, size: 16, color: AppTheme.primaryBlue),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            trip['passenger'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      Text(
                        trip['amount'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: AppTheme.ecoGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.alt_route, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          trip['route'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getPaymentBadgeColor(trip['payment']).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              trip['payment'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getPaymentBadgeColor(trip['payment']),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            trip['time'],
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.ecoGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          trip['status'],
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.ecoGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getPaymentBadgeColor(String payment) {
    switch (payment) {
      case 'M-Pesa':
        return Colors.red;
      case 'Tigo Pesa':
        return Colors.blue;
      case 'Airtel Money':
        return Colors.deepOrange;
      default:
        return Colors.green;
    }
  }

  void _showWithdrawModal(BuildContext context, String currentBalance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WithdrawBottomSheet(currentBalance: currentBalance),
    );
  }

  void _showFeeInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appCopy(context, 'Pricing & Commission Policy', 'Sera ya Bei na Makato')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appCopy(
                context,
                '• Platform Commission: 15% on completed trips\n'
                '• Free Daily Instant Withdrawals to M-Pesa & Tigo Pesa\n'
                '• Fuel Wallet Card transfers are 100% free of charge with zero deductions\n'
                '• Peak hour bonuses and trip milestones are paid out every Sunday night.',
                '• Makato ya Mfumo: 15% kwa kila safari iliyokamilika\n'
                '• Kutoa bure mara moja kila siku kwenda M-Pesa na Tigo Pesa\n'
                '• Uhamisho kwenda Kadi ya Mafuta hauna makato yoyote (0% makato)\n'
                '• Bonasi za muda wa msongamano na malengo ya safari hulipwa kila Jumapili usiku.',
              ),
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appCopy(context, 'Understood', 'Nimeelewa')),
          ),
        ],
      ),
    );
  }
}

class _WithdrawBottomSheet extends StatefulWidget {
  final String currentBalance;
  const _WithdrawBottomSheet({required this.currentBalance});

  @override
  State<_WithdrawBottomSheet> createState() => _WithdrawBottomSheetState();
}

class _WithdrawBottomSheetState extends State<_WithdrawBottomSheet> {
  String _selectedMethod = 'M-Pesa';
  final TextEditingController _amountController = TextEditingController(text: '30000');

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            appCopy(context, 'Instant Payout / Cashout', 'Toa Pesa Papo Hapo'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${appCopy(context, 'Available to withdraw', 'Inayopatikana kutoa')}: ${widget.currentBalance}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Payment Methods
          Text(
            appCopy(context, 'Choose Destination Account', 'Chagua Njia ya Kupokelea'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildMethodChip('M-Pesa', Icons.phone_android, Colors.red),
              const SizedBox(width: 8),
              _buildMethodChip('Tigo Pesa', Icons.phone_android, Colors.blue),
              const SizedBox(width: 8),
              _buildMethodChip('Airtel', Icons.phone_android, Colors.deepOrange),
              const SizedBox(width: 8),
              _buildMethodChip('Fuel Card', Icons.local_gas_station, AppTheme.ecoGreen),
            ],
          ),
          const SizedBox(height: 20),

          // Amount field
          Text(
            appCopy(context, 'Withdraw Amount (TZS)', 'Kiasi cha Kutoa (TZS)'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: 'TZS ',
              prefixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final amt = _amountController.text.trim();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.ecoGreen,
                    content: Text(
                      appCopy(
                        context,
                        'Withdrawal of TZS $amt to $_selectedMethod initiated successfully!',
                        'Utoaji wa TZS $amt kwenda $_selectedMethod umeanza kikamilifu!',
                      ),
                    ),
                  ),
                );
              },
              child: Text(
                appCopy(context, 'Confirm Cash Out', 'Thibitisha Kutoa Pesa'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodChip(String name, IconData icon, Color color) {
    final isSelected = _selectedMethod == name;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = name),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.3),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey, size: 20),
              const SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
