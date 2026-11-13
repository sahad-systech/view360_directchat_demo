// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:view360_call/view360_call.dart';

// /// Screen 2: Active Voice Call
// ///
// /// Clean, modern dark voice-only interface demonstrating live call lifecycle,
// /// reactive state synchronization, call timer, and mute/unmute control.
// class ActiveCallScreen extends StatefulWidget {
//   final View360Call call;
//   final String participantName;
//   final String roomName;

//   const ActiveCallScreen({
//     super.key,
//     required this.call,
//     required this.participantName,
//     required this.roomName,
//   });

//   @override
//   State<ActiveCallScreen> createState() => _ActiveCallScreenState();
// }

// class _ActiveCallScreenState extends State<ActiveCallScreen>
//     with SingleTickerProviderStateMixin {
//   int _durationInSeconds = 0;
//   Timer? _callTimer;
//   late final AnimationController _pulseController;
//   late final Animation<double> _pulseAnimation;

//   /// The view360_call SDK currently only implements connect, mute, unmute,
//   /// and disconnect. Audio speaker routing is not yet implemented in the SDK.
//   /// Per requirements: "Speaker button, but only if supported by the SDK".
//   static const bool _isSpeakerSupportedBySdk = false;

//   @override
//   void initState() {
//     super.initState();

//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1800),
//     )..repeat(reverse: true);

//     _pulseAnimation = Tween<double>(begin: 0.96, end: 1.05).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );

//     widget.call.controller.addListener(_onCallStateChanged);

//     // If call is already connected (normal flow from Screen 1), start the timer
//     if (widget.call.controller.state.status == View360CallStatus.connected) {
//       _startTimer();
//     }
//   }

//   void _onCallStateChanged() {
//     if (!mounted) return;
//     final state = widget.call.controller.state;

//     if (state.status == View360CallStatus.connected) {
//       if (_callTimer == null) {
//         _startTimer();
//       }
//     } else if (state.status == View360CallStatus.disconnected ||
//         state.status == View360CallStatus.failed) {
//       _callTimer?.cancel();
//       _callTimer = null;
//     }

//     setState(() {});
//   }

//   void _startTimer() {
//     _callTimer?.cancel();
//     _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (mounted) {
//         setState(() {
//           _durationInSeconds++;
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _callTimer?.cancel();
//     _pulseController.dispose();
//     widget.call.controller.removeListener(_onCallStateChanged);
//     widget.call.dispose();
//     super.dispose();
//   }

//   String _formatDuration(int totalSeconds) {
//     final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
//     final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
//     return '$minutes:$seconds';
//   }

//   Future<void> _toggleMute() async {
//     final isMuted = widget.call.controller.state.isMuted;
//     try {
//       if (isMuted) {
//         await widget.call.unmute();
//       } else {
//         await widget.call.mute();
//       }
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             widget.call.controller.state.isMuted
//                 ? 'Microphone muted'
//                 : 'Microphone unmuted',
//             style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
//           ),
//           duration: const Duration(milliseconds: 900),
//           backgroundColor: const Color(0xFF1E293B),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Failed to change microphone state: $e',
//             style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
//           ),
//           backgroundColor: const Color(0xFFDC2626),
//         ),
//       );
//     }
//   }

//   Future<void> _endCall() async {
//     _callTimer?.cancel();
//     try {
//       await widget.call.disconnect();
//     } catch (_) {}
//     if (mounted) {
//       Navigator.of(context).pop();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final callState = widget.call.controller.state;
//     final mediaQuery = MediaQuery.of(context);
//     final screenWidth = mediaQuery.size.width;
//     final screenHeight = mediaQuery.size.height;

//     final double horizontalPadding = screenWidth > 600
//         ? (screenWidth - 460) / 2
//         : (screenWidth * 0.06).clamp(18.0, 28.0);

//     final double avatarSize = (screenHeight * 0.15).clamp(96.0, 124.0);
//     final double avatarFontSize = (avatarSize * 0.38).clamp(36.0, 48.0);
//     final double titleFontSize = (screenWidth * 0.062).clamp(22.0, 26.0);
//     final double timerFontSize = (screenWidth * 0.11).clamp(36.0, 48.0);
//     final double controlButtonSize = (screenWidth * 0.18).clamp(62.0, 74.0);

