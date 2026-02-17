import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/state/auth_controller.dart';
import '../../profiles/state/profiles_controller.dart';
import '../../../core/utils/app_snackbar.dart';
import 'widgets/avatar_viewer.dart';

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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await ref.read(authControllerProvider.notifier).logout();
      // ignore: use_build_context_synchronously
      AppSnackBar.show(context, "Logged out successful! See you later!👋", type: SnackType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.asData?.value;
    final profileState = ref.watch(profilesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: profileState.when(
          data: (profile) {
            final nickname = profile?.nickname.isNotEmpty == true
                ? "@${profile!.nickname}'s Profile"
                : "@ronin";
            return Text(nickname);
          },
          loading: () => const Text("Loading..."),
          error: (e, st) => const Text("Profile"),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: user == null
          ? const Center(child: Text("Not logged in"))
          : profileState.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Failed to load profile",
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(profilesControllerProvider);
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
              data: (profile) {
                // Safe defaults
                final fullName = profile?.fullName.isNotEmpty == true
                    ? profile!.fullName
                    : (user.email ?? "Unknown");

                final nickname = profile?.nickname.isNotEmpty == true
                    ? "@${profile!.nickname}"
                    : "@ronin";

                final bio = profile?.bio.isNotEmpty == true
                    ? profile!.bio
                    : "This ronin has not set up a bio yet. They are a mysterious warrior of the digital realm...";

                final avatarUrl = profile?.avatarUrl;
                final fallbackLetter =
                    (user.email != null && user.email!.isNotEmpty)
                        ? user.email!.substring(0, 1).toUpperCase()
                        : 'U';

                return Column(
                  children: [
                    // Banner + Avatar
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
                        Positioned(
                          bottom: -55,
                          left: 20,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder: (context, animation, secondaryAnimation) => AvatarViewer(
                                    imageUrl: avatarUrl,
                                    fullName: fullName,
                                    nickname: nickname,
                                    fallbackLetter: fallbackLetter,
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: "profileAvatar",
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.black,
                                child: CircleAvatar(
                                  radius: 52,
                                  backgroundColor: Colors.grey,
                                  backgroundImage:
                                      avatarUrl != null && avatarUrl.isNotEmpty
                                          ? NetworkImage(avatarUrl)
                                          : null,
                                  child: (avatarUrl == null || avatarUrl.isEmpty)
                                      ? Text(
                                          fallbackLetter,
                                          style: const TextStyle(
                                            fontSize: 42,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 70),

                    // User Info
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nickname,
                            style: const TextStyle(
                                color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            bio,
                            style: const TextStyle(
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                            children: const [
                              _StatItem(
                                  label: "Followers",
                                  value: "-"),
                              _StatItem(
                                  label: "Following",
                                  value: "-"),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton
                                      .styleFrom(
                                    side: const BorderSide(
                                        color: Colors.black),
                                    shape:
                                        const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.zero,
                                    ),
                                  ),
                                  onPressed: () => Navigator.pushNamed(context, '/update_profile_screen'),
                                  child: const Text(
                                    "Edit Profile",
                                    style: TextStyle(
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton
                                      .styleFrom(
                                    side: const BorderSide(
                                        color: Colors.grey),
                                    shape:
                                        const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.zero,
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Text(
                                    "Message",
                                    style: TextStyle(
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.black,
                      tabs: const [
                        Tab(text: "Posts"),
                        Tab(text: "Activity"),
                      ],
                    ),

                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPosts(),
                          _buildActivity(),
                        ],
                      ),
                    ),
                  ],
                );
              },
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
          decoration:
              BoxDecoration(border: Border.all(color: Colors.black)),
          child: Text(
            "Training session log #$index",
            style: const TextStyle(color: Colors.black),
          ),
        );
      },
    );
  }

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
          style:
              const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
