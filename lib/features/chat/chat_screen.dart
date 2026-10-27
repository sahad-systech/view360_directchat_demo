import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';
import 'package:view360_direct_chat_example/core/constants/app_constants.dart';
import 'package:view360_direct_chat_example/features/chat/presentation/providers/chat_provider.dart';
import 'package:view360_direct_chat_example/features/Home/home_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  int _messageCount = 0;

  @override
  void initState() {
    super.initState();
    // Fetch initial chat history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChatProvider>();
      provider.fetchHistory('session_123');

      // Register navigation callback for when agent closes chat
      provider.onChatClosed = () {
        if (mounted) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      };
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom([bool animated = true]) {
    if (_scrollController.hasClients) {
      if (animated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFAFAFF,
      ), // Light background instead of pattern
      body: SafeArea(
        child: Column(
          children: [
            const _ChatHeader(),
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.errorMessage != null) {
                    return Center(child: Text(provider.errorMessage!));
                  }

                  if (provider.messages.length != _messageCount) {
                    final isInitial = _messageCount == 0;
                    _messageCount = provider.messages.length;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom(!isInitial);
                    });
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    itemCount: provider.messages.length,
                    itemBuilder: (context, index) {
                      final message = provider.messages[index];
                      // Format the timestamp simply for display, or use a proper formatter
                      DateTime? dt = DateTime.tryParse(message.createdAt);
                      final timeStr = dt != null
                          ? "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}"
                          : message.createdAt;

                      if (message.senderType == 'customer') {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _UserMessage(
                            text: message.content,
                            files: message.files,
                            time: timeStr,
                            isRead: true,
                          ),
                        );
                      } else if (message.senderType == 'system') {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: SystemMessage(text: message.content),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _SupportMessage(
                            text: message.content,
                            files: message.files,
                            time: timeStr,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            const _ChatInputArea(),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Color(0xFF1B1B2F),
            ),
          ),
          const SizedBox(width: 16),
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF535D7A),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Consumer<ChatProvider>(
                    builder: (context, provider, child) {
                      return Text(
                        provider.agentName.isNotEmpty
                            ? provider.agentName[0].toUpperCase()
                            : 'A',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<ChatProvider>(
                  builder: (context, provider, child) {
                    return Text(
                      provider.agentName,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1B1B2F),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  },
                ),
                Text(
                  'Active Support',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF5C6B8D),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final shouldClose = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      'Close Chat',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1B1B2F),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to close this chat?',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF5C6B8D),
                        fontSize: 14,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF5C6B8D),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  );
                },
              );

              if (shouldClose == true) {
                if (!context.mounted) return;
                final chatProvider = context.read<ChatProvider>();
                await chatProvider.closeChat();
                if (context.mounted) {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  }
                }
              }
            },
            child: const Icon(
              Icons.exit_to_app_rounded,
              color: Color(0xFF1B1B2F),
            ),
          ),
        ],
      ),
    );
  }
}

