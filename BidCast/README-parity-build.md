# BidCast iOS — Parity Build README

**Branch:** `qa/trey-ios-bug-fixes-2026-04-16` on `smokyweb/bidcast-ios`
**Backup tag:** `backup/pre-parity-build-20260422-091016`
**Last phase shipped:** Phase 7 (final polish) — 2026-04-22

---

## What this build is

This branch is the iOS parity build: 7 phases (+ 2 jobs) that took the iOS
app from a ~277-Swift-file template-laden skeleton with no backend wiring
to a feature-complete peer of the Android app and PWA on all major flows:
Auth, Orders, Seller Hub, Shop, Payments, Live Streaming (view + host),
Polls, Tips, Randomizer, Raid, Timer-rotation, Deep links, Push, Analytics,
Localization scaffolding, and Onboarding.

It is ready for a Codemagic TestFlight build once the TODO-TREY items
below are completed (all require human credentials / infra).

---

## Branch layout

- **`iOS_V2`** — SkyeStone's canonical branch on `smokyweb/bidcast-ios`.
  Has the CI fixes from the 2026-04-20 debugging run. **Do not push here
  from parity work; only merge back after Trey reviews.**
- **`qa/trey-ios-bug-fixes-2026-04-16`** — this parity build. Forked from
  the initial `iOS_V2` on 2026-04-17, then developed forward independently.
- **`backup/pre-parity-build-20260422-091016`** — safety tag pinned before
  Phase 1 began. `git reset --hard` here restores the pre-parity state.

---

## TODO-TREY — Go-live checklist

Ordered by blocking priority. Do not trigger Codemagic until 1–4 are done.

1. **Cherry-pick CI fix commits from `iOS_V2` onto `qa/trey-ios-bug-fixes-2026-04-16`**
   so Codemagic can build. Commits: `c0d5c287` (setup_signing.py),
   `8d2c49ff`, `cc2ffc08`, `e99d850`, `2a9829e`. Alternative: merge `iOS_V2`
   into the QA branch.
2. **Stripe publishable key** in `BidCast/Info.plist`. Current value is
   `pk_test_TODO_TREY_REPLACE`. Swap in the real test key for TestFlight,
   then the live key for App Store.
3. **`GoogleService-Info.plist`** — replace `BidCast/GoogleService-Info.plist`
   with the real file downloaded from Firebase Console (`bidcast` project
   → iOS app). Current copy is the Phase 1 dev placeholder.
4. **APNs `.p8` key uploaded to Firebase Messaging** — Firebase Console →
   Project Settings → Cloud Messaging → Apple app configurations. Without
   this, FCM registration succeeds locally but backend push never reaches
   the device.
5. **Agora App ID in Info.plist** — `AGORA_APP_ID` key. Needed for live
   video. Get from the Agora dashboard.
6. **`apple-app-site-association` file** hosted at
   `https://bidcast.betaplanets.com/.well-known/apple-app-site-association`.
   Required for Universal Links (`https://bidcast.betaplanets.com/stream/{id}`).
   Format: JSON with `appID = YQGQU3RV34.io.bidcast` and paths array.
7. **Associated Domains capability** in Apple Developer portal and in the
   Xcode project (`BidCast.entitlements`). Add
   `applinks:bidcast.betaplanets.com`.
8. **`aps-environment` flip dev → production** in `BidCast.entitlements`
   before App Store submission.
9. **`CFBundleVersion` bump** — the next build must be >= 172 (171 was
   the last successful TestFlight upload on the `iOS_V2` branch).
10. **CocoaPods install** — run in Codemagic (`pod install` step in yaml).
    Local `pod install` is disabled per the Bluestone policy. The Pods
    we need are already in the Podfile: Socket.IO, Agora, Stripe,
    Firebase (Core / Analytics / Messaging), Kingfisher.
11. **Localization variant groups** — the 12 non-English `.lproj/Localizable.strings`
    files exist on disk but Xcode's `PBXVariantGroup` still references only
    English. Open BidCast.xcodeproj, select `Localizable.strings` → File
    Inspector → Localization → check the 12 boxes. Xcode picks up the
    sibling files automatically.
12. **First Codemagic build attempt** — yaml workflow `ios-release`, branch
    `qa/trey-ios-bug-fixes-2026-04-16` (or merged back into `iOS_V2`).
