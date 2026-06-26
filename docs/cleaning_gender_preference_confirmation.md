# Cleaning Gender Preference Confirmation Flow

## Backend dependency

```http
GET /api/v1/user/cleaning/orders/female-worker-safety-policy
```

The endpoint returns the server-owned title, question, options, pledge text, and pledge version.

## App behavior

1. The gender preference selector appears before assignment mode.
2. The selector works for both selected-worker and open-count modes.
3. Choosing the restricted preference fetches the server policy.
4. The app opens a required confirmation bottom sheet.
5. The user must choose the allowed option and accept the pledge before the preference is saved.
6. If the backend marks an option as blocked, the app displays the backend message and does not save the preference.
7. The schedule screen blocks final submit when the restricted preference is selected without confirmation.

## Request payload

```json
{
  "genderPreference": "female",
  "workEnvironmentConfirmation": {
    "beneficiaryPresence": "female_present",
    "pledgeAccepted": true,
    "pledgeVersion": "female-worker-safety-v1"
  }
}
```

Other preferences keep the previous request shape and do not send `workEnvironmentConfirmation`.
