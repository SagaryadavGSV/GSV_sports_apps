import 'package:flutter/material.dart';
import 'football_page.dart';
import 'login_page.dart';
import 'handball_page.dart';

class HomePage extends StatefulWidget {
  final bool isAdmin;
  final String userEmail;

  const HomePage({
    super.key,
    required this.isAdmin,
    required this.userEmail,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060818),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _buildWelcomeBanner(),
                const SizedBox(height: 28),
                _buildSectionTitle('🏅  Select Your Sport'),
                const SizedBox(height: 16),
                _AnimatedCard(
                  delay: 0.0,
                  controller: _animController,
                  child: _SportCard(
                    name: 'Football',
                    subtitle: 'GSV Campus League · Season Active',
                    emoji: '⚽',
                    color1: const Color(0xFF11998E),
                    color2: const Color(0xFF38EF7D),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FootballPage(isAdmin: widget.isAdmin),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _AnimatedCard(
                  delay: 0.15,
                  controller: _animController,
                  child: _SportCard(
                    name: 'Handball',
                    subtitle: 'Inter-College Cup · Ongoing',
                    emoji: '🤾',
                    color1: const Color(0xFFE94560),
                    color2: const Color(0xFFFF6B35),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HandballPage(isAdmin: widget.isAdmin),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _buildStatsRow(),
                const SizedBox(height: 28),
                _buildUpcomingSection(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 72,
      pinned: true,
      backgroundColor: const Color(0xFF060818),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                    ),
                    border: Border.all(
                        color: const Color(0xFF42A5F5), width: 1.2),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'GSV',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'GSV Sports',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: _showLogoutDialog,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: widget.isAdmin
                          ? const Color(0xFFFFB300)
                          : const Color(0xFF1565C0),
                      child: Text(
                        widget.isAdmin ? 'A' : 'S',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.isAdmin ? 'Admin' : 'Student',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to sign out?',
            style:
                TextStyle(color: Colors.white.withValues(alpha: 0.6))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94560),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sign Out',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    final hour = DateTime.now().hour;
    final greeting =
        hour < 12 ? 'Morning' : hour < 17 ? 'Afternoon' : 'Evening';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1B3E), Color(0xFF112240)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFF42A5F5).withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good $greeting ${widget.isAdmin ? "Admin" : "Athlete"}! 🎯',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Gati Shakti Vishwavidyalaya\nSports Management Portal',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: const Color(0xFF42A5F5).withValues(alpha: 0.3)),
            ),
            child: const Text('🏆', style: TextStyle(fontSize: 30)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatCard(
            label: 'Teams',
            value: '4',
            icon: Icons.groups,
            color: const Color(0xFF11998E)),
        const SizedBox(width: 12),
        _StatCard(
            label: 'Live',
            value: '1',
            icon: Icons.live_tv,
            color: const Color(0xFFE94560)),
        const SizedBox(width: 12),
        _StatCard(
            label: 'This Week',
            value: '3',
            icon: Icons.event,
            color: const Color(0xFFFF6B35)),
      ],
    );
  }

  Widget _buildUpcomingSection() {
    final matches = [
      ['Football', 'Rajdhani Eagles vs Tejas Tigers', 'Today · 4:00 PM', const Color(0xFF11998E)],
      ['Football', 'Duronto Bulls vs Shatabdi Stallions', 'Tomorrow · 2:30 PM', const Color(0xFF1565C0)],
      ['Football', 'Semi Finals', 'Friday · 5:00 PM', const Color(0xFFFF6B35)],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('📅  Upcoming Matches'),
        const SizedBox(height: 12),
        ...matches.map((m) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 36,
                    decoration: BoxDecoration(
                      color: m[3] as Color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m[1] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          m[2] as String,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (m[3] as Color).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      m[0] as String,
                      style: TextStyle(
                        color: m[3] as Color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

// ── Supporting Widgets ───────────────────────────────────────────────────────

class _AnimatedCard extends StatelessWidget {
  final double delay;
  final AnimationController controller;
  final Widget child;

  const _AnimatedCard({
    required this.delay,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(delay, delay + 0.5, curve: Curves.easeOut),
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (_, c) => Opacity(
        opacity: animation.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 30 * (1 - animation.value)),
          child: c,
        ),
      ),
      child: child,
    );
  }
}

class _SportCard extends StatefulWidget {
  final String name;
  final String subtitle;
  final String emoji;
  final Color color1;
  final Color color2;
  final VoidCallback onTap;

  const _SportCard({
    required this.name,
    required this.subtitle,
    required this.emoji,
    required this.color1,
    required this.color2,
    required this.onTap,
  });

  @override
  State<_SportCard> createState() => _SportCardState();
}

class _SportCardState extends State<_SportCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.color1, widget.color2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.color1.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -10,
                child: Text(widget.emoji,
                    style: const TextStyle(fontSize: 90)),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.name == 'Football'
                            ? Icons.sports_soccer
                            : Icons.sports_handball,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 18,
                bottom: 18,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward,
                      color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
