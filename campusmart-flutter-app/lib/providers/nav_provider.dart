import 'package:flutter/foundation.dart';

import '../models/conversation.dart';
import '../models/item.dart';

/// The pages of the prototype. The order matches the children of the IndexedStack in main_shell.dart.
enum AppPage { home, saved, sell, orders, inbox, profile, detail }

/// Which page is showing, like the prototype's go('home') function.
class NavProvider extends ChangeNotifier {
  AppPage page = AppPage.home;
  Item? selectedItem; // shown on the detail page
  Item? editingItem; // set while the Sell page is used to edit a listing
  ChatTarget? pendingChat; // chat to open as soon as the Inbox page shows

  void go(AppPage target) {
    if (target == AppPage.sell) editingItem = null; // the Sell tab always starts a new listing
    page = target;
    notifyListeners();
  }

  void openDetail(Item item) {
    selectedItem = item;
    page = AppPage.detail;
    notifyListeners();
  }

  void editItem(Item item) {
    editingItem = item;
    page = AppPage.sell;
    notifyListeners();
  }

  void openChat(ChatTarget target) {
    pendingChat = target;
    page = AppPage.inbox;
    notifyListeners();
  }

  /// Does not notify: the inbox calls this while it is being rebuilt.
  void clearPendingChat() {
    pendingChat = null;
  }

  /// After the Sell page saved an edit.
  void finishEditing() {
    editingItem = null;
    page = AppPage.orders;
    notifyListeners();
  }
}