13. **TestFlight submission** — manual review, add release notes, invite
    internal testers.
14. **Cleanup legacy `print()` calls** — 49 stray prints in legacy template
    code. DebugLogger is now available as the preferred replacement. Not
    blocking — noise in DEBUG console only.

---

## Where each feature lives (code map)

| Feature | Primary file(s) |
|---|---|
| **Live viewer** | `BidCast/Live/WatchStreamViewController.swift` |
| **Live host** | `BidCast/Live/HostPublisherViewController.swift` |
| **Socket layer** | `BidCast/Live/Socket/BidcastSocketManager.swift` (+ BreakSpot variant) |
| **Agora engine** | `BidCast/Live/Agora/BidcastAgoraEngine.swift` |
| **Agora token fetch** | `BidCast/Live/Services/AgoraTokenService.swift` |
| **Live show resolver** | `BidCast/Live/Services/LiveShowResolver.swift` |
| **Live auth guard** | `BidCast/Live/Common/LiveAuthGuard.swift` |
| **Chat bubble cells / buffer** | `BidCast/Live/Chat/LiveChatMessageCell.swift`, `LiveChatBuffer.swift` |
| **Poll (host create)** | `BidCast/Live/Host/CreatePollSheet.swift` |
| **Poll (viewer)** | `BidCast/Live/LivePollSheet.swift` |
| **Tip settings (host)** | `BidCast/Live/Host/HostTipSettingsSheet.swift` |
| **Send tip (viewer)** | `BidCast/Live/LiveTipSheet.swift`, `BidCast/Screens/Phase4/Tips/SendTipViewController.swift` |
| **Randomizer host** | `BidCast/Live/Host/HostRandomizerSheet.swift` |
| **Randomizer winner banner** | `BidCast/Live/RandomizerWinnerBanner.swift` |
| **Freebie viewer entry** | `BidCast/Live/LiveFreebieSheet.swift` |
| **Raid host** | `BidCast/Live/Host/HostRaidSheet.swift` |
| **Pinned product card** | `BidCast/Live/PinnedProductCard.swift` |
| **Live banner** | `BidCast/Live/LiveBanner.swift` |
| **Browse live shows (viewer entry)** | `BidCast/Screens/Home/BrowseLiveShowsViewController.swift` |
| **Deep-link router** | `BidCast/Application/DeepLink/DeepLinkRouter.swift` |
| **Push registration** | `BidCast/Application/Push/PushRegistrationService.swift` |
| **Stripe bootstrap** | `BidCast/Application/Payments/StripeService.swift` |
| **Add card** | `BidCast/Screens/Phase4/Payments/AddCardViewController.swift` |
| **Payment methods list** | `BidCast/Screens/Phase4/Payments/PaymentMethodsListViewController.swift` |
| **Wallet + payouts** | `BidCast/Screens/Phase4/Wallet/WalletViewController.swift`, `PayoutRequestViewController.swift` |
| **KYC (Stripe Connect)** | `BidCast/Screens/Phase4/KYC/KYCViewController.swift` |
| **Checkout / Buy Now** | `BidCast/Screens/Phase4/Checkout/CheckoutViewController.swift` |
| **Orders list + detail** | `BidCast/Screens/Phase3/Orders/OrderListViewController.swift`, `OrderDetailViewController.swift` |
| **Chat (Firebase RTDB)** | `BidCast/Services/Chat/FirebaseChatStore.swift`, `BidCast/Screens/Phase3/Chat/ConversationListViewController.swift`, `ChatRoomViewController.swift` |
| **Seller public profile** | `BidCast/Screens/Phase3/Social/SellerPublicProfileViewController.swift` |
| **Seller Hub** | `BidCast/Screens/Phase3/SellerHub/SellerHubContainerViewController.swift` + tabs |
| **Coupons / Premier / Promote Tools** | `BidCast/Screens/Phase3/Shop/*.swift` |
| **Subscription plans** | `BidCast/Screens/Phase3/Shop/SubscriptionPlansViewController.swift` |
| **Show scheduling** | `BidCast/Screens/Phase3/Shows/ShowScheduleEditorViewController.swift` |
| **Home / Activity / Account tab swizzles** | `BidCast/Application/JobA/*Swizzle.swift` |
| **Analytics wrapper** | `BidCast/Services/Analytics/AnalyticsService.swift` |
| **Localization (13 locales)** | `BidCast/Resources/Localization/` |
| **Onboarding carousel** | `BidCast/Screens/Onboarding/OnboardingCarouselViewController.swift` |
| **DebugLogger** | `BidCast/Helper/DebugLogger.swift` |
| **Data models (Kotlin → Swift)** | `BidCast/Models/**/*.swift` |
| **API endpoints enum** | `BidCast/Helper/ProjectEndPoint.swift` |

