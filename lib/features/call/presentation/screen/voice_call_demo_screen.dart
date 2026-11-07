import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:view360_call/view360_call.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/api/call_token_api_config.dart';
import '../../data/api/token_api_service.dart';
import 'active_call_screen.dart';

class VoiceCallDemoScreen extends StatefulWidget {
  const VoiceCallDemoScreen({super.key});

  @override
  State<VoiceCallDemoScreen> createState() => _VoiceCallDemoScreenState();
}

class _VoiceCallDemoScreenState extends State<VoiceCallDemoScreen> {
  final TextEditingController _serverUrlController = TextEditingController(
    text: AppConstants.defaultLiveKitUrl,
  );
  final TextEditingController _tokenServerUrlController = TextEditingController(
    text: AppConstants.defaultTokenServerUrl,
  );
  final TextEditingController _participantNameController =
      TextEditingController(text: 'user-a');
  final TextEditingController _roomNameController = TextEditingController(
    text: 'test-room',
  );

  final _formKey = GlobalKey<FormState>();

  bool _isConnecting = false;
  View360CallStatus _connectionStatus = View360CallStatus.disconnected;
  String? _errorMessage;

  @override
  void dispose() {
    _serverUrlController.dispose();
    _tokenServerUrlController.dispose();
    _participantNameController.dispose();
    _roomNameController.dispose();
    super.dispose();
  }

