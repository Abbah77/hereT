import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/data/models/post.dart';
import 'package:offline_first_app/data/repositories/post_repository.dart';
import 'package:offline_first_app/ui/widgets/post_card.dart';
import 'package:offline_first_app/ui/navigation/app_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final postsStream = ref.watch(postRepositoryProvider).getPostsStream();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // Sync status indicator
          Consumer(
            builder: (context, ref, child) {
              return StreamBuilder<bool>(
                stream: ref.watch(connectivityServiceProvider).connectionStream,
                initialData: true,
                builder: (context, snapshot) {
                  final isOnline = snapshot.data ?? true;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      isOnline ? Icons.wifi : Icons.wifi_off,
                      color: isOnline ? Colors.green : Colors.red,
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              AppRouter.router.go('/profile');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Post>>(
        stream: postsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final posts = snapshot.data ?? [];
          
          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.post_add,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No posts yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first post!',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      AppRouter.router.go('/create-post');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Post'),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(post: post);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppRouter.router.go('/create-post');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}