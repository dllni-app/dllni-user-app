from pathlib import Path

path = Path('docs/cleaning-suite-port-map.md')
text = path.read_text(encoding='utf-8')

section_heading = '### Recurring Cleaning per-session settlement / review / dispute slice'
section = '''### Recurring Cleaning per-session settlement / review / dispute slice

Implemented end-to-end and ported selectively to both User App feature branches:

- Each child visit owns independent settlement/payment-readiness state; service completion does not claim that customer payment was captured.
- Admin commission settlement is idempotent per session and worker, so recurring visits for the same worker settle independently.
- Parent booking completion skips booking-level commission charging when child sessions exist, preventing a second charge after the final visit; legacy single-day bookings retain their existing booking-level path.
- Customer reviews are independent per completed session and worker, so the same worker can receive a separate review for separate visits.
- Only one active dispute can exist for a session at a time; the session payload exposes the active dispute state and identifier.
- User App recurring visit cards expose settlement state, per-visit review, and per-visit dispute actions using server-authoritative capabilities.
- Event Assistance keeps its existing whole-event multi-worker review flow; recurring visits do not reuse that aggregate review UI.

Verification:

- Backend per-session interaction implementation commit: `11e8934715f8e708d254e38ce433e5b420089fb2`.
- Backend permanent recurring CI: run `34033021594`, green.
- User main per-session interaction UI commit: `d60df5f7c83b73f3e2fcd6b70cabb0c8589f3a92`.
- User main final permanent recurring CI: run `34034325685`, green.
- User dev selective per-session interaction port commit: `9f144583eb43ea07bd06c6b0c9e4199b19d451ac`.
- User dev permanent recurring CI: run `34034276119`, green.
- User dev general Cleaning Suite CI for the same port: run `34034276149`, green.

Status: recurring per-session settlement/payment-readiness, review and dispute parity verified for this slice. This does not declare whole-branch parity.

'''

if section_heading not in text:
    marker = '### Multi-Day Event Assistance'
    if marker not in text:
        raise SystemExit('Multi-Day marker not found')
    text = text.replace(marker, section + marker, 1)

text = text.replace('- Per-session payment, review and dispute completion.\n', '')
path.write_text(text, encoding='utf-8')
