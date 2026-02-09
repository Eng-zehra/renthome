import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'dart:convert';

class MessagesTab extends StatefulWidget {
  const MessagesTab({super.key});

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  List<dynamic> _conversations = [];
  bool _isLoading = false;
  int? _adminId;

  @override
  void initState() {
    super.initState();
    _loadAdminId();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/messages/conversations');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _conversations = data;
        });
      }
    } catch (e) {
      debugPrint('Error loading conversations: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAdminId() async {
    try {
      final response = await ApiService.get('/messages/admin');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _adminId = data['adminId'];
        });
      }
    } catch (e) {
      debugPrint('Error loading admin ID: $e');
    }
  }

  void _contactAdmin() {
    if (_adminId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            name: 'Admin Support',
            avatarUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
            receiverId: _adminId!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LineIcons.headset),
            onPressed: _contactAdmin,
            tooltip: 'Contact Support',
          ),
          IconButton(
            icon: const Icon(LineIcons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : _conversations.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LineIcons.comment, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('No messages yet', style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey)),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _conversations.length,
                itemBuilder: (context, index) {
                  final conv = _conversations[index];
                  return _buildChatItem(
                    context,
                    conv['other_user_name'] ?? 'User',
                    conv['last_message'] ?? '',
                    _formatTime(conv['last_message_time']),
                    conv['other_user_avatar'] ?? 'https://randomuser.me/api/portraits/lego/1.jpg',
                    receiverId: conv['other_user_id'],
                    isRead: (conv['unread_count'] ?? 0) == 0,
                  );
                },
              ),
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      
      if (diff.inDays > 0) {
        return '${diff.inDays}d ago';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h ago';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  Widget _buildChatItem(BuildContext context, String name, String message, String time, String img, {required int receiverId, bool isRead = true}) {
    return InkWell(
      onTap: () => _openChatScreen(context, name, img, receiverId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(img),
                  onBackgroundImageError: (_, __) {},
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                if (!isRead)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D64FF),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.outfit(
                          fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isRead ? Colors.grey[600] : Colors.black,
                      fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChatScreen(BuildContext context, String name, String img, int? receiverId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(name: name, avatarUrl: img, receiverId: receiverId),
      ),
    ).then((_) => _loadConversations()); // Refresh list when returning
  }
}

class ChatScreen extends StatefulWidget {
  final String name;
  final String avatarUrl;
  final int? receiverId;

  const ChatScreen({super.key, required this.name, required this.avatarUrl, this.receiverId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.receiverId != null) {
      _loadMessages();
    } else {
      // Dummy messages for UI demo
      _messages = [
        {'text': 'Hi! I have a question about the property.', 'isSent': true, 'time': '10:30 AM'},
        {'text': 'Of course! How can I help you?', 'isSent': false, 'time': '10:32 AM'},
      ];
    }
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/messages/${widget.receiverId}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _messages = data.map((msg) {
            final currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.id;
            // Assuming the API returns sender_id. Check if it matches current user.
            // But wait, Provider is accessbile here? Yes.
            // Check auth_provider first?
            // Actually, comparing sender_id is safer if we know it.
            return {
              'text': msg['message'],
              'isSent': msg['sender_id'] == currentUserId, 
              'time': _formatTime(msg['created_at']),
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    // Simple parser or just return time part
    try {
      final dt = DateTime.parse(timestamp).toLocal();
      return TimeOfDay.fromDateTime(dt).format(context);
    } catch (e) {
      return '';
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      if (widget.receiverId != null) {
        // Send to API
        try {
          final response = await ApiService.post('/messages', {
            'receiverId': widget.receiverId,
            'message': text,
          });
          
          if (response.statusCode == 201) {
             _messageController.clear();
             _loadMessages(); // Refresh or append
          }
        } catch(e) {
          debugPrint('Send message error: $e');
        }
      } else {
        // Dummy behavior
        setState(() {
          _messages.add({
            'text': text,
            'isSent': true,
            'time': TimeOfDay.now().format(context),
          });
          _messageController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.avatarUrl),
            ),
            const SizedBox(width: 12),
            Text(widget.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(LineIcons.phone), onPressed: () {}),
          IconButton(icon: const Icon(LineIcons.verticalEllipsis), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(
                  message['text'],
                  message['isSent'],
                  message['time'],
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isSent, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSent) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSent ? const Color(0xFF2D64FF) : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isSent ? 20 : 4),
                  bottomRight: Radius.circular(isSent ? 4 : 20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: GoogleFonts.outfit(
                      color: isSent ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      color: isSent ? Colors.white70 : Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isSent) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.outfit(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF2D64FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(LineIcons.paperPlane, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
