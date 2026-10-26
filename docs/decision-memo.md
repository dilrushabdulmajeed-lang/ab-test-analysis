# Decision Memo: Mobile Checkout Redesign

**Experiment:** 7 Sep – 4 Oct 2026 · 4,000 mobile users who started checkout · 50/50 split · **Prepared by:** dilrushabdulmajeed

## Recommendation
**Ship the redesign to iOS now. Keep Android on the current checkout and test Google Pay next.**

## Evidence
| | Control | Redesign | Lift |
|---|---|---|---|
| Checkout completion | 47.3% | 52.8% | **+5.4 pts** (95% CI +2.4 to +8.5, p = 0.0006) |
| Revenue per user | AED 922 | AED 1,003 | +8.8% (bootstrap 95% CI +AED 6 to +155) |
| Average order value (guardrail) | AED 1,948 | AED 1,901 | no significant change (p = 0.80) |

- **The test is trustworthy:** it was adequately powered (1,568 users per group needed, about 2,000 collected), the 50/50 split held (SRM p = 0.59), and 41 duplicate assignments were removed before analysis.
- **The effect is an iOS effect:** iOS +11.2 pts (p < 0.001); Android −1.0 pts (p = 0.66). The difference between platforms is itself significant (interaction p = 0.0001), which fits Apple Pay being the driver.
- **Part of the early lift was novelty:** +13 pts in the first 4 days, settling to +4.2 pts overall (iOS +9.3 pts) from day 5. Forecasts use the settled numbers.

## Expected impact (iOS rollout)
12,932 iOS checkout starts a year × 9.3 pts ≈ **1,200 extra orders** × AED 1,923 AOV ≈ **AED 2.3M revenue a year**.

## Risks and follow-up
- The effect may keep fading past 4 weeks. **Monitor completion by platform weekly for a month after launch**, with the control rate as the reference.
- Android users get no benefit yet. **Next experiment:** Google Pay in the Android checkout, needing about 1,570 Android users per group for a 5-pt lift.
- Revenue per user is noisier than completion. Its interval is wide, though positive, so treat the AED figure as an estimate, not a guarantee.
