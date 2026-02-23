import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/state/auth_controller.dart';
import '../../profiles/state/profiles_controller.dart';
import '../../../core/utils/app_snackbar.dart';
import 'widgets/avatar_viewer.dart';
import '../../../core/models/profile_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId; // null = current user, else public
  const ProfileScreen({super.key, this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // local state for public profile
  Profile? _publicProfile;
  bool _isLoadingPublic = false;
  String? _publicError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (widget.userId != null) {
      _fetchPublicProfile();
    }
  }

  Future<void> _fetchPublicProfile() async {
    setState(() {
      _isLoadingPublic = true;
      _publicError = null;
    });

    try {
      final profile = await ref
          .read(profilesControllerProvider.notifier)
          .fetchProfile(userId: widget.userId);
      if (!mounted) return;
      setState(() {
        _publicProfile = profile;
        _isLoadingPublic = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _publicError = e.toString();
        _isLoadingPublic = false;
      });
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );

    if (shouldLogout == true) {
      await ref.read(authControllerProvider.notifier).logout();
      // ignore: use_build_context_synchronously
      AppSnackBar.show(
        // ignore: use_build_context_synchronously
        context,
        "Logged out successful! See you later!👋",
        type: SnackType.success,
      );
    }
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
    final profileState = ref.watch(profilesControllerProvider);

    // decide which profile to use
    final isPublic = widget.userId != null;

    final profile = isPublic ? _publicProfile : profileState.asData?.value;
    if (!isPublic && user != null && profile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/create_profile_screen');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // loading state
    if (isPublic && _isLoadingPublic) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!isPublic && profileState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // error state
    if (isPublic && _publicError != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_publicError!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchPublicProfile,
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (!isPublic && profileState.hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                profileState.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(profilesControllerProvider),
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    // redirect if current user has no profile
    if (!isPublic && user != null && profile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/create_profile_screen');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // safe defaults
    final fullName = profile?.fullName.isNotEmpty == true
        ? profile!.fullName
        : (user?.email ?? "Unknown");

    final nickname = profile?.nickname.isNotEmpty == true
        ? "@${profile!.nickname}"
        : "@ronin";

    final bio = profile?.bio.isNotEmpty == true
        ? profile!.bio
        : "This ronin has not set up a bio yet. They are a mysterious warrior of the digital realm...";

    final avatarUrl = profile?.avatarUrl;
    final fallbackLetter = (user?.email != null && user!.email!.isNotEmpty)
        ? user.email!.substring(0, 1).toUpperCase()
        : 'U';

    final showLogout = !isPublic; // hide logout on public profile

    return Scaffold(
      appBar: AppBar(
        title: Text(nickname + (isPublic ? '' : "'s Profile")),
        actions: [
          if (showLogout)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _confirmLogout(context),
            ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
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
                    style: TextStyle(color: Colors.black26, letterSpacing: 4),
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
                        pageBuilder: (context, a1, a2) => AvatarViewer(
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

          // User Info + buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(nickname, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                Text(bio, style: const TextStyle(color: Colors.black87)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _StatItem(label: "Followers", value: "-"),
                    _StatItem(label: "Following", value: "-"),
                  ],
                ),
                const SizedBox(height: 20),
                
                  Row(
                    children: [
                    if (!isPublic)
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black),
                            shape: const RoundedRectangleBorder(),
                          ),
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/update_profile_screen',
                          ),
                          child: const Text(
                            "Edit Profile",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (user != null)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              shape: const RoundedRectangleBorder(),
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

          // Tabs
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
              children: [_buildPosts(), _buildActivity()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosts() => ListView.builder(
    itemCount: 5,
    itemBuilder: (context, index) => Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Text(
        "Training session log #$index",
        style: const TextStyle(color: Colors.black),
      ),
    ),
  );

  Widget _buildActivity() => const Center(
    child: Text("Recent Activity...", style: TextStyle(color: Colors.black)),
  );
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
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
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ],
  );
}
