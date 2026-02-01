import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/invite_images.dart';
import '../../core/di/app_scope.dart';
import '../../core/routing/app_routes.dart';
import '../../core/utils/link_builder.dart';
import '../../domain/entities/invite.dart';

class CreateInvitePage extends StatefulWidget {
  const CreateInvitePage({super.key});

  @override
  State<CreateInvitePage> createState() => _CreateInvitePageState();
}

class _CreateInvitePageState extends State<CreateInvitePage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  InviteImageOption _selectedImage = InviteImages.options.first;
  bool _isSaving = false;
  String? _createdId;
  String? _errorText;
  DateTime? _lastSubmitTime;

  @override
  void dispose() {
    _messageController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveInvite() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      setState(() => _errorText = 'Write a sweet message first.');
      return;
    }

    setState(() {
      _errorText = null;
      _isSaving = true;
    });

    final now = DateTime.now();
    if (_lastSubmitTime != null && now.difference(_lastSubmitTime!).inSeconds < 10) {
      setState(() {
        _errorText = 'Please wait a few seconds before creating another.';
        _isSaving = false;
      });
      return;
    }

    final imageUrl = _imageUrlController.text.trim();
    final invite = Invite(
      message: message,
      imageId: _selectedImage.id,
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
      createdAt: DateTime.now(),
    );
    final id = await AppScope.of(context).createInvite(invite);

    setState(() {
      _createdId = id;
      _isSaving = false;
      _lastSubmitTime = DateTime.now();
    });
  }

  Future<void> _copyLink(String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Invite link copied!')));
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final createdLink = _createdId == null ? null : LinkBuilder.inviteLink(_createdId!);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 600;
          final horizontalPadding = isCompact ? 16.0 : 32.0;
          final verticalPadding = isCompact ? 20.0 : 32.0;
          final maxWidth = isCompact ? constraints.maxWidth : 760.0;
          final cardWidth = isCompact
              ? max(130.0, (constraints.maxWidth - horizontalPadding * 2 - 16) / 2)
              : 150.0;

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                32,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create a playful Valentine page',
                      style: isCompact
                          ? Theme.of(context).textTheme.headlineSmall
                          : Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 12),
                    Text('Choose a card', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: InviteImages.options.map((option) {
                        final isSelected = option.id == _selectedImage.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedImage = option),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: cardWidth,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFFFE2EC) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFB71C4A)
                                    : const Color(0xFFE9B7C8),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                SvgPicture.asset(option.assetPath, height: 80),
                                const SizedBox(height: 8),
                                Text(
                                  option.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2B0A1E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        hintText: 'Paste an image or GIF link (optional)',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Write something sweet and playful...',
                        errorText: _errorText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isCompact)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveInvite,
                            icon: const Icon(Icons.favorite_rounded),
                            label: Text(_isSaving ? 'Saving...' : 'Generate Link'),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              _messageController.clear();
                              _imageUrlController.clear();
                              setState(() {
                                _selectedImage = InviteImages.options.first;
                                _createdId = null;
                                _errorText = null;
                              });
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveInvite,
                            icon: const Icon(Icons.favorite_rounded),
                            label: Text(_isSaving ? 'Saving...' : 'Generate Link'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () {
                              _messageController.clear();
                              _imageUrlController.clear();
                              setState(() {
                                _selectedImage = InviteImages.options.first;
                                _createdId = null;
                                _errorText = null;
                              });
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    if (createdLink != null) ...[
                      const SizedBox(height: 28),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your invite link is ready!',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              SelectableText(createdLink),
                              const SizedBox(height: 12),
                              if (isCompact)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _copyLink(createdLink),
                                      icon: const Icon(Icons.copy_rounded),
                                      label: const Text('Copy Link'),
                                    ),
                                    const SizedBox(height: 12),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.of(
                                          context,
                                        ).pushNamed(AppRoutes.invite(_createdId!));
                                      },
                                      icon: const Icon(Icons.open_in_new_rounded),
                                      label: const Text('Preview'),
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _copyLink(createdLink),
                                      icon: const Icon(Icons.copy_rounded),
                                      label: const Text('Copy Link'),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.of(
                                          context,
                                        ).pushNamed(AppRoutes.invite(_createdId!));
                                      },
                                      icon: const Icon(Icons.open_in_new_rounded),
                                      label: const Text('Preview'),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
