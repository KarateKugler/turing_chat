part of 'chat_cubit.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

final class ChatLoading extends ChatState {}

/// Models the state of the chat rooms
final class ChatLoaded extends ChatState {
  final List<ChatRoom> chatrooms;

  ChatLoaded({
    required this.chatrooms
});
}

