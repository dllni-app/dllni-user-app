# Open-time override

- Before confirmation, explain the expected ceiling, hard ceiling, one-hour minimum, 15-minute rounding, worker count, and maximum estimate.
- During work, place elapsed time and live amount first. Use the API `serverNow` anchor and stable/tabular digits.
- Show a single primary action appropriate to state: request extension or request end. Pending decisions replace the action with status and retry/recovery guidance.
- Hard-limit and disagreement states must name the administrative escalation path without silently selecting another worker.

