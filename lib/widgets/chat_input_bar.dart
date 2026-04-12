import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.onSendAttachments,
    this.hintText = 'Tanyakan informasi kampus...',
  });

  final String hintText;
  final ValueChanged<String> onSend;
  final Future<void> Function(List<PickedAttachment> attachments)
      onSendAttachments;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _canSend = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    setState(() => _canSend = false);
    _focusNode.requestFocus();
  }

  Future<void> _pickAttachment() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.attach_file),
              title: Text('Tambahkan lampiran'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeri'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Kamera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted || source == null) return;

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: colorScheme.surface.withValues(alpha: 0.86),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Lampiran',
                onPressed: _pickAttachment,
                icon: const Icon(Icons.add_circle_outline),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  onChanged: (v) {
                    final ok = v.trim().isNotEmpty;
                    if (ok != _canSend) setState(() => _canSend = ok);
                  },
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Tulis pesan...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Voice',
                onPressed: null, // mockup-like (placeholder, disabled)
                icon: const Icon(Icons.mic_none_rounded),
              ),
              const SizedBox(width: 2),
              Container(
                margin: const EdgeInsets.only(right: 6),
                child: IconButton.filled(
                  tooltip: 'Send',
                  onPressed: _canSend ? _send : null,
                  icon: const Icon(Icons.send_rounded),
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
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
