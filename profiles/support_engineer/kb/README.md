# Knowledge base

Known issues and answers, one markdown file per topic (`kebab-case.md`), so the next person with the
same problem gets an answer fast. Check here before investigating; add or update a file after solving
something likely to come back. No customer names, emails or other personal data.

## Index

<!-- One line per file: - [Title](file.md): symptom in a few words. Keep it sorted by title. -->

## Entry format

```markdown
# <Title: the symptom as a customer would describe it>

- Status: open bug | fixed in <version/date> | expected behavior | workaround only
- Last confirmed: YYYY-MM-DD
- Related: <ticket / pull request / DECISION.md entry>

## Symptoms
What the customer sees (error text, screen, behavior).

## Cause
What's actually going on, in plain words (with code pointers for engineers if useful).

## Fix or workaround
Steps the customer or the team can take.

## Reply that worked
A short customer-ready answer, in the tone from CONTEXT.md.
```
