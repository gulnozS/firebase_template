import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_template/core/widgets/app_error_text.dart';
import 'package:firebase_template/core/widgets/app_loader.dart';
import 'package:firebase_template/features/auth/presentation/providers/auth_providers.dart';
import 'package:firebase_template/features/notes/domain/entities/note.dart';
import 'package:firebase_template/features/notes/presentation/providers/notes_providers.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({required this.userId, required this.userEmail, super.key});

  final String userId;
  final String userEmail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesStreamProvider(userId));
    final actionState = ref.watch(noteActionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes ($userEmail)'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authActionControllerProvider.notifier).signOut();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: actionState.isLoading
                  ? null
                  : () => _showCreateDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Create note'),
            ),
            const SizedBox(height: 12),
            if (ref
                    .watch(noteActionControllerProvider.notifier)
                    .errorMessage() !=
                null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppErrorText(
                  message:
                      ref
                          .watch(noteActionControllerProvider.notifier)
                          .errorMessage() ??
                      'Action failed.',
                ),
              ),
            Expanded(
              child: notesAsync.when(
                data: (notes) {
                  if (notes.isEmpty) {
                    return const Center(
                      child: Text('No notes yet. Create your first one.'),
                    );
                  }
                  return ListView.separated(
                    itemCount: notes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(note.description),
                              if (note.imageUrl != null) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    note.imageUrl!,
                                    height: 180,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) {
                                        return child;
                                      }
                                      return const SizedBox(
                                        height: 180,
                                        child: AppLoader(),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const SizedBox(
                                        height: 180,
                                        child: Center(
                                          child: Icon(Icons.broken_image),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: actionState.isLoading
                                        ? null
                                        : () => _showEditDialog(
                                            context,
                                            ref,
                                            note,
                                          ),
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Edit'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: actionState.isLoading
                                        ? null
                                        : () => ref
                                              .read(
                                                noteActionControllerProvider
                                                    .notifier,
                                              )
                                              .deleteNote(
                                                userId: userId,
                                                noteId: note.id,
                                                imageUrl: note.imageUrl,
                                              ),
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const AppLoader(),
                error: (error, _) =>
                    Center(child: AppErrorText(message: error.toString())),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    Uint8List? imageBytes;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create note'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final file = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (file == null) {
                          return;
                        }
                        imageBytes = await file.readAsBytes();
                        setState(() {});
                      },
                      icon: const Icon(Icons.image),
                      label: Text(
                        imageBytes == null
                            ? 'Attach image (Firebase Storage)'
                            : 'Image attached',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final description = descriptionController.text.trim();
                    if (title.isEmpty || description.isEmpty) {
                      return;
                    }
                    final note = Note(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      title: title,
                      description: description,
                      createdAt: DateTime.now(),
                    );
                    await ref
                        .read(noteActionControllerProvider.notifier)
                        .createNote(
                          userId: userId,
                          note: note,
                          imageBytes: imageBytes,
                        );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    final titleController = TextEditingController(text: note.title);
    final descriptionController = TextEditingController(text: note.description);
    Uint8List? imageBytes;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update note'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final file = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (file == null) {
                          return;
                        }
                        imageBytes = await file.readAsBytes();
                        setState(() {});
                      },
                      icon: const Icon(Icons.upload),
                      label: Text(
                        imageBytes == null
                            ? 'Replace image'
                            : 'New image selected',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final updatedNote = note.copyWith(
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                    );
                    await ref
                        .read(noteActionControllerProvider.notifier)
                        .updateNote(
                          userId: userId,
                          note: updatedNote,
                          imageBytes: imageBytes,
                        );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