class SystemMessage extends StatelessWidget {
  final String text;
  const SystemMessage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8E9F1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: const Color(0xFF5C6B8D),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

Future<void> downloadAndOpenFile(String filePath, {String? filepath}) async {
  try {
    final targetPath = filepath ?? filePath;
    if (!targetPath.startsWith('http') && File(targetPath).existsSync()) {
      await OpenFilex.open(targetPath);
      return;
    }

    final dio = Dio();
    final tempDir = await getTemporaryDirectory();
    final fileName = targetPath.split('/').last.split('?').first;
    final savePath = '${tempDir.path}/$fileName';

    final file = File(savePath);
    if (!file.existsSync()) {
      await dio.download(targetPath, savePath);
    }
    await OpenFilex.open(savePath);
  } catch (e) {
    debugPrint('Error downloading/opening file: $e');
  }
}

Widget buildFileWidget(String filePath) {
  return FutureBuilder<String?>(
    future: SharedPreferences.getInstance().then(
      (prefs) => prefs.getString('mediaUrl'),
    ),
    builder: (context, snapshot) {
      final mediaUrl = snapshot.data ?? AppConstants.mediaUrl;
      final extension = filePath.split('.').last.toLowerCase();
      final isLocal =
          !filePath.startsWith('http') && File(filePath).existsSync();
      final String fullPath = isLocal
          ? filePath
          : (filePath.startsWith('http')
                ? filePath
                : '$mediaUrl${filePath.startsWith('/') ? '' : '/'}$filePath');

      switch (extension) {
        case 'jpg':
        case 'jpeg':
        case 'png':
        case 'webp':
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => downloadAndOpenFile(
                fullPath,
                filepath: isLocal ? fullPath : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isLocal
                    ? Image.file(
                        File(fullPath),
                        fit: BoxFit.cover,
                        height: 160,
                        width: 220,
                      )
                    : Image.network(
                        fullPath,
                        fit: BoxFit.cover,
                        height: 160,
                        width: 220,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 160,
                            width: 220,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 160,
                          width: 220,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 40),
                        ),
                      ),
              ),
            ),
          );
        case 'pdf':
          return _buildGenericFileWidget(
            fullPath,
            Icons.picture_as_pdf,
            const Color(0xFF8B0000),
            'PDF Document',
            isLocal: isLocal,
          );
        case 'mp4':
        case 'mov':
        case 'avi':
          return _buildGenericFileWidget(
            fullPath,
            Icons.movie,
            const Color(0xFF2E8B57),
            'Video File',
            isLocal: isLocal,
          );
        case 'gif':
          return _buildGenericFileWidget(
            fullPath,
            Icons.gif,
            const Color(0xFF6A5ACD),
            'GIF File',
            isLocal: isLocal,
          );
        case 'xlsx':
        case 'csv':
        case 'xls':
          return _buildGenericFileWidget(
            fullPath,
            Icons.table_chart,
            const Color(0xFF4682B4),
            'Spreadsheet',
            isLocal: isLocal,
          );
        case 'mp3':
        case 'wav':
        case 'm4a':
        case 'aac':
        case 'ogg':
          return _buildGenericFileWidget(
            fullPath,
            Icons.audiotrack,
            const Color(0xFF673AB7),
            'Audio File',
            isLocal: isLocal,
          );
        default:
          return _buildGenericFileWidget(
            fullPath,
            Icons.insert_drive_file,
            const Color(0xFF555555),
            filePath.split('/').last,
            isLocal: isLocal,
          );
      }
    },
  );
}

