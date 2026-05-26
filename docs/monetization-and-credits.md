# Moments AV Monetization And Credits

This document records the current product direction for Moments AV credits,
Pro access, promo claims, and the RevenueCat/App Store setup. It is a planning
document, not a user-facing promise.

## Product Decision

Moments AV should keep monetization simple at launch:

- One monthly Pro subscription.
- One or more one-time credit packs.
- Promo codes for campaigns, support, testers, or manual compensation.
- No quarterly or annual subscription at launch.

The intended model is:

```text
canRender = spendableCredits > 0
hasProFeatures = activeProSubscription
```

Credits buy render capacity. Pro unlocks the premium creative experience.

## Credit Sources

Credits may come from these sources:

- Monthly Pro allocation while the subscription is active.
- Purchased credit packs.
- Promotional claims.

Avoid user-facing copy that says credits are permanent, lifetime, or never
expire. The app should say only what is currently operationally guaranteed.

## Pro Monthly

Pro Monthly is the recommended plan for users who create memory videos
regularly. It should not be positioned as an aggressive discount on credits.
Instead, the product value is:

- Monthly credits while the plan is active.
- Future Pro-only templates.
- Future advanced customization.
- Future additional preview/story iterations.
- Future memory profile or preference features.
- Future early access to new styles.

Suggested paywall copy:

```text
For regular memory videos. Includes monthly credits while your plan is active.
Cancel anytime.
```

Do not promise accumulated monthly credits unless the backend and terms are
explicitly designed for it.

## Purchased Credits

Purchased credit packs are for users who want to create videos without a
subscription, or Pro users who need extra render capacity.

Suggested paywall copy:

```text
Add credits when you need more.
```

Purchased credits do not unlock Pro-only features by themselves.

## Pro Plus Purchased Credits

If a user has an active Pro subscription and buys extra credits, those extra
credits can be used with Pro features while the subscription remains active.

If the user later cancels Pro and still has spendable credits, those credits can
still be used for non-Pro videos, but Pro-only templates and customization
should no longer be available.

| User state | Can render videos | Pro features | Credit source |
| --- | --- | --- | --- |
| Signed in, no credits | No | No | None |
| Purchased credits only | Yes | No | Purchased |
| Active Pro | Yes | Yes | Monthly |
| Active Pro plus purchased credits | Yes | Yes | Monthly and purchased |
| Canceled Pro with purchased credits | Yes | No | Purchased |

## Promo Codes

Promo codes are a controlled credit source and must be validated by backend
authority before production use.

Promo codes may grant credits only, temporary Pro access only, or a bundle of
temporary Pro access plus promo credits.

Promo code rules should support:

- Single-use codes.
- Multi-use campaign codes.
- Expiration dates.
- Per-user claim limits.
- Operator-issued support codes.
- Audit records.

Promo credits should not be described as permanent or equivalent to purchased
credits unless product, legal, and backend policy explicitly make that true.

## Pro Promo Pass

Moments AV may support a Pro promo pass for testers, campaigns, support, press,
or early user validation. This is not an App Store subscription trial and should
not be described as one.

A Pro promo pass can unlock Pro-only features for a limited time without
creating an App Store subscription, renewal, payment method requirement, or
cancelation obligation.

The recommended low-risk trial bundle is:

- Temporary Pro feature access, such as 7 or 14 days.
- A small number of promo credits, such as 1 or 2.
- One claim per user per campaign.
- Campaign expiration.
- Backend audit records.

Suggested copy:

```text
Try Pro with promo credits. No subscription required.
```

Avoid offering "Pro without credits" as the primary trial experience. It can be
confusing because the user may unlock premium options but still be unable to
render a video.

The entitlement rule becomes:

```text
canRender = spendableCredits > 0
hasProFeatures = activeProSubscription || activeProPromoEntitlement
```

The credit rule stays unchanged:

```text
spendableCredits = monthlyCredits + purchasedCredits + promoCredits
```

RevenueCat/App Store should remain the authority for paid subscription and
purchase evidence. The backend should remain the authority for promo pass
validation, promo credits, claim limits, campaign expiration, and audit history.

## Pro-Only Feature Candidates

