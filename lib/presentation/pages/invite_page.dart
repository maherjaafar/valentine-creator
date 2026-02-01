import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../core/constants/invite_images.dart';
import '../../core/di/app_scope.dart';
import '../../core/routing/app_routes.dart';
import '../../domain/entities/invite.dart';
import '../widgets/invite_image_card.dart';
import '../widgets/playful_no_button.dart';

class InvitePage extends StatefulWidget {
  const InvitePage({super.key, required this.inviteId});

  final String inviteId;

  @override
  State<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> {
  Invite? _invite;
  bool _isLoading = true;
  String? _errorMessage;
  bool _accepted = false;
  int _yesPressCount = 0;
  bool _hasLoadedInvite = false;
  late ConfettiController _confettiController;
  late AudioPlayer _audioPlayer;
  late Uint8List _yesSoundBytes;
  final PlayfulNoButtonController _noButtonController = PlayfulNoButtonController();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _audioPlayer = AudioPlayer();
    _yesSoundBytes = _buildYesSoundBytes();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedInvite) {
      _hasLoadedInvite = true;
      _loadInvite();
    }
  }

  Future<void> _loadInvite() async {
    final invite = await AppScope.of(context).getInviteById(widget.inviteId);
    if (!mounted) return;
    setState(() {
      _invite = invite;
      _isLoading = false;
      _errorMessage = invite == null ? 'Invite not found. Create a new one?' : null;
    });
  }

  void _accept() {
    setState(() {
      _accepted = true;
      _yesPressCount++;
    });
    _playYesSound();
    _confettiController.play(); // Trigger confetti!
  }

  String _getExcitementLevel() {
    final levels = [
      'YES!',
      'REALLY YES! 💖',
      'SUPER YES!! 🔥',
      'ULTIMATE YES!!! 🚀',
      'FOREVER YES!!!! ♾️',
      'YES YES YES!!!!! ❤️‍🔥',
      'ABSOLUTELY!!!!! 🌹',
      '1000% YES!!!!! 💎',
      'BEYOND YES!!!!! ✨',
      'INFINITE YES!!!!! 🌌',
      'UNSTOPPABLE YES!!!! ☄️',
      'GALACTIC YES!!!!! 🌠',
      'COSMIC YES!!!!!! 🎆',
      'ETERNAL YES!!!!!!! 💍',
      'MAXIMUM EXCITEMENT!!!! 🎢',
      'HEART EXPLOSION!!!!! 🌋',
      'LOVE OVERLOAD!!!!!! 🌊',
      'TRUE LOVE YES!!!!!!! 💘',
      'DESTINY YES!!!!!!!! 🏹',
      'SOULMATE YES!!!!!!!!! 🕯️',
    ];

    if (_yesPressCount <= 0) return 'YES';
    final index = (_yesPressCount - 1).clamp(0, levels.length - 1);
    final text = levels[index];
    return '$text ($_yesPressCount)';
  }

  Future<void> _playYesSound() async {
    await _audioPlayer.play(BytesSource(_yesSoundBytes));
  }

  Uint8List _buildYesSoundBytes() {
    const sampleRate = 44100;
    const durationSeconds = 0.6;
    const amplitude = 0.42;
    const bitsPerSample = 16;
    const channels = 1;

    final numSamples = (sampleRate * durationSeconds).toInt();
    final dataSize = numSamples * (bitsPerSample ~/ 8) * channels;
    final totalSize = 44 + dataSize;
    final bytes = ByteData(totalSize);

    void writeString(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        bytes.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    writeString(0, 'RIFF');
    bytes.setUint32(4, 36 + dataSize, Endian.little);
    writeString(8, 'WAVE');
    writeString(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, channels, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate * channels * (bitsPerSample ~/ 8), Endian.little);
    bytes.setUint16(32, channels * (bitsPerSample ~/ 8), Endian.little);
    bytes.setUint16(34, bitsPerSample, Endian.little);
    writeString(36, 'data');
    bytes.setUint32(40, dataSize, Endian.little);

    for (var i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final envelope = (1 - (t / durationSeconds)).clamp(0.0, 1.0);
      final burst = envelope * envelope;

      final shimmer =
          sin(2 * pi * 540 * t) +
          0.8 * sin(2 * pi * 720 * t) +
          0.6 * sin(2 * pi * 920 * t) +
          0.4 * sin(2 * pi * 1240 * t);

      final noise = (Random(i).nextDouble() - 0.5) * 0.6;
      final sample = (shimmer + noise) * amplitude * burst;
      final intSample = (sample * 32767).round();
      bytes.setInt16(44 + i * 2, intSample, Endian.little);
    }

    return bytes.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 600;
          final horizontalPadding = isCompact ? 16.0 : 32.0;
          final verticalPadding = isCompact ? 20.0 : 32.0;
          final maxWidth = isCompact ? constraints.maxWidth : 760.0;
          final headlineStyle = isCompact
              ? theme.textTheme.headlineSmall
              : theme.textTheme.headlineMedium;
          final buttonAreaHeight = isCompact ? 150.0 : 170.0;

          return Stack(
            children: [
              Center(
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _invite?.inviteeName != null
                              ? 'Will you be my Valentine, ${_invite!.inviteeName}?'
                              : 'Will you be my Valentine?',
                          style: headlineStyle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(height: 16),
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          )
                        else if (_errorMessage != null)
                          Column(
                            children: [
                              Text(_errorMessage!, style: theme.textTheme.bodyLarge),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pushReplacementNamed(AppRoutes.create);
                                },
                                icon: const Icon(Icons.favorite_rounded),
                                label: const Text('Create a new invite'),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              InviteImageCard(
                                imageId: _invite!.imageId,
                                imageUrl: _invite!.imageUrl,
                                revealed: _accepted,
                              ),
                              const SizedBox(height: 16),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: _accepted
                                    ? Column(
                                        key: const ValueKey('message'),
                                        children: [
                                          Text(
                                            _invite!.message,
                                            style: theme.textTheme.titleLarge,
                                            textAlign: TextAlign.center,
                                          ),
                                          if (_invite!.letterBody != null) ...[
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
                                                    if (_invite!.letterTitle != null) ...[
                                                      Text(
                                                        _invite!.letterTitle!,
                                                        style: theme.textTheme.titleMedium
                                                            ?.copyWith(
                                                              fontStyle: FontStyle.italic,
                                                              color: const Color(0xFFB71C4A),
                                                            ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      const SizedBox(height: 12),
                                                    ],
                                                    Text(
                                                      _invite!.letterBody!,
                                                      style: theme.textTheme.bodyLarge?.copyWith(
                                                        height: 1.5,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                          Text(
                                            InviteImages.byId(_invite!.imageId).title,
                                            style: theme.textTheme.bodyLarge,
                                          ),
                                          const SizedBox(height: 32),
                                          Text(
                                            '📸 Take a screenshot and share it with your next valentine!',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF7C2B5F),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      )
                                    : Text(
                                        'Say YES to reveal the message.',
                                        key: const ValueKey('placeholder'),
                                        style: theme.textTheme.bodyLarge,
                                        textAlign: TextAlign.center,
                                      ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: buttonAreaHeight,
                                child: LayoutBuilder(
                                  builder: (context, buttonConstraints) {
                                    return MouseRegion(
                                      onEnter: (event) {
                                        _noButtonController.updateCursor(event.localPosition);
                                      },
                                      onHover: (event) {
                                        _noButtonController.updateCursor(event.localPosition);
                                      },
                                      child: Stack(
                                        children: [
                                          AnimatedPositioned(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeOutCubic,
                                            left: 0,
                                            right: _accepted ? 0 : null,
                                            bottom: 0,
                                            child: SizedBox(
                                              width: _accepted ? null : 120,
                                              height: 48,
                                              child: ElevatedButton.icon(
                                                onPressed: _accept,
                                                icon: const Icon(Icons.favorite_rounded),
                                                label: Text(
                                                  _accepted ? _getExcitementLevel() : 'YES',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: _accepted ? 18 : null,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (!_accepted)
                                            PlayfulNoButton(
                                              bounds: Size(
                                                buttonConstraints.maxWidth,
                                                buttonConstraints.maxHeight,
                                              ),
                                              controller: _noButtonController,
                                              onMessageChanged: (_) {},
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // Confetti overlay
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 3.14 / 2, // Down
                  emissionFrequency: 0.05,
                  numberOfParticles: 30,
                  gravity: 0.3,
                  shouldLoop: false,
                  colors: const [
                    Color(0xFFB71C4A),
                    Color(0xFF7C2B5F),
                    Color(0xFFFF8FB1),
                    Color(0xFFFFD1DC),
                    Color(0xFFF7C8D8),
                    Color(0xFFFF4D6D),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
