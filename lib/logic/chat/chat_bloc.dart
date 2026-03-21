import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/session_manager.dart';
import '../../data/services/websocket_service.dart'; // NEW IMPORT

abstract class ChatEvent {}

class FetchMessages extends ChatEvent {
  final String incidentId;
  FetchMessages(this.incidentId);
}

class SendMessage extends ChatEvent {
  final String incidentId;
  final String content;
  SendMessage(this.incidentId, this.content);
}

abstract class ChatState {}
class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}
class ChatLoaded extends ChatState {
  final List<dynamic> messages;
  ChatLoaded(this.messages);
}
class ChatFailure extends ChatState {
  final String error;
  ChatFailure(this.error);
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;
  final WebSocketService wsService; // NEW: Added WS Service
  final SessionManager sessionManager = SessionManager();
  
  String? _activeIncidentId; // Tracks the currently open chat

  ChatBloc(this.repository, this.wsService) : super(ChatInitial()) {
    
    // WOW FACTOR: Listen to real-time chat messages
    wsService.connect();
    wsService.stream.listen((data) {
      // If we are currently looking at the chat that just got a message, refresh it instantly
      if (data.toString().contains('"type": "NEW_MESSAGE"') && _activeIncidentId != null) {
        add(FetchMessages(_activeIncidentId!)); 
      }
    });

    on<FetchMessages>((event, emit) async {
      _activeIncidentId = event.incidentId; // Set active chat
      emit(ChatLoading());
      try {
        final messages = await repository.getMessages(event.incidentId);
        emit(ChatLoaded(messages));
      } catch (e) {
        emit(ChatFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<SendMessage>((event, emit) async {
      try {
        final userId = await sessionManager.getUserId();
        if (userId == null) throw Exception("Session expired.");

        await repository.sendMessage(
          incidentId: event.incidentId,
          senderId: userId,
          content: event.content,
        );
        
        add(FetchMessages(event.incidentId));
      } catch (e) {
        emit(ChatFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}