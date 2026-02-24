import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/state/auth_controller.dart';
import '../../profiles/state/profiles_controller.dart';
import '../../../shared/widgets/nav_user_menu.dart';
import '../../blogs/state/blogs_controller.dart';
import 'article_widgets/article_image_grid.dart';
import '../../../core/constants/time_ago.dart';
import '../../../shared/widgets/image/image_gallery_page.dart';
import 'article_widgets/create_article.dart';
import 'article_widgets/update_article.dart';
import '../../../shared/widgets/app_refresh.dart';
import '../../comments/presentation/comment_panel.dart';
import '../../../core/enums/comment_context_type.dart';
import '../../../features/profiles/presentation/widgets/profile_link.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  int page = 1;
  final int limit = 5;

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetch();
    });
  }

  Future<void> _fetch() async {
    await ref
        .read(blogsControllerProvider.notifier)
        .fetchArticles(
          limit: limit,
          page: page,
          search: searchController.text.isEmpty ? null : searchController.text,
        );
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _openCommentPanel(String articleId) {
    _dismissKeyboard();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.zero),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85, // 85% of screen height
          minChildSize: 0.25, // can shrink to 25%
          maxChildSize: 0.95, // can grow to 95%
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Article Comments',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                Expanded(
                  child: CommentPanel(
                    articleId: articleId,
                    type: CommentContextType.article,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openPaginationPicker(int totalPages) async {
    final selectedPage = await showGeneralDialog<int>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Pagination Picker',
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox.expand(),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 72),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 250,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(totalPages, (index) {
                            final pageNumber = index + 1;
                            final isCurrent = pageNumber == page;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pop(pageNumber);
                                },
                                child: Container(
                                  width: 40,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? Colors.black
                                        : Colors.white,
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  child: Text(
                                    '$pageNumber',
                                    style: TextStyle(
                                      color: isCurrent
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || selectedPage == null || selectedPage == page) return;
    setState(() {
      page = selectedPage;
    });
    _fetch();
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
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: NavUserMenu(),
              ),
            ],
          ),
          body: GestureDetector(
            onTap: _dismissKeyboard,
            behavior: HitTestBehavior.translucent,
            child: Column(
              children: [
                // search bar
                Container(
                  color: Colors.black,
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.all(3),
                  child: TextField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: "Search Title",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      suffixIconConstraints: const BoxConstraints(minWidth: 0),
                      // Keep search icon; add clear icon on the left when input has value.
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (searchController.text.isNotEmpty) ...[
                            IconButton(
                              onPressed: () {
                                searchController.clear();
                                _dismissKeyboard();
                                setState(() {
                                  page = 1;
                                });
                                _fetch();
                              },
                              icon: const Icon(Icons.close, color: Colors.black),
                            ),
                            Container(
                              width: 1,
                              height: 22,
                              color: Colors.grey.shade400,
                            ),
                          ],
                          IconButton(
                            onPressed: () {
                              _dismissKeyboard();
                              setState(() {
                                page = 1;
                              });
                              _fetch(); // trigger search
                            },
                            icon: const Icon(Icons.search, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (value) {
                      _dismissKeyboard();
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
                                  _dismissKeyboard();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const CreateArticleScreen(),
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
                              : blogState.contentError != null
                              ? Center(
                                  child: Text(
                                    blogState.contentError!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                )
                              : blogState.articles.isEmpty
                              ? const Center(
                                  child: Text("No available articles."),
                                )
                              : AppRefreshWrapper(
                                  onRefresh: () async {
                                    setState(() {
                                      page = 1; // reset to first page on pull
                                    });
                                    await _fetch();
                                  },
                                  child: ListView.builder(
                                    itemCount: blogState.articles.length,
                                    itemBuilder: (context, index) {
                                      final article = blogState.articles[index];
                                      final isUpdating =
                                          blogState
                                              .updateArticleLoadingById[article
                                              .id] ??
                                          false;
                                      final isDeleting =
                                          blogState
                                              .deleteArticleLoadingById[article
                                              .id] ??
                                          false;
                                      final isBusy = isUpdating || isDeleting;

                                      return Stack(
                                        children: [
                                          Card(
                                            color: Colors.white,
                                            elevation: 0,
                                            shape: const RoundedRectangleBorder(
                                              side: BorderSide(
                                                color: Colors.black,
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.zero,
                                            ),
                                            margin: const EdgeInsets.only(
                                              bottom: 27,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          article.title,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ),

                                                      // 3 dots menu
                                                      if (user != null)
                                                        PopupMenuButton<String>(
                                                          icon: const Icon(
                                                            Icons.more_vert,
                                                          ),
                                                          onSelected: (value) {
                                                            _dismissKeyboard();
                                                            if (isBusy) return;
                                                            if (value ==
                                                                'edit') {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (_) =>
                                                                      UpdateArticleScreen(
                                                                        article:
                                                                            article,
                                                                      ),
                                                                ),
                                                              );
                                                            } else if (value ==
                                                                'delete') {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder: (context) => AlertDialog(
                                                                  title: const Text(
                                                                    "Delete Article",
                                                                  ),
                                                                  content:
                                                                      const Text(
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
                                                                      onPressed: () async {
                                                                        Navigator.pop(
                                                                          context,
                                                                        );

                                                                        await ref
                                                                            .read(
                                                                              blogsControllerProvider.notifier,
                                                                            )
                                                                            .deleteArticle(
                                                                              id: article.id,
                                                                              removedImages: article.images
                                                                                  .map(
                                                                                    (
                                                                                      img,
                                                                                    ) => img.imageUrl,
                                                                                  )
                                                                                  .toList(),
                                                                            );
                                                                      },
                                                                      child: const Text(
                                                                        "Delete",
                                                                        style: TextStyle(
                                                                          color:
                                                                              Colors.red,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          itemBuilder:
                                                              (
                                                                context,
                                                              ) => const [
                                                                PopupMenuItem(
                                                                  value: 'edit',
                                                                  child: Text(
                                                                    "Edit",
                                                                  ),
                                                                ),
                                                                PopupMenuItem(
                                                                  value:
                                                                      'delete',
                                                                  child: Text(
                                                                    "Delete",
                                                                  ),
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
                                                    images: article.images
                                                        .map(
                                                          (img) => img.imageUrl,
                                                        )
                                                        .toList(),
                                                    onImageClick: (imageUrl, index) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              ImageGalleryPage(
                                                                images: article
                                                                    .images
                                                                    .map(
                                                                      (
                                                                        img,
                                                                      ) => img
                                                                          .imageUrl,
                                                                    )
                                                                    .toList(),
                                                                initialIndex:
                                                                    index,
                                                                articleId:
                                                                    article.id,
                                                                imageId: article
                                                                    .images[index]
                                                                    .id,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                  ),

                                                  const SizedBox(height: 8),

                                                  //meta info
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        'Published by ',
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      ProfileLink(
                                                        userId: article
                                                            .authorId, // pass the actual user ID
                                                        displayName:
                                                            article.fullName ??
                                                            "Unknown", // the name to display
                                                        textColor: Colors
                                                            .grey, // match your styling
                                                      ),
                                                      Text(
                                                        ' • ${timeAgo(article.createdAt)}',
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  // comment button
                                                  InkWell(
                                                    onTap: () =>
                                                        _openCommentPanel(
                                                          article.id,
                                                        ),
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
                                                            BorderRadius.circular(
                                                              0,
                                                            ),
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
                                          ),
                                          if (isBusy)
                                            Positioned.fill(
                                              child: ColoredBox(
                                                color: Colors.white70,
                                                child: Center(
                                                  child: const SizedBox(
                                                    width: 22,
                                                    height: 22,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                        ),

                        // pagination
                        if (blogState.total > 0)
                          Builder(
                            builder: (context) {
                              final totalPages = (blogState.total / limit)
                                  .ceil();

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
                                  InkWell(
                                    onTap: () => _openPaginationPicker(
                                      totalPages,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 6,
                                      ),
                                      child: Text("Page $page of $totalPages"),
                                    ),
                                  ),
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
          ),
        );
      },
    );
  }
}
