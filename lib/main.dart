import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:image_upload_flutter_firebase/firebase_options.dart';
import 'package:image_upload_flutter_firebase/src/async_value_ui.dart';
import 'package:image_upload_flutter_firebase/src/image_upload_notifier.dart';
import 'package:image_upload_flutter_firebase/src/image_upload_repository.dart';
import 'package:image_upload_flutter_firebase/src/photo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue>(
      imageUploadNotifierProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(imageUploadNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Images'),
      ),
      body: const ImagesGrid(),
      floatingActionButton: FloatingActionButton(
          onPressed: state.isLoading
              ? null
              : () => ref
                  .read(imageUploadNotifierProvider.notifier)
                  .pickImageAndUpload(),
          child: state.isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : const Icon(Icons.add)),
    );
  }
}

class ImagesGrid extends ConsumerWidget {
  const ImagesGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosQuery = ref.watch(photosProvider);
    return FirestoreQueryBuilder<Photo>(
      query: photosQuery,
      pageSize: 10,
      builder: (context, snapshot, child) {
        if (snapshot.docs.isEmpty) {
          return Center(
              child: Text('No Data',
                  style: Theme.of(context).textTheme.headline5));
        }
        return ListView.builder(
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            // if we reached the end of the currently obtained items, we try to
            // obtain more items
            if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
              // Tell FirestoreQueryBuilder to try to obtain more items.
              // It is safe to call this function from within the build method.
              snapshot.fetchMore();
            }
            final photo = snapshot.docs[index].data();
            return Dismissible(
              key: Key(photo.id),
              background: Container(color: Colors.red),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) =>
                  ref.read(imageUploadRepositoryProvider).deletePhoto(photo.id),
              child: PhotoTile(photo: photo),
            );
          },
        );
      },
    );
  }
}

class PhotoTile extends StatelessWidget {
  const PhotoTile({
    Key? key,
    required this.photo,
  }) : super(key: key);
  final Photo photo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: CachedNetworkImage(
              imageUrl: photo.imageUrl,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${photo.id}'),
                if (photo.createdAt != null) ...[
                  const SizedBox(height: 8),
                  Text(photo.createdAt.toString(),
                      style: Theme.of(context).textTheme.caption),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }
}