//     return Scaffold(
//       backgroundColor: const Color(0xFF0B0F19), // Deep dark theme background
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               physics: const ClampingScrollPhysics(),
//               padding: EdgeInsets.symmetric(
//                 horizontal: horizontalPadding,
//                 vertical: 18.0,
//               ),
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   minHeight: constraints.maxHeight - 36,
//                 ),
//                 child: IntrinsicHeight(
//                   child: Column(
//                     children: [
//                       // Top Bar: Back & Connection Status Indicator
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           InkWell(
//                             onTap: () => Navigator.of(context).maybePop(),
//                             borderRadius: BorderRadius.circular(10),
//                             child: Container(
//                               padding: const EdgeInsets.all(9),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF1E293B),
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(
//                                   color: const Color(0xFF334155),
//                                 ),
//                               ),
//                               child: const Icon(
//                                 Icons.arrow_back_ios_new_rounded,
//                                 size: 15,
//                                 color: Color(0xFFE2E8F0),
//                               ),
//                             ),
//                           ),
//                           _buildConnectionBadge(callState.status),
//                         ],
//                       ),

//                       SizedBox(height: (screenHeight * 0.04).clamp(24.0, 42.0)),

//                       // Main Voice Caller Avatar with Audio Pulse Ring
//                       Center(
//                         child: AnimatedBuilder(
//                           animation: _pulseAnimation,
//                           builder: (context, child) {
//                             final isConnected =
//                                 callState.status == View360CallStatus.connected;
//                             return Transform.scale(
//                               scale: isConnected ? _pulseAnimation.value : 1.0,
//                               child: Container(
//                                 width: avatarSize + 28,
//                                 height: avatarSize + 28,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   gradient: RadialGradient(
//                                     colors: isConnected
//                                         ? [
//                                             const Color(
//                                               0xFF2563EB,
//                                             ).withValues(alpha: 0.25),
//                                             const Color(
//                                               0xFF2563EB,
//                                             ).withValues(alpha: 0.02),
//                                           ]
//                                         : [
//                                             const Color(
//                                               0xFF334155,
//                                             ).withValues(alpha: 0.2),
//                                             Colors.transparent,
//                                           ],
//                                   ),
//                                 ),
//                                 alignment: Alignment.center,
//                                 child: Container(
//                                   width: avatarSize,
//                                   height: avatarSize,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFF1E293B),
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       color: isConnected
//                                           ? const Color(0xFF3B82F6)
//                                           : const Color(0xFF475569),
//                                       width: 2.2,
//                                     ),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: isConnected
//                                             ? const Color(
//                                                 0xFF3B82F6,
//                                               ).withValues(alpha: 0.3)
//                                             : Colors.black.withValues(
//                                                 alpha: 0.4,
//                                               ),
//                                         blurRadius: 20,
//                                         offset: const Offset(0, 8),
//                                       ),
//                                     ],
//                                   ),
//                                   alignment: Alignment.center,
//                                   child: Text(
//                                     widget.participantName.isNotEmpty
//                                         ? widget.participantName[0]
//                                               .toUpperCase()
//                                         : 'A',
//                                     style: GoogleFonts.inter(
//                                       fontSize: avatarFontSize,
//                                       fontWeight: FontWeight.w700,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       const SizedBox(height: 18),

//                       // Current Participant Name
//                       Text(
//                         widget.participantName,
//                         style: GoogleFonts.inter(
//                           fontSize: titleFontSize,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white,
//                           letterSpacing: -0.4,
//                         ),
//                       ),
//                       const SizedBox(height: 8),

//                       // Room Name with icon
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF1E293B),
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(color: const Color(0xFF334155)),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(
//                               Icons.meeting_room_outlined,
//                               size: 14,
//                               color: Color(0xFF94A3B8),
//                             ),
//                             const SizedBox(width: 6),
//                             Text(
//                               'Room: ${widget.roomName}',
//                               style: GoogleFonts.inter(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xFFCBD5E1),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       SizedBox(height: (screenHeight * 0.03).clamp(20.0, 32.0)),

//                       // Call Duration Timer
//                       Text(
//                         _formatDuration(_durationInSeconds),
//                         style: GoogleFonts.jetBrainsMono(
//                           fontSize: timerFontSize,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white,
//                           letterSpacing: 1.5,
//                         ),
//                       ),
//                       const SizedBox(height: 6),

//                       // State Subtext description
//                       Text(
//                         _getStatusDescription(callState.status),
//                         style: GoogleFonts.inter(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w400,
//                           color: const Color(0xFF94A3B8),
//                         ),
//                       ),

//                       // Error message container (if connection failed)
//                       if (callState.error != null ||
//                           callState.status == View360CallStatus.failed) ...[
//                         const SizedBox(height: 18),
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: const Color(
//                               0xFF450A0A,
//                             ).withValues(alpha: 0.6),
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(color: const Color(0xFF991B1B)),
//                           ),
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.error_outline_rounded,
//                                 color: Color(0xFFF87171),
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: Text(
//                                   callState.error ?? 'Connection failed.',
//                                   style: GoogleFonts.inter(
//                                     fontSize: 12.5,
//                                     color: const Color(0xFFFCA5A5),
//                                     height: 1.3,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],

//                       const Spacer(),
//                       SizedBox(height: (screenHeight * 0.04).clamp(24.0, 40.0)),

//                       // Bottom Call Controls (Mute/Unmute, End Call)
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           // 1. Mute / Unmute Button
//                           _buildVoiceControlButton(
//                             size: controlButtonSize,
//                             icon: callState.isMuted
//                                 ? Icons.mic_off_rounded
//                                 : Icons.mic_rounded,
//                             iconColor: callState.isMuted
//                                 ? const Color(0xFFF87171)
//                                 : Colors.white,
//                             backgroundColor: callState.isMuted
//                                 ? const Color(0xFF7F1D1D)
//                                 : const Color(0xFF1E293B),
//                             borderColor: callState.isMuted
//                                 ? const Color(0xFFDC2626)
//                                 : const Color(0xFF334155),
//                             label: callState.isMuted ? 'Unmute' : 'Mute',
//                             enabled:
//                                 callState.status == View360CallStatus.connected,
//                             onTap: _toggleMute,
//                           ),

//                           // 2. Speaker Button (Rendered ONLY if supported by the SDK)
//                           if (_isSpeakerSupportedBySdk) ...[
//                             const SizedBox(width: 28),
//                             _buildVoiceControlButton(
//                               size: controlButtonSize,
//                               icon: Icons.volume_up_rounded,
//                               iconColor: Colors.white,
//                               backgroundColor: const Color(0xFF1E293B),
//                               borderColor: const Color(0xFF334155),
//                               label: 'Speaker',
//                               onTap: () {},
//                             ),
//                           ],

//                           const SizedBox(width: 28),

//                           // 3. End Call Button
//                           _buildVoiceControlButton(
//                             size: controlButtonSize,
//                             icon: Icons.call_end_rounded,
//                             iconColor: Colors.white,
//                             backgroundColor: const Color(0xFFDC2626),
//                             borderColor: const Color(0xFFEF4444),
//                             hasGlow: true,
//                             label: 'End Call',
//                             onTap: _endCall,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   /// Status badge widget representing all 5 SDK connection states:
//   /// Connecting, Connected, Reconnecting, Disconnected, Connection failed.
//   Widget _buildConnectionBadge(View360CallStatus status) {
//     Color bg;
//     Color border;
//     Color textColor;
//     String label;
//     Widget? leading;

//     switch (status) {
//       case View360CallStatus.connected:
//         bg = const Color(0xFF064E3B);
//         border = const Color(0xFF059669);
//         textColor = const Color(0xFF34D399);
//         label = 'Connected';
//         leading = Container(
//           width: 7,
//           height: 7,
//           decoration: const BoxDecoration(
//             color: Color(0xFF34D399),
//             shape: BoxShape.circle,
//           ),
//         );
//         break;

//       case View360CallStatus.connecting:
//         bg = const Color(0xFF451A03);
//         border = const Color(0xFFD97706);
//         textColor = const Color(0xFFFBBF24);
//         label = 'Connecting';
//         leading = const SizedBox(
//           width: 9,
//           height: 9,
//           child: CircularProgressIndicator(
//             strokeWidth: 1.8,
//             color: Color(0xFFFBBF24),
//           ),
//         );
//         break;

//       case View360CallStatus.reconnecting:
//         bg = const Color(0xFF451A03);
//         border = const Color(0xFFEA580C);
//         textColor = const Color(0xFFFB923C);
//         label = 'Reconnecting';
//         leading = const SizedBox(
//           width: 9,
//           height: 9,
//           child: CircularProgressIndicator(
//             strokeWidth: 1.8,
//             color: Color(0xFFFB923C),
//           ),
//         );
//         break;

//       case View360CallStatus.disconnecting:
//         bg = const Color(0xFF1E293B);
//         border = const Color(0xFF475569);
//         textColor = const Color(0xFF94A3B8);
//         label = 'Disconnecting';
//         break;

//       case View360CallStatus.failed:
//         bg = const Color(0xFF450A0A);
//         border = const Color(0xFFDC2626);
//         textColor = const Color(0xFFF87171);
//         label = 'Connection Failed';
//         leading = const Icon(
//           Icons.error_outline_rounded,
//           size: 13,
//           color: Color(0xFFF87171),
//         );
//         break;

//       case View360CallStatus.disconnected:
//         bg = const Color(0xFF1E293B);
//         border = const Color(0xFF334155);
//         textColor = const Color(0xFF94A3B8);
//         label = 'Disconnected';
//         leading = Container(
//           width: 7,
//           height: 7,
//           decoration: const BoxDecoration(
//             color: Color(0xFF64748B),
//             shape: BoxShape.circle,
//           ),
//         );
//         break;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: border),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (leading != null) ...[leading, const SizedBox(width: 7)],
//           Text(
//             label,
//             style: GoogleFonts.inter(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: textColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getStatusDescription(View360CallStatus status) {
//     switch (status) {
//       case View360CallStatus.connected:
//         return 'Voice call active';
//       case View360CallStatus.connecting:
//         return 'Connecting to voice room...';
//       case View360CallStatus.reconnecting:
//         return 'Reconnecting voice stream...';
//       case View360CallStatus.disconnecting:
//         return 'Disconnecting from call...';
//       case View360CallStatus.failed:
//         return 'Call failed to establish';
//       case View360CallStatus.disconnected:
//         return 'Call ended';
//     }
//   }

//   Widget _buildVoiceControlButton({
//     required double size,
//     required IconData icon,
//     required Color iconColor,
//     required Color backgroundColor,
//     required Color borderColor,
//     required String label,
//     required VoidCallback onTap,
//     bool hasGlow = false,
//     bool enabled = true,
//   }) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: enabled ? onTap : null,
//             borderRadius: BorderRadius.circular(size / 2),
//             child: Opacity(
//               opacity: enabled ? 1.0 : 0.45,
//               child: Container(
//                 width: size,
//                 height: size,
//                 decoration: BoxDecoration(
//                   color: backgroundColor,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: borderColor, width: 1.5),
//                   boxShadow: hasGlow
//                       ? [
//                           BoxShadow(
//                             color: backgroundColor.withValues(alpha: 0.45),
//                             blurRadius: 18,
//                             offset: const Offset(0, 6),
//                           ),
//                         ]
//                       : [
//                           BoxShadow(
//                             color: Colors.black.withValues(alpha: 0.3),
//                             blurRadius: 8,
//                             offset: const Offset(0, 3),
//                           ),
//                         ],
//                 ),
//                 child: Icon(icon, color: iconColor, size: size * 0.44),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           style: GoogleFonts.inter(
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//             color: enabled ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
//           ),
//         ),
//       ],
//     );
//   }
// }
