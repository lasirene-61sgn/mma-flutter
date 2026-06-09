import 'package:flutter/material.dart';
import '../../../main.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MMPApp.cream,
      appBar: AppBar(
        title: const Text('About Mel Milaap Parivaar'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Logo Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: MMPApp.borderBrown,
                        width: 2,
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/mmp_logo.jpeg',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Mel Milaap Parivaar',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: MMPApp.maroon,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Established 2010',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Mission Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSection(
                icon: Icons.flag,
                title: 'Our Mission',
                content:
                    'To empower Mel Milaap Parivaar by fostering unity, developing leadership skills, and preserving our rich cultural heritage. We believe in passing the torch of knowledge and values from generation to generation.',
              ),
            ),
            const SizedBox(height: 16),
            // Vision Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSection(
                icon: Icons.visibility,
                title: 'Our Vision',
                content:
                    'To create a vibrant community of young Indians who are confident, culturally rooted, and ready to lead positive change in society.',
              ),
            ),
            const SizedBox(height: 16),
            // Values Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: MMPApp.maroon.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: MMPApp.maroon,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Our Values',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: MMPApp.maroon,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildValueItem(Icons.groups, 'Unity', 'Strength in togetherness'),
                    _buildValueItem(Icons.emoji_events, 'Leadership', 'Guiding the next generation'),
                    _buildValueItem(Icons.temple_hindu, 'Culture', 'Preserving our heritage'),
                    _buildValueItem(Icons.handshake, 'Service', 'Giving back to community'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Statistics
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [MMPApp.maroon, MMPApp.maroonLight],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('500+', 'Members'),
                    _buildDivider(),
                    _buildStat('50+', 'Events'),
                    _buildDivider(),
                    _buildStat('10+', 'Chapters'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: MMPApp.maroon.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: MMPApp.maroon,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MMPApp.maroon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: MMPApp.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white24,
    );
  }
}