---

## How to run Codemagic

Prerequisites: TODO-TREY items 1–4 (especially #1) completed.

```bash
# Trigger via Codemagic API
curl -X POST "https://api.codemagic.io/builds" \
  -H "x-auth-token: $CM_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
        "appId": "69e671d2402d4fe5b4b21835",
        "workflowId": "ios-release",
        "branch": "qa/trey-ios-bug-fixes-2026-04-16"
      }'
```

(Or trigger via the Codemagic UI: apps → bidcast-ios → Start new build.)

Build logs stream to the Codemagic UI. First build will take ~10–15 min
(pod install + archive + signing + upload).

**Before triggering:** verify `app_store_cred` variable group has the 3
ASC keys (`APP_STORE_CONNECT_KEY_IDENTIFIER`, `APP_STORE_CONNECT_ISSUER_ID`,
`APP_STORE_CONNECT_PRIVATE_KEY`) on THIS specific Codemagic app
(69e671d2402d4fe5b4b21835) — these are per-app, not global.

---

## Socket event contract

27 emits + 26 listeners across viewer + host flows. See
`BidCast/Live/Socket/BidcastSocketManager.swift` for the full method surface,
and the Phase 5 report for the event-to-UI map. Highlights:

- `place_bid` / `set_max_bid` / `bid_finalized` — auction pipeline
- `create_poll` / `vote_poll` / `end_poll` / `poll_created` / `poll_ended`
- `tip_setting_save` / `tip_setting_updated`
- `create-freebie` / `enter-in-freebie` / `finalize-freebie` / `get-freebie` / `get-freebie-winner`
- `createRaid` / `receiveRaid`
- `run_next_product` / `auction_next_product` / `run_next_product_error`
- Break-spot variants (`start_auction_break_spot`, `place_bid_break_spot`, etc.)

All event names + payload shapes already match Android's `SocketManager.kt`
1-to-1 (verified across Phase 2, 5, 6).

---

## iOS Parity P0 follow-ups (2026-04-23)

### Associated-domain / AASA for /invite links (P0.5)

The iOS app now handles `/invite/<code>` universal links — tapping one
presents `SignUpViewController` with the referral code pre-filled (code
is forwarded as `referral_code` multipart in the register request).

**Backend action required:** publish an updated
`apple-app-site-association` file on `bidcast.betaplanets.com` so Apple
whitelists that path. The `paths` array must include the invite prefix
alongside the existing Bidcast routes, e.g.:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "<TEAM_ID>.io.bidcast",
        "paths": [
          "/stream/*",
          "/show/*",
          "/live/*",
          "/order/*",
          "/chat/*",
          "/profile/*",
          "/product/*",
          "/invite/*"
        ]
      }
    ]
  }
}
```

Serve it at `https://bidcast.betaplanets.com/.well-known/apple-app-site-association`
with `Content-Type: application/json` and no redirect.

---

## Known non-blockers

1. **Randomizer uses instant-pick, not lucky-wheel.** Matches PWA. Android
   has a wheel animation; not ported for v1.
2. **Tip preset tiers persist to UserDefaults locally** because the backend
   doesn't expose a dedicated REST endpoint yet. When backend adds
   `POST /api/update-tip-settings`, wire `TipSettingsViewController` to it.
3. **Firebase Crashlytics not integrated.** Analytics + Messaging are.
   Add Crashlytics pod to the Podfile when desired.
4. **49 stray `print()` calls** in legacy template code (EditProfile,
   PrivacyPolicy, etc). Noise in DEBUG only. Replace with `DebugLogger.log`
   at leisure.

---

## Rolling back

Every phase landed in its own commit. To back out the entire parity build:

```bash
cd bidcast-ios
git fetch origin
git reset --hard backup/pre-parity-build-20260422-091016
git push --force-with-lease origin qa/trey-ios-bug-fixes-2026-04-16
```

Or to back out a single phase: `git revert <commit-sha>`.
