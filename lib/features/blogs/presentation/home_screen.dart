import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/state/auth_controller.dart';
import '../../profiles/state/profiles_controller.dart';
import '../../../shared/widgets/nav_user_menu.dart';
import '../../blogs/state/blogs_controller.dart';
import '../../blogs/presentation/widgets/article_image_grid.dart';
import '../../../core/constants/time_ago.dart';
import 'widgets/image_gallery_page.dart';
import 'widgets/create_article.dart';

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
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetch();
    });
  }

  void _fetch() {
    ref
        .read(blogsControllerProvider.notifier)
        .fetchArticles(
          limit: limit,
          page: page,
          search: searchController.text.isEmpty ? null : searchController.text,
        );
  }

  void _openCommentPanel(String articleId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.zero), // sharp top
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85, // 85% of screen height
          minChildSize: 0.25, // can shrink to 25%
          maxChildSize: 0.95, // can grow to 95%
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // draggable handle
                  Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Text(
                    'Comments for $articleId',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Comments content goes here...',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final profileState = ref.watch(profilesControllerProvider);
    final blogState = ref.watch(blogsControllerProvider);

    final user = authState.asData?.value;

    return profileState.when(
      // while checking profile
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text("Go Back"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
            ],
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
            body: Center(child: CircularProgressIndicator()),
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
                  decoration: InputDecoration(
                    hintText: "Search Title",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    // Add search icon inside input
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          page = 1;
                        });
                        _fetch(); // trigger search
                      },
                      child: const Icon(Icons.search, color: Colors.black),
                    ),
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      page = 1;
                    });
                    _fetch();
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                side: const BorderSide(color: Colors.black),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CreateArticle(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Create Post",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // article list
                      Expanded(
                        child: blogState.contentLoading
                            ? const Center(child: CircularProgressIndicator())
                            : blogState.blogError != null
                            ? Center(
                                child: Text(
                                  blogState.blogError!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              )
                            : blogState.articles.isEmpty
                            ? const Center(
                                child: Text("No available articles."),
                              )
                            : ListView.builder(
                                itemCount: blogState.articles.length,
                                itemBuilder: (context, index) {
                                  final article = blogState.articles[index];

                                  return Card(
                                    color: Colors.white,
                                    elevation: 0,
                                    shape: const RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 27),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  article.title,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),

                                              // 3 dots menu
                                              if (user !=
                                                  null) // optional: only show if logged in
                                                PopupMenuButton<String>(
                                                  icon: const Icon(
                                                    Icons.more_vert,
                                                  ),
                                                  onSelected: (value) {
                                                    if (value == 'edit') {
                                                      print(
                                                        "Edit article: ${article.id}",
                                                      );
                                                      // TODO: Navigate to edit screen
                                                    } else if (value ==
                                                        'delete') {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: const Text(
                                                            "Delete Article",
                                                          ),
                                                          content: const Text(
                                                            "Are you sure you want to delete this article?",
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                  ),
                                                              child: const Text(
                                                                "Cancel",
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                                print(
                                                                  "Deleted article: ${article.id}",
                                                                );
                                                                // TODO: Call delete function
                                                              },
                                                              child: const Text(
                                                                "Delete",
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  itemBuilder: (context) =>
                                                      const [
                                                        PopupMenuItem(
                                                          value: 'edit',
                                                          child: Text("Edit"),
                                                        ),
                                                        PopupMenuItem(
                                                          value: 'delete',
                                                          child: Text("Delete"),
                                                        ),
                                                      ],
                                                ),
                                            ],
                                          ),

                                          const SizedBox(height: 8),
                                          Text(article.content),
                                          const SizedBox(height: 12),

                                          // Image grid
                                          ArticleImageGrid(
                                            images: article.images,
                                            onImageClick: (imageUrl, index) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ImageGalleryPage(
                                                        images: article
                                                            .images, // all images
                                                        initialIndex: index,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),

                                          const SizedBox(height: 8),

                                          //meta info
                                          Text(
                                            'Published by ${article.fullName ?? 'Unknown'} • ${timeAgo(article.createdAt)}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // comment button
                                          InkWell(
                                            onTap: () =>
                                                _openCommentPanel(article.id),
                                            child: Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors
                                                    .grey[200], // light background like FB modal handle
                                                borderRadius:
                                                    BorderRadius.circular(0),
                                              ),
                                              child: const Icon(
                                                Icons.comment_outlined,
                                                size: 28,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      // pagination
                      if (blogState.total > 0)
                        Builder(
                          builder: (context) {
                            final totalPages = (blogState.total / limit).ceil();

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: page > 1
                                      ? () {
                                          setState(() {
                                            page = 1;
                                          });
                                          _fetch();
                                        }
                                      : null,
                                  icon: const Icon(Icons.first_page),
                                ),
                                IconButton(
                                  onPressed: page > 1
                                      ? () {
                                          setState(() {
                                            page--;
                                          });
                                          _fetch();
                                        }
                                      : null,
                                  icon: const Icon(Icons.arrow_back),
                                ),
                                Text("Page $page of $totalPages"),
                                IconButton(
                                  onPressed: page < totalPages
                                      ? () {
                                          setState(() {
                                            page++;
                                          });
                                          _fetch();
                                        }
                                      : null,
                                  icon: const Icon(Icons.arrow_forward),
                                ),
                                IconButton(
                                  onPressed: page < totalPages
                                      ? () {
                                          setState(() {
                                            page = totalPages;
                                          });
                                          _fetch();
                                        }
                                      : null,
                                  icon: const Icon(Icons.last_page),
                                ),
                              ],
                            );
                          },
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
