import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/speech_input_service.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.onSendAttachments,
    this.hintText = 'Tulis pertanyaan…',
    this.speechLocaleId,
  });

  final String hintText;
  final String? speechLocaleId;
  final ValueChanged<String> onSend;
  final Future<void> Function(List<PickedAttachment> attachments)
      onSendAttachments;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final SpeechInputService _speech = SpeechInputService();
  bool _canSend = false;
  bool _isListening = false;
  bool _speechReady = false;
  bool _micBusy = false;
  Timer? _voiceSilenceTimer;
  static const _voiceSilenceDelay = Duration(milliseconds: 1200);

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _voiceSilenceTimer?.cancel();
    _speech.stop();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _cancelVoiceSilenceTimer() {
    _voiceSilenceTimer?.cancel();
    _voiceSilenceTimer = null;
  }

  void _scheduleAutoSendAfterSilence() {
    _cancelVoiceSilenceTimer();
    if (!_isListening || _controller.text.trim().isEmpty) return;
    _voiceSilenceTimer = Timer(_voiceSilenceDelay, () {
      if (!mounted || !_isListening) return;
      if (_controller.text.trim().isEmpty) return;
      unawaited(_finishListening());
    });
  }

  Future<void> _initSpeech() async {
    final ok = await _speech.initialize(
      onError: (message) {
        if (!mounted) return;
        if (_isListening) {
          setState(() => _isListening = false);
        }
        _showSnack('Pengenalan suara: $message');
      },
    );
    if (mounted) setState(() => _speechReady = ok);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    setState(() => _canSend = false);
    _focusNode.requestFocus();
  }

  Future<void> _finishListening({bool send = true}) async {
    if (!_isListening || _micBusy) return;
    _cancelVoiceSilenceTimer();
    _micBusy = true;
    try {
      await _speech.stop();
      if (!mounted) return;

      final text = _controller.text.trim();
      setState(() => _isListening = false);

      if (!send || text.isEmpty) return;
      widget.onSend(text);
      _controller.clear();
      setState(() => _canSend = false);
    } finally {
      _micBusy = false;
    }
  }

  void _onSpeechResult(String text, bool isFinal) {
    if (!mounted || !_isListening) return;
    final trimmed = text.trim();
    setState(() {
      _controller.text = text;
      _controller.selection = TextSelection.collapsed(offset: text.length);
      _canSend = trimmed.isNotEmpty;
    });
    if (trimmed.isEmpty) return;
    if (isFinal) {
      unawaited(_finishListening());
      return;
    }
    _scheduleAutoSendAfterSilence();
  }

  void _onSpeechStatus(String status) {
    if (!mounted) return;
    if (status == 'listening') {
      if (!_isListening) setState(() => _isListening = true);
      return;
    }
    if ((status == 'done' || status == 'notListening') && _isListening) {
      final text = _controller.text.trim();
      if (text.isNotEmpty) {
        unawaited(_finishListening());
      } else {
        _cancelVoiceSilenceTimer();
        setState(() => _isListening = false);
        unawaited(_speech.stop());
      }
    }
  }

  Future<void> _toggleMic() async {
    if (_micBusy) return;

    if (_isListening) {
      await _finishListening();
      return;
    }

    _micBusy = true;
    try {
    if (!_speechReady) {
      final ok = await _speech.initialize();
      if (!ok) {
        _showSnack('Speech to text tidak tersedia di perangkat ini.');
        return;
      }
      if (mounted) setState(() => _speechReady = true);
    }

    _focusNode.unfocus();
    _controller.clear();
    setState(() => _canSend = false);

    final started = await _speech.startListening(
      localeId: widget.speechLocaleId,
      onResult: _onSpeechResult,
      onStatus: _onSpeechStatus,
      listenFor: const Duration(seconds: 30),
    );

    if (!mounted) return;
    if (!started) {
      _showSnack(
        'Tidak bisa memulai mikrofon. Gunakan Chrome dan izinkan akses mic.',
      );
      return;
    }

    setState(() => _isListening = true);
    } finally {
      _micBusy = false;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1280,
      imageQuality: 86,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    final mime = (image.mimeType?.trim().isNotEmpty ?? false)
        ? image.mimeType!.trim()
        : 'image/jpeg';

    await widget.onSendAttachments(
      [
        PickedAttachment(
          fileName: image.name,
          mimeType: mime,
          bytes: bytes,
        ),
      ],
    );
  }

  void _comingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label segera hadir.')),
    );
  }

  Future<void> _openAttachmentsMenu() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.add_circle_outline),
              title: Text('Tambahkan'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.of(context).pop('gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Ambil Gambar'),
              onTap: () => Navigator.of(context).pop('camera'),
            ),
            ListTile(
              leading: const Icon(Icons.link_rounded),
              title: const Text('Upload File'),
              onTap: () => Navigator.of(context).pop('file'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted || picked == null) return;
    if (picked == 'gallery') {
      await _pickImage(ImageSource.gallery);
    } else if (picked == 'camera') {
      await _pickImage(ImageSource.camera);
    } else if (picked == 'file') {
      _comingSoon('Upload file');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = cs.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.5);
    final fillColor = cs.surfaceContainerHighest.withValues(alpha: isDark ? 0.35 : 0.55);
    final mutedFg = cs.onSurfaceVariant.withValues(alpha: isDark ? 0.72 : 0.78);
    final micColor = _isListening ? cs.error : mutedFg;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: fillColor,
            border: Border.all(
              color: _isListening ? cs.error.withValues(alpha: 0.55) : borderColor,
              width: 1,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 420;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: 'Tambah',
                        visualDensity: VisualDensity.compact,
                        style: IconButton.styleFrom(
                          foregroundColor: cs.onSurfaceVariant,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _isListening ? null : _openAttachmentsMenu,
                        icon: const Icon(Icons.add_rounded, size: 22),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          readOnly: _isListening,
                          textInputAction: TextInputAction.newline,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _send(),
                          onChanged: (v) {
                            final ok = v.trim().isNotEmpty;
                            if (ok != _canSend) setState(() => _canSend = ok);
                          },
                          minLines: 1,
                          maxLines: 5,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.35,
                                    fontWeight: FontWeight.w400,
                                    color: _isListening
                                        ? cs.onSurface.withValues(alpha: 0.9)
                                        : null,
                                  ),
                          decoration: InputDecoration(
                            hintText: _isListening
                                ? 'Bicara… pesan terkirim otomatis'
                                : widget.hintText,
                            hintStyle: TextStyle(
                              color: _isListening
                                  ? cs.error.withValues(alpha: 0.75)
                                  : cs.onSurfaceVariant.withValues(alpha: 0.65),
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            filled: false,
                            contentPadding:
                                const EdgeInsets.fromLTRB(14, 12, 10, 12),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: _isListening
                            ? 'Hentikan & kirim'
                            : 'Bicara lalu kirim otomatis',
                        visualDensity: VisualDensity.compact,
                        style: IconButton.styleFrom(
                          foregroundColor: micColor,
                          backgroundColor: _isListening
                              ? cs.error.withValues(alpha: 0.12)
                              : null,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _toggleMic,
                        icon: Icon(
                          _isListening
                              ? Icons.mic_rounded
                              : Icons.mic_none_rounded,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 2),
                      if (compact)
                        FilledButton(
                          onPressed: _canSend && !_isListening ? _send : null,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            minimumSize: const Size(0, 40),
                            shape: const StadiumBorder(),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Icon(Icons.send_rounded, size: 18),
                        )
                      else
                        FilledButton.icon(
                          onPressed: _canSend && !_isListening ? _send : null,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            minimumSize: const Size(0, 40),
                            shape: const StadiumBorder(),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: const Text('Kirim'),
                        ),
                      const SizedBox(width: 8),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PickedAttachment {
  const PickedAttachment({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
  });

  final String fileName;
  final String mimeType;
  final List<int> bytes;
}