The first Pro-only features should avoid large automatic cost increases. Good
future candidates are:

- Premium templates.
- Advanced customization for tone, pacing, music direction, captions, duration,
  language, dedication, or story emphasis.
- More preview/story iterations before final render.
- Memory profile or reusable preferences.
- Early access to new styles.

Higher-cost features, such as higher-quality models, longer videos, or priority
queues, should be introduced only after provider costs and queue behavior are
measured.

## App Store And RevenueCat Setup Direction

Initial product identifiers are planned as:

- `momentsav_pro_monthly`: monthly subscription.
- `momentsav_credits_5`: consumable credit pack.
- `momentsav_credits_20`: consumable credit pack.
- `moments_credits`: RevenueCat offering identifier.

### Apple Compliance Rule

Paid digital access that is consumed inside the iOS app must use Apple
In-App Purchase/StoreKit. For Moments AV this includes paid Pro subscriptions,
paid credit packs, paid render capacity, paid templates, paid customization, or
any paid digital feature used in the app.

Do not sell external promo codes, vouchers, or website purchases that unlock
paid in-app digital content unless the app is explicitly using an Apple-approved
external purchase entitlement for the relevant storefront and the flow has been
reviewed for compliance.

Free promotional access is different. Moments AV may grant free promo credits
or a free temporary Pro promo pass through backend policy or RevenueCat granted
entitlements, as long as users are not paying outside Apple for that access.

User-facing copy should keep this clear:

```text
Have a promo code? Claim it here.
```

Avoid copy that implies external purchase:

```text
Buy a code on our website.
Redeem your web purchase.
Use this code instead of subscribing.
```

Apple reference: App Review Guideline 3.1.1 covers in-app purchase requirements
for digital goods and services consumed in the app:
https://developer.apple.com/app-store/review/guidelines/

### RevenueCat Configuration

RevenueCat should be configured around a single paid Pro entitlement and paid
App Store products:

- Entitlement: `pro`
- Offering: `moments_credits`
- Subscription product: `momentsav_pro_monthly`
- Consumable products: `momentsav_credits_5`, `momentsav_credits_20`

Attach the monthly subscription product to the `pro` entitlement. Do not attach
consumable credit packs to the `pro` entitlement, because consumables should not
unlock Pro access indefinitely.

RevenueCat reference: entitlements represent access to features/content and are
typically unlocked after purchase:
https://www.revenuecat.com/docs/getting-started/entitlements

RevenueCat also warns that consumables attached to entitlements can appear as
unlocked forever after purchase, which is not the desired behavior for credit
packs:
https://www.revenuecat.com/docs/platform-resources/non-subscriptions

### Pro Promo Pass Configuration

The safest implementation for temporary Pro promo access is one of these:

1. RevenueCat granted entitlements for the `pro` entitlement.
2. Backend-managed `activeProPromoEntitlement` checked alongside RevenueCat.

RevenueCat granted entitlements are appropriate for support, testers, campaigns,
press, or early access because they work independently of App Store billing,
have a chosen duration, do not charge the user, do not issue refunds, and do
not convert to a paid subscription.

RevenueCat reference:
https://www.revenuecat.com/docs/dashboard-and-metrics/customer-history/active-entitlements

The preferred production rule is:

```text
paidProActive = RevenueCat entitlement "pro" is active from App Store purchase
promoProActive = backend promo pass is active OR RevenueCat granted entitlement is active
hasProFeatures = paidProActive || promoProActive
```

Promo credits should remain in the backend credit ledger:

```text
spendableCredits = monthlyCredits + purchasedCredits + promoCredits
```

RevenueCat/App Store purchases should be treated as purchase evidence, not the
final credit authority. The backend credit ledger should remain the source of
truth after purchase, restore, promo claim, refund, or account deletion.

## Exit Plan

The launch model should keep shutdown risk bounded:

1. Disable new purchases and new subscriptions.
2. Keep service available for already active monthly subscription periods.
3. Stop selling new credit packs.
4. Announce a window for users to use remaining credits.
5. Preserve access to already generated final videos until the announced
   retention window ends.
6. Handle unused paid credits through the planned support/refund policy.

This is one reason the first subscription should be monthly only, not annual.
