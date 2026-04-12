import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.onSendAttachments,
    this.hintText = 'Tulis pertanyaan…',
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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = cs.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.5);
    final fillColor = cs.surfaceContainerHighest.withValues(alpha: isDark ? 0.35 : 0.55);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: fillColor,
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: 'Lampiran',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 44, minHeight: 44),
                    style: IconButton.styleFrom(
                      foregroundColor: cs.onSurfaceVariant,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: _pickAttachment,
                    icon: const Icon(Icons.add_rounded, size: 22),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.newline,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _send(),
                      onChanged: (v) {
                        final ok = v.trim().isNotEmpty;
                        if (ok != _canSend) setState(() => _canSend = ok);
                      },
                      minLines: 1,
                      maxLines: 5,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.35,
                            fontWeight: FontWeight.w400,
                          ),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.65),
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        filled: false,
                        contentPadding: const EdgeInsets.fromLTRB(0, 10, 8, 10),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Kirim',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 44, minHeight: 44),
                    style: IconButton.styleFrom(
                      foregroundColor: cs.primary,
                      disabledForegroundColor:
                          cs.onSurfaceVariant.withValues(alpha: 0.35),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: _canSend ? _send : null,
                    icon: const Icon(Icons.arrow_upward_rounded, size: 20),
                  ),
                ],
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
