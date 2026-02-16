import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/auth_controller.dart';
import '../../profiles/state/profiles_controller.dart';
import '../../../shared/widgets/nav_user_menu.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final searchController = TextEditingController();

  int page = 1;
  final int limit = 5;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final profileState = ref.watch(profilesControllerProvider);

    final user = authState.asData?.value;

    return profileState.when(
      // while checking profile
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),

      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text(
            "Something went wrong while fetching profile.",
            // error.toString(),
            // style: const TextStyle(color: Colors.red),
          ),
        ),
      ),

      // when profile check finished
      data: (profile) {
        // if user exists but profile doesn't -> redirect
        if (user != null && profile == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            Navigator.pushReplacementNamed(context, '/create_profile_screen');
          });

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // nomal home UI
        return Scaffold(
          appBar: AppBar(
            title: const Text('Modern Samurai'),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: NavUserMenu(),
              ),
            ],
          ),
          body: Column(
            children: [
              // search bar
              Container(
                color: Colors.black,
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(3),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: "Search Title",
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      page = 1;
                    });
                  },
                ),
              ),

              // content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // header
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Recent Posts",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          if (user != null)
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape:
                                    const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.zero,
                                ),
                                side: const BorderSide(
                                    color: Colors.black),
                              ),
                              onPressed: () {},
                              child: const Text(
                                "Create Post",
                                style:
                                    TextStyle(color: Colors.black),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // article list
                      Expanded(
                        child: ListView.builder(
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return const SizedBox(); // temporary
                          },
                        ),
                      ),

                      // pagination
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: page > 1
                                ? () => setState(() => page--)
                                : null,
                            icon:
                                const Icon(Icons.arrow_back),
                          ),
                          Text("Page $page"),
                          IconButton(
                            onPressed: () =>
                                setState(() => page++),
                            icon: const Icon(
                                Icons.arrow_forward),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
