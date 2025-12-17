import 'dart:js_interop';
import 'package:web/web.dart';

/// Locates the root of the flutter app (the first element that has
/// a flt-renderer tag), and dispatches a JS event named [name] with [data].
///
/// This is used to communicate from Flutter to the parent web app
/// by broadcasting custom DOM events.
void broadcastAppEvent(String name, JSObject data) {
  final HTMLElement? root =
      document.querySelector('[flt-renderer]') as HTMLElement?;

  if (root == null) {
    print('[broadcastAppEvent] WARNING: Flutter root element cannot be found!');
    return;
  }

  final eventDetails = CustomEventInit(detail: data);
  eventDetails.bubbles = true;
  eventDetails.composed = true;

  root.dispatchEvent(CustomEvent(name, eventDetails));

  print('[broadcastAppEvent] Event "$name" dispatched successfully');
}
