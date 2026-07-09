import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  String _cacheText = 'Used: 1.2 GB (Optimized)';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth < 600;
    final horizontalPadding = isPhone ? 16.0 : (screenWidth < 900 ? 20.0 : 24.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0x991A1C22),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC2C6D6)),
          onPressed: () {},
        ),
        title: const Text(
          'Settings',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility, color: Color(0xFF528DFF)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserProfile(context, isPhone),
                    const SizedBox(height: 24),

                    // Preferences Section
                    _buildSectionHeader('PREFERENCES'),
                    const SizedBox(height: 8),
                    _buildSettingsRow(
                      icon: Icons.palette,
                      iconColor: const Color(0xFFD6BAFF),
                      title: 'Appearance',
                      subtitle: 'Dark mode (Glassmorphism enabled)',
                      trailing: const Icon(Icons.chevron_right, color: Color(0xFFC2C6D6)),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsSwitchRow(
                      icon: Icons.notifications,
                      iconColor: const Color(0xFFFFB77D),
                      title: 'Notification settings',
                      subtitle: 'In-app, Email, Model Completion',
                    ),
                    const SizedBox(height: 24),

                    // Data & Storage
                    _buildSectionHeader('DATA & STORAGE'),
                    const SizedBox(height: 8),
                    _buildSettingsRow(
                      icon: Icons.cleaning_services,
                      iconColor: const Color(0xFFFFB4AB),
                      title: 'Clear cache',
                      subtitle: _cacheText,
                      trailing: const Icon(Icons.delete_sweep, color: Color(0xFFC2C6D6)),
                      onTap: _showClearCacheDialog,
                    ),
                    const SizedBox(height: 24),

                    // Resources
                    _buildSectionHeader('RESOURCES'),
                    const SizedBox(height: 8),
                    _buildSettingsRow(
                      icon: Icons.menu_book,
                      iconColor: const Color(0xFF528DFF),
                      title: 'Documentation',
                      subtitle: 'API References & Lab Tutorials',
                      trailing: const Icon(Icons.open_in_new, color: Color(0xFFC2C6D6), size: 16),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsRow(
                      icon: Icons.info,
                      iconColor: const Color(0xFFC2C6D6),
                      title: 'About AI Vision Lab',
                      subtitle: 'Version 2.4.0-Stable',
                      trailing: const Icon(Icons.chevron_right, color: Color(0xFFC2C6D6)),
                    ),
                    const SizedBox(height: 32),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFFB4AB),
                          side: const BorderSide(color: Colors.white10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {},
                        child: Text(
                          isPhone ? 'LOGOUT' : 'LOGOUT SESSION',
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Center(
                      child: Text(
                        'DESIGNED FOR UNIVERSITY RESEARCH DIVISION',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: isPhone ? 8 : 9,
                          color: Colors.white24,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'JetBrains Mono',
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Color(0xFF528DFF),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, bool isPhone) {
    final avatarSize = isPhone ? 56.0 : 72.0;

    if (isPhone) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1C22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF528DFF).withOpacity(0.3), width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: CircleAvatar(
                      backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=200'),
                      radius: avatarSize / 2 - 3,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF34D399),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF1A1C22), width: 2.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                const Text(
                  'Alex Chen',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE2E2E8)),
                ),
                const Text(
                  'Senior Vision Researcher',
                  style: TextStyle(fontSize: 12, color: Color(0xFFC2C6D6)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF528DFF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PRO ACCOUNT',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF528DFF),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFFC2C6D6), size: 20),
                onPressed: () {},
              ),
            ),
          ],
        ),
      );
    }

    // Desktop / Tablet layout
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF528DFF).withOpacity(0.3), width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: CircleAvatar(
                    backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=200'),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF34D399),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1A1C22), width: 2.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alex Chen',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE2E2E8)),
                ),
                const Text(
                  'Senior Vision Researcher',
                  style: TextStyle(fontSize: 12, color: Color(0xFFC2C6D6)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF528DFF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PRO ACCOUNT',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF528DFF),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFFC2C6D6), size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1C22).withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Color(0xFFC2C6D6)),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSwitchRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C22).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Color(0xFFC2C6D6)),
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            activeColor: const Color(0xFF528DFF),
            onChanged: (val) {
              setState(() {
                _notificationsEnabled = val;
              });
            },
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1C22),
          title: const Text('Clear Cache'),
          content: const Text('Are you sure you want to clear laboratory cache? This will reset local model weights.'),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Color(0xFFC2C6D6))),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Clear', style: TextStyle(color: Color(0xFFFFB4AB))),
              onPressed: () {
                setState(() {
                  _cacheText = 'Used: 0 KB (Clean)';
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}