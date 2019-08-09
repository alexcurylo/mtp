1) Re-enable Thread Sanitizer once crash building Realm for Simulator (ok for device builds) addressed:
// https://github.com/realm/realm-cocoa/issues/6121
> Known Issues
> The Swift compiler may crash during a build when the Thread Sanitizer is enabled. (48719789)
> Workaround: Disable Thread Sanitizer in the Scheme Editor’s Diagnostics tab.

_notes on current branch task:_