  Future<void> _connectAndJoinRoom() async {
    // 1. Validate all required fields
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // 2. Set connecting and loading state
    setState(() {
      _isConnecting = true;
      _connectionStatus = View360CallStatus.connecting;
      _errorMessage = null;
    });

    final serverUrl = _serverUrlController.text.trim();
    final tokenServerUrl = _tokenServerUrlController.text.trim();
    final participantName = _participantNameController.text.trim();
    final roomName = _roomNameController.text.trim();

    // 3. Configure Token API service (separated from UI)
    final tokenApiService = TokenApiService(
      config: CallTokenApiConfig(baseUrl: tokenServerUrl),
    );

    // 4. Initialize SDK via public API
    final call = View360Call(
      config: View360CallConfig(
        serverUrl: serverUrl,
        tokenProvider: ({
          required String roomName,
          required String participantName,
        }) async {
          return await tokenApiService.requestToken(
            roomName: roomName,
            participantName: participantName,
          );
        },
      ),
    );

    try {
      // 5. Connect to room
      await call.connect(
        roomName: roomName,
        participantName: participantName,
      );

      if (!mounted) {
        call.dispose();
        return;
      }

      // 6. Navigate only after successful connection
      if (call.controller.state.status == View360CallStatus.connected) {
        setState(() {
          _connectionStatus = View360CallStatus.connected;
          _isConnecting = false;
        });

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActiveCallScreen(
              call: call,
              participantName: participantName,
              roomName: roomName,
            ),
          ),
        );

        // Reset state after returning from call screen
        if (mounted) {
          setState(() {
            _connectionStatus = View360CallStatus.disconnected;
          });
        }
      } else {
        throw Exception(call.controller.state.error ?? 'Connection failed');
      }
    } catch (e) {
      call.dispose();
      if (!mounted) return;

      // Extract clear, informative error message
      String message = e.toString().replaceFirst('Exception: ', '');
      if (message.startsWith('CallTokenApiException: ')) {
        message = message.replaceFirst('CallTokenApiException: ', '');
      } else if (message.startsWith('View360CallException: ')) {
        message = message.replaceFirst('View360CallException: ', '');
      }

      setState(() {
        _isConnecting = false;
        _connectionStatus = View360CallStatus.failed;
        _errorMessage = message;
      });
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
    final double titleFontSize = (screenWidth * 0.058).clamp(20.0, 24.0);
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
                          // Top Navigation Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (Navigator.canPop(context))
                                InkWell(
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
                                )
                              else
                                const SizedBox.shrink(),

                              // Connection status indicator
                              _buildConnectionStatusBadge(_connectionStatus),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // App Title
                          Text(
                            'View360 Call SDK Demo',
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
                            'Configure your connection to join a LiveKit room using the view360_call SDK.',
                            style: GoogleFonts.inter(
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF64748B),
                              height: 1.3,
                            ),
                          ),
                          SizedBox(
                            height: (screenHeight * 0.03).clamp(18.0, 28.0),
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
                          const SizedBox(height: 14),

                          // 1. LiveKit Server URL Field
                          _buildInputField(
                            label: 'LiveKit Server URL',
                            controller: _serverUrlController,
                            labelFontSize: labelFontSize,
                            hintText: 'ws://127.0.0.1:7880',
                            enabled: !_isConnecting,
                            validator: (val) {
                              final text = val?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'LiveKit server URL is required';
                              }
                              final uri = Uri.tryParse(text);
                              if (uri == null ||
                                  (!uri.scheme.startsWith('ws') &&
                                      !uri.scheme.startsWith('http'))) {
                                return 'Enter a valid URL (e.g. ws:// or wss://)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 2. Node.js Token API URL Field
                          _buildInputField(
                            label: 'Node.js Token API URL',
                            controller: _tokenServerUrlController,
                            labelFontSize: labelFontSize,
                            hintText: 'http://127.0.0.1:3000',
                            helperText:
                                'Backend endpoint generating LiveKit JWT tokens (POST /token)',
                            enabled: !_isConnecting,
                            validator: (val) {
                              final text = val?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Node.js token API URL is required';
                              }
                              final uri = Uri.tryParse(text);
                              if (uri == null ||
                                  (!uri.scheme.startsWith('http'))) {
                                return 'Enter a valid HTTP/HTTPS URL (e.g. http://127.0.0.1:3000)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 3. Participant Name Field
                          _buildInputField(
                            label: 'Participant Name',
                            controller: _participantNameController,
                            labelFontSize: labelFontSize,
                            hintText: 'user-a',
                            enabled: !_isConnecting,
                            validator: (val) {
                              final text = val?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Participant name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 4. Room Name Field
                          _buildInputField(
                            label: 'Room Name',
                            controller: _roomNameController,
                            labelFontSize: labelFontSize,
                            hintText: 'test-room',
                            enabled: !_isConnecting,
                            validator: (val) {
                              final text = val?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Room name is required';
                              }
                              return null;
                            },
                          ),

                          // Display Useful Error Messages
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 18),
                            _buildErrorBanner(_errorMessage!),
                          ],

                          const Spacer(),
                          const SizedBox(height: 24),

                          // Connect Button
                          SizedBox(
                            width: double.infinity,
                            height: buttonHeight,
                            child: ElevatedButton(
                              onPressed:
                                  _isConnecting ? null : _connectAndJoinRoom,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                disabledBackgroundColor:
                                    const Color(0xFF93C5FD),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: const Color(0xFF2563EB)
                                    .withValues(alpha: 0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isConnecting
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Connecting to Room...',
                                          style: GoogleFonts.inter(
                                            fontSize: (screenWidth * 0.042)
                                                .clamp(15.0, 16.5),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.2,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'Connect & Join Room',
                                      style: GoogleFonts.inter(
                                        fontSize: (screenWidth * 0.042)
                                            .clamp(15.0, 16.5),
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

  Widget _buildConnectionStatusBadge(View360CallStatus status) {
    Color bg;
    Color border;
    Color text;
    String label;
    Widget? leading;

    switch (status) {
      case View360CallStatus.connected:
        bg = const Color(0xFFDCFCE7);
        border = const Color(0xFFBBF7D0);
        text = const Color(0xFF15803D);
        label = 'Connected';
        leading = Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Color(0xFF16A34A),
            shape: BoxShape.circle,
          ),
        );
        break;
      case View360CallStatus.connecting:
      case View360CallStatus.reconnecting:
        bg = const Color(0xFFFEF3C7);
        border = const Color(0xFFFDE68A);
        text = const Color(0xFFD97706);
        label = 'Connecting...';
        leading = const SizedBox(
          width: 9,
          height: 9,
          child: CircularProgressIndicator(
            strokeWidth: 1.8,
            color: Color(0xFFD97706),
          ),
        );
        break;
      case View360CallStatus.failed:
        bg = const Color(0xFFFEE2E2);
        border = const Color(0xFFFECACA);
        text = const Color(0xFFDC2626);
        label = 'Failed';
        leading = const Icon(
          Icons.error_outline_rounded,
          size: 13,
          color: Color(0xFFDC2626),
        );
        break;
      case View360CallStatus.disconnecting:
        bg = const Color(0xFFF1F5F9);
        border = const Color(0xFFE2E8F0);
        text = const Color(0xFF64748B);
        label = 'Disconnecting...';
        break;
      case View360CallStatus.disconnected:
        bg = const Color(0xFFF1F5F9);
        border = const Color(0xFFCBD5E1);
        text = const Color(0xFF64748B);
        label = 'Disconnected';
        leading = Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Color(0xFF94A3B8),
            shape: BoxShape.circle,
          ),
        );
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading,
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFDC2626),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connection Error',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF991B1B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFB91C1C),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required double labelFontSize,
    required String hintText,
    String? helperText,
    bool enabled = true,
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
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          validator: validator,
          style: GoogleFonts.inter(
            fontSize: (labelFontSize + 1).clamp(14.0, 15.5),
            fontWeight: FontWeight.w500,
            color: enabled ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
          ),
          cursorColor: const Color(0xFF2563EB),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            helperText: helperText,
            helperMaxLines: 2,
            helperStyle: GoogleFonts.inter(
              fontSize: 11.5,
              color: const Color(0xFF64748B),
            ),
            hintStyle: GoogleFonts.inter(
              fontSize: (labelFontSize + 1).clamp(14.0, 15.5),
              color: const Color(0xFF94A3B8),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
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
            disabledBorder: OutlineInputBorder(
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
