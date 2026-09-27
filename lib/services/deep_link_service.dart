/// Browser URL sync for deep-linking into HMI destinations (e.g. `/drive_coach`,
/// `/fleet`). Real implementation only compiles in on web; every other target
/// gets the no-op stub.
library;

export 'deep_link_service_stub.dart'
    if (dart.library.js_interop) 'deep_link_service_web.dart';
