# Cleaning Gender Preference Confirmation Phase

## Summary

This branch implements the user-app phase for the cleaning order gender-preference confirmation protocol.

## Backend endpoint consumed

```http
GET /api/v1/user/cleaning/orders/female-worker-safety-policy
```

## Implementation checklist

- Add response model for the server-driven policy.
- Add request model for the confirmation payload.
- Add repository and remote data source methods.
- Show the gender preference section before assignment mode.
- Keep gender preference available in both assignment modes.
- Open a required confirmation sheet when the restricted preference is selected.
- Save the confirmation in BLoC state only after the user accepts the allowed option.
- Send `workEnvironmentConfirmation` with the final create order request.
- Add a submit guard on the schedule screen.

## Manual QA

1. Select unrestricted preferences and confirm the flow still reaches schedule and creates orders.
2. Select the restricted preference and cancel the sheet; the previous preference should remain selected.
3. Select the restricted preference, choose the blocked option, and verify the app shows the backend message without changing selection.
4. Select the restricted preference, choose the allowed option, accept the pledge, and verify the final request includes `workEnvironmentConfirmation`.
5. Switch between selected-worker and open-count modes; the preference should remain unchanged.
