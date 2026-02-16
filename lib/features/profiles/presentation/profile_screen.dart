import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/state/auth_controller.dart';
import '../../../shared/widgets/nav_user_menu.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User\'s Profile'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: NavUserMenu(),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: user == null
          ? const Center(child: Text("Not logged in"))
          : Column(
              children: [
                // banner + avatar
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Text(
                          "MODERN SAMURAI",
                          style: TextStyle(
                            color: Colors.black26,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),

                    // avatar
                    Positioned(
                      bottom: -55,
                      left: 20,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.black,
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor: Colors.grey,
                          child: Text(
                            user.email != null && user.email!.isNotEmpty
                                ? user.email!.substring(0, 1).toUpperCase()
                                : "U",
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 70),

                // user info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.email ?? "Unknown",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "@ronin",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Disciplined. Focused. Building the digital dojo.",
                        style: TextStyle(color: Colors.black87),
                      ),

                      const SizedBox(height: 20),

                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          _StatItem(label: "Followers", value: "-"),
                          _StatItem(label: "Following", value: "-"),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.black),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              onPressed: () {},
                              child: const Text(
                                "Edit Profile",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              onPressed: () {},
                              child: const Text(
                                "Message",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // tabs
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                  tabs: const [
                    Tab(text: "Posts"),
                    // Tab(text: "About"),
                    Tab(text: "Activity"),
                  ],
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPosts(),
                      // _buildAbout(),
                      _buildActivity(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPosts() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
          child: Text(
            "Training session log #$index",
            style: const TextStyle(color: Colors.black),
          ),
        );
      },
    );
  }

  // Widget _buildAbout() {
  //   return const Center(
  //     child: Text(
  //       "About the Ronin...",
  //       style: TextStyle(color: Colors.black),
  //     ),
  //   );
  // }

  Widget _buildActivity() {
    return const Center(
      child: Text(
        "Recent Activity...",
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
