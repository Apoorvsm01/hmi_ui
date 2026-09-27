/// No-op implementation used on every non-web platform.
library;

String? currentDeepLinkSlug() => null;

void pushDeepLinkPath(String? slug) {}

void listenForPopState(void Function(String? slug) onPopState) {}
