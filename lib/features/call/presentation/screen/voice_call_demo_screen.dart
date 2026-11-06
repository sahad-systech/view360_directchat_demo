import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'active_call_screen.dart';

class VoiceCallDemoScreen extends StatefulWidget {
  const VoiceCallDemoScreen({super.key});

  @override
  State<VoiceCallDemoScreen> createState() => _VoiceCallDemoScreenState();
}

class _VoiceCallDemoScreenState extends State<VoiceCallDemoScreen> {
  final TextEditingController _serverUrlController = TextEditingController(
    text: 'ws://127.0.0.1:7880',
  );
  final TextEditingController _participantNameController =
      TextEditingController(text: 'user-a');
  final TextEditingController _roomNameController = TextEditingController(
    text: 'test-room',
  );

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _serverUrlController.dispose();
    _participantNameController.dispose();
    _roomNameController.dispose();
    super.dispose();
  }

  void _connectAndJoinRoom() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActiveCallScreen(
            serverUrl: _serverUrlController.text.trim(),
            participantName: _participantNameController.text.trim().isEmpty
                ? 'User A'
                : _participantNameController.text.trim(),
            roomName: _roomNameController.text.trim().isEmpty
                ? 'test-room'
                : _roomNameController.text.trim(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Responsive horizontal padding based on screen width
    final double horizontalPadding = screenWidth > 600
        ? (screenWidth - 480) / 2
        : (screenWidth * 0.05).clamp(16.0, 24.0);

    // Responsive font sizes and element scaling
    final double titleFontSize = (screenWidth * 0.06).clamp(20.0, 25.0);
    final double subtitleFontSize = (screenWidth * 0.038).clamp(13.0, 15.0);
    final double sectionFontSize = (screenWidth * 0.042).clamp(15.0, 17.0);
    final double labelFontSize = (screenWidth * 0.036).clamp(13.0, 14.5);
    final double buttonHeight = (screenHeight * 0.065).clamp(48.0, 54.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20.0,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back Button Row (if can pop)
                          if (Navigator.canPop(context)) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.03,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 16,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Page Title
                          Text(
                            'Voice Call Demo',
                            style: GoogleFonts.inter(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Subtitle
                          Text(
                            'Connect to your LiveKit server and join a room.',
                            style: GoogleFonts.inter(
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF64748B),
                              height: 1.3,
                            ),
                          ),
                          SizedBox(
                            height: (screenHeight * 0.035).clamp(20.0, 36.0),
                          ),

                          // Section Title: Server Configuration
                          Text(
                            'Server Configuration',
                            style: GoogleFonts.inter(
                              fontSize: sectionFontSize,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // LiveKit Server URL Input
                          _buildInputField(
                            label: 'LiveKit Server URL',
                            controller: _serverUrlController,
                            labelFontSize: labelFontSize,
                            hintText: 'ws://127.0.0.1:7880',
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Server URL cannot be empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Participant Name Input
                          _buildInputField(
                            label: 'Participant Name',
                            controller: _participantNameController,
                            labelFontSize: labelFontSize,
                            hintText: 'user-a',
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Participant name cannot be empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Room Name Input
                          _buildInputField(
                            label: 'Room Name',
                            controller: _roomNameController,
                            labelFontSize: labelFontSize,
                            hintText: 'test-room',
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Room name cannot be empty';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: (screenHeight * 0.04).clamp(24.0, 40.0),
                          ),

                          // Connection Status Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Connection status',
                                style: GoogleFonts.inter(
                                  fontSize: labelFontSize,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFBBF7D0),
                                  ),
                                ),
                                child: Text(
                                  'Disconnected',
                                  style: GoogleFonts.inter(
                                    fontSize: (labelFontSize - 1).clamp(
                                      11.0,
                                      13.0,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF15803D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Connect & Join Room Button
                          SizedBox(
                            width: double.infinity,
                            height: buttonHeight,
                            child: ElevatedButton(
                              onPressed: _connectAndJoinRoom,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: const Color(
                                  0xFF2563EB,
                                ).withValues(alpha: 0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Connect & Join Room',
                                style: GoogleFonts.inter(
                                  fontSize: (screenWidth * 0.042).clamp(
                                    15.0,
                                    16.5,
                                  ),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required double labelFontSize,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          style: GoogleFonts.inter(
            fontSize: (labelFontSize + 1).clamp(14.0, 15.5),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF0F172A),
          ),
          cursorColor: const Color(0xFF2563EB),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              fontSize: (labelFontSize + 1).clamp(14.0, 15.5),
              color: const Color(0xFF94A3B8),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF2563EB),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
