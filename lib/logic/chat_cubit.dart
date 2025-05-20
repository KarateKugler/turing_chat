import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_api/supabase_api.dart';
import 'package:turing_chat/models/contact.dart';
import 'package:turing_chat/models/settings.dart';

import '../models/chat_room.dart';
import '../models/message.dart';
import '../models/user.dart';

part 'chat_state.dart';

// todo: use hydrated cubit
class ChatCubit extends Cubit<ChatState> {
  final AuthService _auth;
  final DatabaseService _db;

  ChatCubit(this._auth, this._db)
      : super(ChatState.initial);

  /// Initialize the ChatCubit
  /// (only called if Authenticated, so active session is ensured)

  void init() async {
    emit(state.copyWith(status: ChatStatus.loading));

    try {
      final userData = _auth.userData!;
      final String userId = userData['id']!;

      /// user model (username & created at)
      final username = await _db.getUsername(id: userId);
      final user = User(
        id: userId,
        email: userData['email']!,
        username: username,
        createdAt: DateTime.parse(userData['created_at']!),
      );

      emit(state.copyWith(
        currentUser: user,
      ));

      /// contacts / chat rooms and channels set up
      await fetchContactsAndChannels();

      /// settings (sys prompt)
      await fetchSystemPrompt();
    }

    /// ...
    catch (e) {
      emit(
          state.copyWith(status: ChatStatus.error, errorMessage: e.toString()));
      debugPrint(e.toString());
    }
  }

  @override
  Future<void> close() {
    /// close all message listeners
    _db.close();
    return super.close();
  }

  void logOut()  {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      emit(ChatState.initial);
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// emit a chat error state directly

  void chatError(String errorMessage) {
    emit(state.copyWith(status: ChatStatus.error, errorMessage: errorMessage));
  }

  /// emit the ChatRoomState for the selected contact
  void openChatRoom(String contactUsername) {
    emit(state.copyWith(chatroomContactUsername: contactUsername));
  }

  void closeChatRoom() {
    emit(state.copyWith(chatroomContactUsername: ''));
  }

  /// /////////////////////////////////
  ///   CONTACTS

  /// fetch/refrsh all contacts and init the chat rooms
  Future<void> fetchContactsAndChannels() async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      /// contacts
      List<ContactModel> contactData =
          await _db.fetchContacts(state.currentUser!.id);

      /// init/update chatrooms and realtime channels
      Map<String, ChatRoom> chatrooms = state.chatroomsByUsername;
      for (ContactModel entry in contactData) {
        print(entry);
        // init chatroom
        if (chatrooms[entry.username] == null) {
          // contact data and status, score and streak
          chatrooms[entry.username] = ChatRoom.fromContactModel(entry);

          // realtime channel and presence subscription (if not blocked)
          if (!(entry.blockedIn || entry.blockedOut)) {
            print('not blocked');
            // set init the channel
            _db.initContactChannel(
              username: state.currentUser!.username,
              contactName: entry.username,
            );

            // start listening to online status / presence
            _db.addStatusSubscription(
              username: state.currentUser!.username,
              contactName: entry.username,
              statusCallback: (_) {},
              presenceCallback: ({required online, required username}) {
                if (username == state.currentUser!.username) return;

                Map<String, ChatRoom> chatrooms = state.chatroomsByUsername;

                // only change if we have to
                if (chatrooms[username]?.contact.onlineStatus.isOnline !=
                    online) {
                  chatrooms[username] = chatrooms[username]!
                      .copyWithUpdatedOnlineStatus(
                          online ? OnlineStatus.online : OnlineStatus.offline);

                  // reemit:
                  // todo refactor with update flag in the state.
                  emit(state.copyWith(chatroomsByUsername: chatrooms));
                }
              },
            );
          }
        }

        // update friend status
        else {
          chatrooms[entry.username] = chatrooms[entry.username]!
              .copyWithUpdatedFriendStatus(FriendStatus.fromFlags(
            blockedIn: entry.blockedIn,
            blockedOut: entry.blockedOut,
            friendIn: entry.friendRequestedIn,
            friendOut: entry.friendRequestedOut,
          ));

          if (entry.blockedIn || entry.blockedOut) {
            // todo: close channel.
          }
        }
      }

      emit(state.copyWith(
        chatroomsByUsername: chatrooms,
        status: ChatStatus.success,
      ));
    }