Widget _buildGenericFileWidget(
  String filePath,
  IconData icon,
  Color color,
  String label, {
  bool isLocal = false,
}) {
  return InkWell(
    onTap: () =>
        downloadAndOpenFile(filePath, filepath: isLocal ? filePath : null),
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}

class _UserMessage extends StatelessWidget {
  final String text;
  final List<String> files;
  final String time;
  final bool isRead;

  const _UserMessage({
    required this.text,
    this.files = const [],
    required this.time,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            color: Color(0xFF4B39C7),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (files.isNotEmpty)
                ...files.map((file) => buildFileWidget(file)),
              if (text.isNotEmpty)
                Text(
                  text,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: GoogleFonts.inter(
                color: const Color(0xFF8B92A5),
                fontSize: 11,
              ),
            ),
            if (isRead) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.done_all_rounded,
                size: 14,
                color: Color(0xFF4B39C7),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _SupportMessage extends StatelessWidget {
  final String text;
  final List<String> files;
  final String time;

  const _SupportMessage({
    required this.text,
    this.files = const [],
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFDCD8F9),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              'A',
              style: GoogleFonts.inter(
                color: const Color(0xFF4B39C7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (files.isNotEmpty)
                      ...files.map((file) => buildFileWidget(file)),
                    if (text.isNotEmpty)
                      Text(
                        text,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF1B1B2F),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                time,
                style: GoogleFonts.inter(
                  color: const Color(0xFF8B92A5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatInputArea extends StatefulWidget {
  const _ChatInputArea();

  @override
  State<_ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<_ChatInputArea> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isPickerActive = false;

  void _sendMessage() {
    final text = _controller.text;
    final chatProvider = context.read<ChatProvider>();
    if (text.trim().isNotEmpty || chatProvider.attachments.isNotEmpty) {
      chatProvider.sendMessage(text.trim(), 'session_123');
      _controller.clear();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickerActive) return;
    _isPickerActive = true;
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null && mounted) {
        context.read<ChatProvider>().addAttachment(image.path);
      }
    } finally {
      _isPickerActive = false;
    }
  }

  Future<void> _pickAudio() async {
    if (_isPickerActive) return;
    _isPickerActive = true;
    try {
      // Delay to allow PopupMenu to dismiss completely on iOS
      await Future.delayed(const Duration(milliseconds: 300));
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg'],
      );
      if (files.isNotEmpty && files.first.path != null && mounted) {
        context.read<ChatProvider>().addAttachment(files.first.path!);
      }
    } on PlatformException catch (e) {
      debugPrint('File picker error: $e');
    } finally {
      _isPickerActive = false;
    }
  }

  Future<void> _pickDocument() async {
    if (_isPickerActive) return;
    _isPickerActive = true;
    try {
      // Delay to allow PopupMenu to dismiss completely on iOS
      await Future.delayed(const Duration(milliseconds: 300));
      final files = await FilePicker.pickFiles(type: FileType.any);
      if (files.isNotEmpty && files.first.path != null && mounted) {
        context.read<ChatProvider>().addAttachment(files.first.path!);
      }
    } on PlatformException catch (e) {
      debugPrint('File picker error: $e');
    } finally {
      _isPickerActive = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildInputArea();
  }

  Widget _buildInputArea() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).scaffoldBackgroundColor, // Match background
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Consumer<ChatProvider>(
              builder: (context, state, _) {
                final isActiveChat = state.isActiveChat;
                if (!isActiveChat) return const SizedBox.shrink();
                return PopupMenuButton<String>(
                  icon: Icon(
                    Icons.add,
                    color: isDark ? Colors.white : Colors.black,
                    size: 20,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'camera':
                        _pickImage(ImageSource.camera);
                        break;
                      case 'image':
                        _pickImage(ImageSource.gallery);
                        break;
                      case 'audio':
                        _pickAudio();
                        break;
                      case 'document':
                        _pickDocument();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'camera',
                      child: Row(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Camera',
                            style: GoogleFonts.poppins(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'image',
                      child: Row(
                        children: [
                          Icon(
                            Icons.image,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Image',
                            style: GoogleFonts.poppins(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'audio',
                      child: Row(
                        children: [
                          Icon(
                            Icons.audiotrack,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Audio',
                            style: GoogleFonts.poppins(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'document',
                      child: Row(
                        children: [
                          Icon(
                            Icons.description,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Document',
                            style: GoogleFonts.poppins(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D3748) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Consumer<ChatProvider>(
              builder: (context, state, _) {
                final attachments = state.attachments;

                if (attachments.isEmpty) return const SizedBox.shrink();

                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 4, top: 4),
                      child: Icon(
                        Icons.attach_file,
                        size: 24,
                        color: isDark ? Colors.white : const Color(0xFF001F3F),
                      ),
                    ),
                    if (attachments.isNotEmpty) ...[
                      Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${attachments.length}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            context.read<ChatProvider>().clearAttachments();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white24 : Colors.black26,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            Consumer<ChatProvider>(
              builder: (context, state, _) {
                final isInQueue = state.isInQueue;

                return isInQueue
                    ? Icon(
                        Icons.send,
                        color: isDark ? Colors.white24 : Colors.grey,
                        size: 20,
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.send,
                          color: isDark ? Colors.white : Colors.black,
                          size: 20,
                        ),
                        onPressed: _sendMessage,
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
