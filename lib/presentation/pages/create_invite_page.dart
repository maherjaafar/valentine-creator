import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/invite_images.dart';
import '../../core/di/app_scope.dart';
import '../../core/routing/app_routes.dart';
import '../../core/utils/link_builder.dart';
import '../../domain/entities/invite.dart';
import '../widgets/invite_image_card.dart';

class CreateInvitePage extends StatefulWidget {
  const CreateInvitePage({super.key});

  @override
  State<CreateInvitePage> createState() => _CreateInvitePageState();
}

class _CreateInvitePageState extends State<CreateInvitePage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _inviteeNameController = TextEditingController();
  final TextEditingController _letterTitleController = TextEditingController();
  final TextEditingController _letterBodyController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  InviteImageOption _selectedImage = InviteImages.options.first;
  bool _isSaving = false;
  String? _createdId;
  String? _errorText;
  DateTime? _lastSubmitTime;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onFieldChanged);
    _inviteeNameController.addListener(_onFieldChanged);
    _letterTitleController.addListener(_onFieldChanged);
    _letterBodyController.addListener(_onFieldChanged);
    _imageUrlController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _messageController.removeListener(_onFieldChanged);
    _inviteeNameController.removeListener(_onFieldChanged);
    _letterTitleController.removeListener(_onFieldChanged);
    _letterBodyController.removeListener(_onFieldChanged);
    _imageUrlController.removeListener(_onFieldChanged);
    _messageController.dispose();
    _inviteeNameController.dispose();
    _letterTitleController.dispose();
    _letterBodyController.dispose();
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
      inviteeName: _inviteeNameController.text.trim().isEmpty
          ? null
          : _inviteeNameController.text.trim(),
      letterTitle: _letterTitleController.text.trim().isEmpty
          ? null
          : _letterTitleController.text.trim(),
      letterBody: _letterBodyController.text.trim().isEmpty
          ? null
          : _letterBodyController.text.trim(),
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
    final createdLink = _createdId == null ? null : LinkBuilder.inviteLink(_createdId!);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 600;
          final horizontalPadding = isCompact ? 16.0 : 32.0;
          final verticalPadding = isCompact ? 20.0 : 32.0;
          final maxWidth = isCompact ? constraints.maxWidth : 760.0;
          final cardWidth = isCompact
              ? max(130.0, (constraints.maxWidth - horizontalPadding * 2 - 16) / 2)
              : 150.0;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding, horizontalPadding, 48),
            child: Center(
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
                      controller: _inviteeNameController,
                      decoration: const InputDecoration(hintText: 'Invitee Name (e.g. Madelene)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        hintText: 'Paste an image or GIF link (optional)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _messageController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'A short sweet message...',
                        errorText: _errorText,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'The Love Letter (optional)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _letterTitleController,
                      decoration: const InputDecoration(
                        hintText: 'Letter Title (e.g. To my dearest...)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _letterBodyController,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText: 'Write your heartfelt letter here...',
                      ),
                    ),
                    const SizedBox(height: 32),
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
                              _inviteeNameController.clear();
                              _letterTitleController.clear();
                              _letterBodyController.clear();
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
                              _inviteeNameController.clear();
                              _letterTitleController.clear();
                              _letterBodyController.clear();
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
                    const SizedBox(height: 48),
                    Text(
                      'Live Preview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFFB71C4A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 32),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7FB),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE9B7C8), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB71C4A).withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            _inviteeNameController.text.trim().isNotEmpty
                                ? 'Will you be my Valentine, ${_inviteeNameController.text.trim()}?'
                                : 'Will you be my Valentine?',
                            style: isCompact
                                ? Theme.of(context).textTheme.headlineSmall
                                : Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          InviteImageCard(
                            imageId: _selectedImage.id,
                            imageUrl: _imageUrlController.text.trim().isEmpty
                                ? null
                                : _imageUrlController.text.trim(),
                            revealed: true,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _messageController.text.trim().isNotEmpty
                                ? _messageController.text.trim()
                                : 'Your sweet message will appear here...',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          if (_letterBodyController.text.trim().isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Card(
                              color: const Color(0xFFFFF7FB),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: Color(0xFFE9B7C8)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    if (_letterTitleController.text.trim().isNotEmpty) ...[
                                      Text(
                                        _letterTitleController.text.trim(),
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontStyle: FontStyle.italic,
                                          color: const Color(0xFFB71C4A),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    Text(
                                      _letterBodyController.text.trim(),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.copyWith(height: 1.5),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(_selectedImage.title, style: Theme.of(context).textTheme.bodyLarge),
                          const SizedBox(height: 32),
                          Text(
                            '📸 Take a screenshot and share it with your next valentine!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF7C2B5F),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
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