    // ...
    catch (e) {
      emit(
          state.copyWith(status: ChatStatus.error, errorMessage: e.toString()));
      debugPrint(e.toString());
    }
  }

  /// Add a new friend by username
  Future<void> addFriendByUsername(String friendUsername) async {
    /// Try finding by username and adding
    try {
      emit(state.copyWith(status: ChatStatus.loading));

      if (state.currentUser == null) {
        emit(state.copyWith(
          status: ChatStatus.error,
          errorMessage: 'No authenticated user found',
        ));
        return;
      }

      String friendId =
          await _db.addFriendByUsername(state.currentUser!.id, friendUsername);

      ChatRoom? chatroom = state.chatroomsByUsername[friendUsername];

      /// if this works, two possiblities:

      /// this is a new contact, and the user just sent a friend request
      if (chatroom == null) {
        ChatRoom newChatroom = ChatRoom(
          contact: Contact(
            id: friendId,
            email: null,
            username: friendUsername,
            friendsSince: DateTime.now(),
            friendStatus: FriendStatus.requestedOut,
          ),
          messages: [],
          userScore: 0,
          userStreak: 0,
          contactScore: 0,
          contactStreak: 0,
        );
        state.chatroomsByUsername.addAll({friendUsername: newChatroom});
      }

      /// the user just accepted a friend request
      else {
        /// update contact status
        state.chatroomsByUsername[friendUsername] = state
            .chatroomsByUsername[friendUsername]!
            .copyWithUpdatedFriendStatus(FriendStatus.friend);
      }

      emit(state.copyWith(status: ChatStatus.success));

      // todo: add more logic for case of contact being blocked or reported
    }

    /// Error if username was not found
    on NotFoundException {
      emit(state.copyWith(errorMessage: 'username not found'));
    }

    /// other error
    catch (e) {
      emit(state.copyWith(errorMessage: 'unexpected error occured: $e'));
    }
  }

  /// block a contact

  void blockContact(String contactId) {
    try {
      emit(state.copyWith(status: ChatStatus.loading));
      
      // Call database service to block the contact
      _db.blockContact(
        userId: state.currentUser!.id,
        contactId: contactId,
      );

      // Find the contact username from the contactId
      String? contactUsername;
      state.chatroomsByUsername.forEach((username, chatroom) {
        if (chatroom.contact.id == contactId) {
          contactUsername = username;
        }
      });

      if (contactUsername != null) {
        // Update the chatroom's friend status to blocked
        Map<String, ChatRoom> updatedChatrooms = Map.from(state.chatroomsByUsername);
        updatedChatrooms[contactUsername!] = updatedChatrooms[contactUsername]!
            .copyWithUpdatedFriendStatus(FriendStatus.blockedOut);

        // Remove message subscription if it exists
        removeMessageSubscription(contactUsername!);

        emit(state.copyWith(
          chatroomsByUsername: updatedChatrooms,
          status: ChatStatus.success,
        ));
      }
    } catch (e) {
      debugPrint(e.toString());
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// unblock a contact

  void unblockContact(String contactId) {
    try {
      emit(state.copyWith(status: ChatStatus.loading));

      // Call database service to unblock the contact
      _db.unblockContact(
        userId: state.currentUser!.id,
        contactId: contactId,
      );

      // update contacts (emits success)
      fetchContactsAndChannels();
    } catch (e) {
      debugPrint(e.toString());
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// /////////////////////////////////
  ///   MESSAGES

  /// add message listener

  void addMessageSubscription(String contactName) {
    try {
      _db.addMessageSubscription(
        username: state.currentUser!.username,
        contactName: contactName,
        messageCallback: (message) {
          state.chatroomsByUsername[contactName]!.messages
              .add(Message.fromModel(message, state.currentUser!.id));

          print('emit new msg!');

          /// todo refresh flag
          emit(state.copyWith(chatroomsByUsername: state.chatroomsByUsername));
        },
      );
    } catch (e) {
      debugPrint(e.toString());
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// remove message listener

  void removeMessageSubscription(String contactName) {
    try {
      _db.removeMessageSubscription(contactName);
    } catch (e) {
      debugPrint(e.toString());
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// send a message to a contact

  Future<void> sendMessage({
    required String contactId,
    required String content,
  }) async {
    User user = state.currentUser!;

    ///
    try {
      // send to the db and realtime channel
      _db.sendMessage(
        userId: user.id,
        contactId: contactId,
        content: content,
      );
    } catch (e) {
      debugPrint(e.toString());
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// call function to generate and send to contact
  Future<void> sendGeneratedMessage(String contactId) async {
    User user = state.currentUser!;

    ///
    try {
      _db.sendGeneratedMessage(
        userId: user.id,
        contactId: contactId,
      );
    }

    ///
    catch (e) {
      debugPrint(e.toString());
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// fetch/refresh msgs for one contact

  Future<void> fetchMessages(String contactName) async {
    emit(state.copyWith(status: ChatStatus.loading));

    try {
      List<MessageModel> messageData = await _db.fetchMessages(
          userId: state.currentUser!.id,
          contactId: state.chatroomsByUsername[contactName]!.contact.id);

      state.chatroomsByUsername[contactName]!.messages.clear();
      state.chatroomsByUsername[contactName]!.messages.addAll(
          messageData.map((e) => Message.fromModel(e, state.currentUser!.id)));

      emit(state.copyWith(status: ChatStatus.success));
    } catch (e) {
      debugPrint(e.toString());
      emit(
          state.copyWith(status: ChatStatus.error, errorMessage: e.toString()));
    }
  }

  void selectMessage(int messageIndex) {
    emit(state.copyWith(selectedMessageIndex: messageIndex));
  }

  void deselectMessage() {
    emit(state.copyWith(selectedMessageIndex: -1));
  }

  Future<void> updateCurrentChatroom() async {
    try {
      // get the contact of the current chatroom
      Contact contact =
          state.chatroomsByUsername[state.chatroomContactUsername]!.contact;
      String contactId = contact.id;

      // fetch the contact data
      ContactModel contactModel = await _db.fetchContact(
          userId: state.currentUser!.id, contactId: contactId);

      // update scores
      state.chatroomsByUsername[state.chatroomContactUsername] =
          state.chatroomsByUsername[state.chatroomContactUsername]!.copyWith(
        contactScore: contactModel.contactScore,
        contactStreak: contactModel.contactStreak,
        userScore: contactModel.userScore,
        userStreak: contactModel.userStreak,
      );

      // update messages
      fetchMessages(contact.username);
      // (emits success)
    } catch (e) {
      emit(
          state.copyWith(status: ChatStatus.error, errorMessage: e.toString()));
      debugPrint(e.toString());
    }
  }

  Future<void> classifyMessage({
    required String messageId,
    bool guess = true,
  }) async {
    emit(state.copyWith(status: ChatStatus.loading));

    // 1. call the classify fct.
    // we simply set the identified column of the given message as TRUE
    // i.e. UPDATE messages SET identified = TRUE WHERE id = message_id
    // Then the policy on gen_flags allows for read
    // We update the streak and score
    // 2. refetch the contact data, and the messages data
    // 3. update state and emit success.

    await _db.classifyMessage(messageId: messageId, guess: guess);

    updateCurrentChatroom();
    // (emits success)
  }

  /// /////////////////////////////////
  ///   SETTINGS

  /// fetches and updates the user's current system prompt

  Future<void> fetchSystemPrompt() async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final promptData = await _db.fetchSystemPrompt(state.currentUser!.id);

      /// add to state and emit success
      emit(state.copyWith(
          status: ChatStatus.success,
          userSettings: Settings(
            systemPrompt: promptData['system_prompt'],
            promptUpdatedAt: DateTime.parse(promptData['prompt_created_at']),
          )));
    }

    /// ...
    catch (e) {
      emit(
          state.copyWith(status: ChatStatus.error, errorMessage: e.toString()));
      debugPrint(e.toString());
    }
  }

  /// sends updated prompt to the db

  Future<void> updateSystemPrompt(String newPrompt) async {
    emit(state.copyWith(status: ChatStatus.loading));

    try {
      /// send
      await _db.updateSystemPrompt(
          userId: state.currentUser!.id, prompt: newPrompt);

      /// fetch again (emits suc.)
      await fetchSystemPrompt();
    }

    /// ...
    catch (e) {
      emit(
          state.copyWith(status: ChatStatus.error, errorMessage: e.toString()));
      debugPrint(e.toString());
    }
  }

  /// reset the system prompt to the default.

  Future<void> resetSystemPrompt() async {
    emit(state.copyWith(status: ChatStatus.loading));

    try {
      /// reset
      await _db.resetSystemPrompt(state.currentUser!.id);

      /// fetch again (emits suc.)
      await fetchSystemPrompt();
    }

    /// ...
    catch (e) {
      emit(
          state.copyWith(status: ChatStatus.error, errorMessage: e.toString()));
      debugPrint(e.toString());
    }
  }
}
