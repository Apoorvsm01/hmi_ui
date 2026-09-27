/// Web implementation backed by `package:web` (browser History/Location APIs).
library;

import 'dart:js_interop';

import 'package:web/web.dart' as web;

String get _basePath {
  final base = Uri.parse(web.document.baseURI).path;
  return base.isEmpty ? '/' : base;
}

String? currentDeepLinkSlug() {
  final path = web.window.location.pathname;
  final base = _basePath;
  final remainder = path.startsWith(base) ? path.substring(base.length) : path;
  final trimmed = remainder.replaceAll(RegExp(r'^/+|/+$'), '');
  return trimmed.isEmpty ? null : trimmed;
}

void pushDeepLinkPath(String? slug) {
  final base = _basePath;
  final target = (slug == null || slug.isEmpty)
      ? base
      : '$base$slug'.replaceAll('//', '/');
  if (web.window.location.pathname == target) return;
  web.window.history.pushState(null, '', target);
}

void listenForPopState(void Function(String? slug) onPopState) {
  web.window.addEventListener(
    'popstate',
    ((web.Event _) => onPopState(currentDeepLinkSlug())).toJS,
  );
}
