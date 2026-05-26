import 'package:flutter/material.dart';

void main() {
  runApp(const GSVSportsApp());
}

class GSVSportsApp extends StatelessWidget {
  const GSVSportsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GSV Sports',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1A237E), // Deep Blue (Corrected Hex)
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Dark Slate
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFB300), // Volleyball Amber
          secondary: Color(0xFF00B0FF), // Electric Blue
        ),
        useMaterial3: true,
      ),
      home: const VolleyballDashboard(),
    );
  }
}

class VolleyballDashboard extends StatelessWidget {
  const VolleyballDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GSV SPORTS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('LIVE MATCH'),
              const SizedBox(height: 10),
              _buildLiveMatchCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('QUICK ACTIONS'),
              const SizedBox(height: 10),
              _buildQuickActionsGrid(),
              const SizedBox(height: 24),
              _buildSectionTitle('UPCOMING FIXTURES'),
              const SizedBox(height: 10),
              _buildUpcomingMatchItem('GSV Titans', 'Spike Masters', 'May 26, 06:00 PM'),
              _buildUpcomingMatchItem('Thunder Volleys', 'GSV Knights', 'May 28, 04:30 PM'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: const Color(0xFFFFB300),
        unselectedItemColor: Colors.white60,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sports_volleyball), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Standings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // Section Title Helper
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold, // Corrected from Colors.bold
        letterSpacing: 1.2,
        color: Colors.white70,
      ),
    );
  }

  // Live Match Card Widget
  Widget _buildLiveMatchCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3), // Corrected from withOpacity
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Corrected from py: 4
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('LIVE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const Text('Set 3 - GSV Arena', style: TextStyle(color: Colors.white60, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTeamScore('GSV Warriors', '25', '2'),
              const Text('VS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFFB300))),
              _buildTeamScore('Strikers BC', '21', '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScore(String teamName, String currentPoints, String setsWon) {
    return Column(
      children: [
        const Icon(Icons.sports_volleyball, size: 40, color: Colors.white),
        const SizedBox(height: 8),
        Text(teamName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(currentPoints, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFFB300))),
        Text('Sets Won: $setsWon', style: const TextStyle(fontSize: 12, color: Colors.white60)),
      ],
    );
  }

  // Quick Actions Grid Widget
  Widget _buildQuickActionsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildActionCard(Icons.analytics, 'Stats Tracker'),
        _buildActionCard(Icons.group, 'Teams'),
        _buildActionCard(Icons.emoji_events, 'Tournaments'),
        _buildActionCard(Icons.video_library, 'Highlights'),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 16),
          Icon(icon, color: const Color(0xFFFFB300), size: 28),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // Upcoming Match List Item Widget
  Widget _buildUpcomingMatchItem(String team1, String team2, String dateTime) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$team1 vs $team2', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(dateTime, style: const TextStyle(color: Colors.white60, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
        ],
      ),
    );
  }
}