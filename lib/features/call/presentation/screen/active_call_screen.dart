import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActiveCallScreen extends StatefulWidget {
  final String serverUrl;
  final String participantName;
  final String roomName;
  final int initialSeconds;

  const ActiveCallScreen({
    super.key,
    this.serverUrl = 'ws://127.0.0.1:7880',
    this.participantName = 'User A',
    this.roomName = 'test-room',
    this.initialSeconds = 332, // 05:32 as shown in the screenshot
  });

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen> {
  late int _durationInSeconds;
  Timer? _callTimer;
  bool _isMuted = true;
  bool _isSpeakerOn = true;

  @override
  void initState() {
    super.initState();
    _durationInSeconds = widget.initialSeconds;
    _startTimer();
  }

  void _startTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _durationInSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isMuted ? 'Microphone muted' : 'Microphone unmuted',
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
        ),
        duration: const Duration(milliseconds: 900),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSpeakerOn ? 'Speaker enabled' : 'Earpiece enabled',
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
        ),
        duration: const Duration(milliseconds: 900),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _endCall() {
    _callTimer?.cancel();
    Navigator.of(context).pop();
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

    // Responsive sizing
    final double mainAvatarSize = (screenHeight * 0.12).clamp(84.0, 108.0);
    final double mainAvatarFontSize = (mainAvatarSize * 0.38).clamp(28.0, 38.0);
    final double titleFontSize = (screenWidth * 0.058).clamp(20.0, 24.0);
    final double timerFontSize = (screenWidth * 0.09).clamp(32.0, 40.0);
    final double controlButtonSize = (screenWidth * 0.16).clamp(56.0, 68.0);
    final double controlIconSize = (controlButtonSize * 0.42).clamp(24.0, 28.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Top Bar: App Title and Connected Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (Navigator.canPop(context)) ...[
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 15,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                              Text(
                                'View360Call',
                                style: GoogleFonts.inter(
                                  fontSize: (screenWidth * 0.048).clamp(18.0, 21.0),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFBBF7D0),
                              ),
                            ),
                            child: Text(
                              'Connected',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: (screenHeight * 0.035).clamp(20.0, 36.0)),

                      // Main Caller Avatar
                      Container(
                        width: mainAvatarSize,
                        height: mainAvatarSize,
                        decoration: BoxDecoration(
                          color: const Color(0xFF334155),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF334155).withValues(alpha: 0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.participantName.isNotEmpty
                              ? widget.participantName[0].toUpperCase()
                              : 'A',
                          style: GoogleFonts.inter(
                            fontSize: mainAvatarFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // User Name
                      Text(
                        widget.participantName,
                        style: GoogleFonts.inter(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Connection Status / Room Name
                      Text(
                        'Connected to ${widget.roomName}',
                        style: GoogleFonts.inter(
                          fontSize: (screenWidth * 0.036).clamp(13.0, 14.5),
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: (screenHeight * 0.025).clamp(16.0, 24.0)),

                      // Call Duration (Live Ticking Timer)
                      Text(
                        _formatDuration(_durationInSeconds),
                        style: GoogleFonts.inter(
                          fontSize: timerFontSize,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Duration Label
                      Text(
                        'Call duration',
                        style: GoogleFonts.inter(
                          fontSize: (screenWidth * 0.034).clamp(12.0, 13.5),
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: (screenHeight * 0.035).clamp(24.0, 36.0)),

                      // Participants Card
                      _buildParticipantsCard(screenWidth),

                      const Spacer(),
                      SizedBox(height: (screenHeight * 0.03).clamp(20.0, 32.0)),

                      // Bottom Call Controls (Mute, Speaker, End Call)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Mute Button
                          _buildControlButton(
                            size: controlButtonSize,
                            iconSize: controlIconSize,
                            backgroundColor: _isMuted
                                ? const Color(0xFFE2E8F0)
                                : const Color(0xFFF1F5F9),
                            borderColor: const Color(0xFFCBD5E1),
                            icon: _isMuted
                                ? Icons.mic_off_rounded
                                : Icons.mic_rounded,
                            iconColor: const Color(0xFF334155),
                            onTap: _toggleMute,
                          ),
                          const SizedBox(width: 22),

                          // Speaker Button
                          _buildControlButton(
                            size: controlButtonSize,
                            iconSize: controlIconSize,
                            backgroundColor: _isSpeakerOn
                                ? const Color(0xFFE2E8F0)
                                : const Color(0xFFF1F5F9),
                            borderColor: const Color(0xFFCBD5E1),
                            icon: _isSpeakerOn
                                ? Icons.volume_up_rounded
                                : Icons.volume_down_rounded,
                            iconColor: const Color(0xFF334155),
                            onTap: _toggleSpeaker,
                          ),
                          const SizedBox(width: 22),

                          // End Call Button
                          _buildControlButton(
                            size: controlButtonSize,
                            iconSize: controlIconSize,
                            backgroundColor: const Color(0xFFEF4444),
                            icon: Icons.call_end_rounded,
                            iconColor: Colors.white,
                            hasShadow: true,
                            onTap: _endCall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Controls Subtext Label
                      Text(
                        'Mute · Speaker · End Call',
                        style: GoogleFonts.inter(
                          fontSize: (screenWidth * 0.034).clamp(12.0, 13.5),
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildParticipantsCard(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Participants',
                style: GoogleFonts.inter(
                  fontSize: (screenWidth * 0.042).clamp(15.0, 16.5),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFBBF7D0),
                  ),
                ),
                child: Text(
                  '2 online',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Participant 1: User A (You)
          _buildParticipantTile(
            initial: widget.participantName.isNotEmpty
                ? widget.participantName[0].toUpperCase()
                : 'A',
            name: widget.participantName,
            role: 'You',
            screenWidth: screenWidth,
          ),

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(
              color: Color(0xFFF1F5F9),
              height: 1,
              thickness: 1,
            ),
          ),

          // Participant 2: User B (Remote participant)
          _buildParticipantTile(
            initial: 'B',
            name: 'User B',
            role: 'Remote participant',
            screenWidth: screenWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantTile({
    required String initial,
    required String name,
    required String role,
    required double screenWidth,
  }) {
    return Row(
      children: [
        // Small Circle Avatar
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Color(0xFF334155),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Name and Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: (screenWidth * 0.038).clamp(14.0, 15.5),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                role,
                style: GoogleFonts.inter(
                  fontSize: (screenWidth * 0.033).clamp(12.0, 13.0),
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),

        // Green Mic Icon
        const Icon(
          Icons.mic,
          color: Color(0xFF16A34A),
          size: 20,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required double size,
    required double iconSize,
    required Color backgroundColor,
    Color? borderColor,
    required IconData icon,
    required Color iconColor,
    bool hasShadow = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1)
                : null,
            boxShadow: hasShadow
                ? [
                    BoxShadow(
                      color: backgroundColor.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
