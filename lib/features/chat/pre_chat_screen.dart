import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:view360_direct_chat_example/features/chat/chat_screen.dart';
import 'package:view360_direct_chat_example/features/chat/presentation/providers/chat_provider.dart';

class PreChatScreen extends StatefulWidget {
  const PreChatScreen({super.key});

  @override
  State<PreChatScreen> createState() => _PreChatScreenState();
}

class _PreChatScreenState extends State<PreChatScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Test User',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'test@gmail.com',
  );
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController(
    text: 'Halo',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const _HeaderSection(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Let\'s Start a Conversation',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B1B2F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please introduce yourself to start a conversation\nwith our support team.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF6C7293),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form Fields
                  _InputField(
                    label: 'Full Name',
                    hintText: 'John Doe',
                    icon: Icons.person_outline_rounded,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 20),
                  _InputField(
                    label: 'Email Address',
                    hintText: 'john@example.com',
                    icon: Icons.email_outlined,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),
                  _InputField(
                    label: 'Mobile Number',
                    hintText: '+1234567890',
                    icon: Icons.phone_outlined,
                    controller: _phoneController,
                  ),
                  const SizedBox(height: 20),
                  _InputField(
                    label: 'First Message',
                    hintText: 'How can we help you today?',
                    icon: Icons.chat_bubble_outline_rounded,
                    isMultiline: true,
                    controller: _messageController,
                  ),
                  const SizedBox(height: 32),

                  Consumer<ChatProvider>(
                    builder: (context, provider, child) {
                      return GestureDetector(
                        onTap: provider.isLoading
                            ? null
                            : () async {
                                final message = _messageController.text;
                                final name = _nameController.text;
                                final email = _emailController.text;
                                final phone = _phoneController.text;

                                if (message.isNotEmpty &&
                                    name.isNotEmpty &&
                                    (email.isNotEmpty || phone.isNotEmpty)) {
                                  final success = await context
                                      .read<ChatProvider>()
                                      .createSession(
                                        name: name,
                                        email: email,
                                        phone: phone,
                                        firstMessage: message,
                                      );

                                  if (success && mounted) {
                                    await context
                                        .read<ChatProvider>()
                                        .fetchHistory('');
                                    if (mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ChatScreen(),
                                        ),
                                      );
                                    }
                                  } else if (mounted) {
                                    final error = context
                                        .read<ChatProvider>()
                                        .errorMessage;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          error ??
                                              'Failed to start conversation',
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please fill out name, message, and either email or phone.',
                                      ),
                                    ),
                                  );
                                }
                              },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6A5AE0), Color(0xFF4B39C7)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF6A5AE0,
                                ).withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: provider.isLoading
                              ? const Center(
                                  child: SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Start Conversation',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Footer Security Notice
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 14,
                        color: Color(0xFF6C7293),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Your information is safe with us.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6C7293),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        width: double.infinity,
        height: 260,
        decoration: const BoxDecoration(color: Color(0xFF1B2342)),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Top Right Chat Illustration
              Positioned(
                top: 20,
                right: 20,
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6A5AE0),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(8),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF6A5AE0,
                                ).withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.more_horiz_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -5,
                        right: 15,
                        child: Row(
                          children: [
                            Container(
                              width: 3,
                              height: 10,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 3,
                              height: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Profile and Info
              Positioned(
                bottom: 60,
                left: 24,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 2,
                            ),
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF1B2342),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Support',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'We are online',
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4CAF50,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Typically replies in a few minutes',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF4CAF50),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 60);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstPoint = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstPoint.dx,
      firstPoint.dy,
    );

    var secondControlPoint = Offset(
      size.width - (size.width / 4),
      size.height - 60,
    );
    var secondPoint = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondPoint.dx,
      secondPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _InputField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final bool isMultiline;
  final TextEditingController? controller;

  const _InputField({
    required this.label,
    required this.hintText,
    required this.icon,
    this.isMultiline = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF4A4E69),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E6FC)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: isMultiline ? 4 : 1,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                color: const Color(0xFF9EA3BA),
                fontSize: 14,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: isMultiline ? 60 : 0),
                child: Icon(icon, color: const Color(0xFF9EA3BA), size: 20),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        if (isMultiline) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '0/500',
              style: GoogleFonts.inter(
                color: const Color(0xFF9EA3BA),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
