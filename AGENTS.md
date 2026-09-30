# easyTitanic — agent context

Handoff notes for this folder. Written to be read cold by a future session.

**This folder holds two standalone HTML lessons for high-school beginners, both on PostgreSQL.**
(1) `titanic_quiz.html` — 12 self-grading questions over the `sqltitanic` database, with
`titanic.sql` as its dataset. (2) `laliga_joins.html` — a La Liga lesson that shows *why* joins
exist, with `laliga.sql` as its dataset. Both pages grade themselves, save answers to
localStorage, and offer a per-question hint plus a reveal-the-SQL answer. Nothing on either page
is invented — every number was read off a real query against the live server (§5, §8), and that
is the folder's only asset.

DSH loads this file as workspace instructions, so anything stated here as a rule is meant to
bind future sessions. Keep it true: a wrong fact here is worse than no file, because the next
session will trust it instead of re-checking.

---

## 1. Environment facts (hard-won — re-deriving these wastes a session)

* **Same physical tree as the sibling Windows projects, seen from the other side.**
  The user works on Windows at `E:\postgres\easyTitanic`; this Linux session sees the
  *identical* files at `/mnt/7E3875FB3875B2AF/postgres/easyTitanic`.
  Mapping: `E:\` ↔ `/mnt/7E3875FB3875B2AF`. So a Linux path here and a Windows path in a
  sibling `AGENTS.md` can name the same file — do not treat them as different machines.
* OS/user: Ubuntu box (`tinyPC`), user `kdowd`, bash. **Every tool call is a fresh process** —
  no `cwd`, variables or functions carry over. Pass `workdir:` instead of using `cd`.
* `psql` is **18.6**; the server is up on `/var/run/postgresql:5432` (`pg_isready` → accepting).
* **Plain `psql` fails here:** `FATAL: role "kdowd" does not exist`. There is no role for the
  OS user — always connect as `psql -U postgres -d <db> ...`. Local socket auth is `trust`, so
  no password flags are needed.
* **`sudo` is unusable** — `The "no new privileges" flag is set, which prevents sudo from
  running as root`. Do not plan around it.
* **`/tmp` does NOT persist between bash tool calls.** Each call appears to get a fresh
  `/tmp`, so a file written in one call is gone by the next. Either do the whole
  write → use → read inside **one** call, or write scratch files into the workspace.
  This was learned the hard way: a screenshot written to `/tmp` in one call had vanished
  before the next call could read it.
* **`read_image` is sandboxed to the workspace.** It cannot read `/tmp/quiz.png`. Copy or
  screenshot the image into the workspace first, then read it.
* **Headless Chrome works and is the way to verify the UI.** Verified recipe:

  ```bash
  google-chrome --headless=new --disable-gpu --no-sandbox \
    --user-data-dir=/tmp/cprof --virtual-time-budget=5000 \
    --dump-dom  "file://$PWD/page.html"   # or --screenshot=... / --window-size=900,1200
  ```

  **`--user-data-dir` is required** — without it Chrome dies instantly with
  `Failed to create headless user data directory container`. Chrome creates that directory
  (and any missing parents) itself, so **no `mkdir` is needed** — verified. `--dump-dom` marks
  newlines literally in the text, so match across lines with `[\s\S]` rather than `.`.
  Harmless stderr noise to ignore: Crashpad and `dconf` `Read-only file system` lines.
* Tooling present: `node` **v22.22.1**, `google-chrome`, `firefox`, `python3`.
  **No puppeteer / playwright** — drive Chrome by CLI and parse the output.
* File sandbox is **workspace-write**; writes outside the workspace need approval.
* **The sibling `AGENTS.md` files describe other folders, not this one.**
  `../../dsh_projects/basic_psql/AGENTS.md` is long and excellent but is explicit that it is a
  *Windows-only* project (`pwsh`, scoop, `C:\...`) with **no browser available** — the exact
  opposite of this session, which is Linux **with** a browser. Take the user's *habits* from
  those files (2-space indent, verify-don't-guess, announce revisions); do **not** take their
  environment facts. `supabaseConnect` / `normalsVideo` / `WPF/WPFWithSB` likewise.

---

## 2. What this project is

Two independent lessons, each a single self-contained HTML file plus its own data loader:

| Lesson | Files | What it teaches |
|---|---|---|
| Titanic quiz | `titanic_quiz.html` + `titanic.sql` | 12 graded questions — `COUNT`, `WHERE`, `AND`, `IS NULL`, and two closing `JOIN`s — over `sqltitanic` |
| La Liga joins | `laliga_joins.html` + `laliga.sql` | *Why* joins exist: one flat table → its anomalies → split into two → `JOIN` them back. Full write-up in §8 |

`answers.js` (**0 bytes, the user's own**) — see §7.

Design brief for the quiz (as given by the user): teach postgres/psql to **high school students**; 12
questions; **easiest first, the two table-join questions last**; save answers to
localStorage so a refresh does not lose work. Confirmed choices at build time:

* **Answers are plain numbers**, not SQL text — auto-grading stays unambiguous and students
  run the query in `psql` themselves. The reveal panel shows the model SQL.
* **Both** a "Check Answers" grader **and** an optional "Reveal Answer" per question.
* **Standalone static HTML** — opens over `file://`, no server, no CDN, no network. This was
  chosen deliberately over a live query runner.
* **Full scaffolding**: schema cheat sheet, per-question hints, difficulty badges, concept tags.

**Level ceiling — stated by the user, do not raise it.** This student's level stops at
`COUNT`, `WHERE`, `AND`, `<`, `IS NULL`, and a first `JOIN` with one filter. The sibling
`../titanicSQL/titanic-sql-lesson.html` is **too difficult for this student and is not a
template** — measured from its `answers.js`: Q5 is already `ROUND(AVG(age),2)`, Q6 is
`JOIN + GROUP BY`, Q7 a `GROUP BY` percentage, Q8–Q9 join the `tickets` table for `fare`,
Q10 puts arithmetic in `WHERE` (`sibsp + parch > 0`), Q11 is a **scalar subquery**
(`fare > (SELECT AVG(fare) FROM tickets)`), Q12 is `CASE WHEN + GROUP BY`. Its user-visible
answers are also decimals (`29.70`, `13.68`, `512.33`) where this quiz uses whole numbers.
Nothing from it is to be imported here; keep every new question inside the rungs in §5.

The teaching shape is the `learning-designer` skill's difficulty ladder — each rung changes
roughly one thing (new filter → new aggregate → `AND` → `IS NULL` → `JOIN`). The skill source
lives in a sibling repo, **not** in this workspace's skill catalog:
`/mnt/7E3875FB3875B2AF/dsh_projects/psqlLearn/.dsh/skills/learning-designer/SKILL.md`
(+ `lesson-template.md`; a second copy sits under `DatabasePostGres/psqlLearn/`). Read those
files directly; the `skill` tool cannot load it from here unless a copy is placed in
`.dsh/skills/` here and the session is restarted.

### How the page is built (read this before editing)

Everything is in one inline `<script>` IIFE. The question bank is the `QUESTIONS` array; each
entry is:

```js
{ n, level: "Easy"|"Medium"|"Hard", concept, join?: true,
  text, answer: <number>, hint, sql, note? }
```

`renderQuestions()`-style string building injects one `<section class="q" id="qN">` per entry,
so **question markup is not in the HTML** — add or change questions in the array, not in the
body. Per-question element ids follow a strict pattern: `ansN`, `iconN`, `hintN`, `revealN`,
and buttons found via `.hint-btn[data-n="N"]` / `.reveal-btn[data-n="N"]`.

* **localStorage**: two keys. **`titanicQuiz.v1`** holds the work — shape
  `{ answers:{}, hints:{}, revealed:{} }`, written on every `input` and toggle; restore happens
  once at startup. Grading normalises the input (strips commas/whitespace/leading `$`) and
  compares numerically with a `1e-4` tolerance. **`titanicQuiz.fabPos.v1`** holds the dragged
  button position `{ left, bottom }` (see below) — deliberately a *separate* key so `Clear All`
  wipes answers without moving the button.
* **Two check buttons, one function.** `checkAnswers(scrollToScore)`:
  * `#checkBtn` in the sticky toolbar → `checkAnswers(true)` → scrolls to the score banner.
  * `#checkBtnFab` in the floating layer → `checkAnswers(false)` → **no scroll**, and writes a
    compact result into `#fabChip` instead (the whole point of the floating layer is to check
    from wherever you are).
  * The floating layer is `.fab-layer` — `position: fixed; right/bottom: 22px; z-index: 60`
    (above the sticky toolbar's 30). Footer carries `padding-bottom: 110px` so the button never
    covers the last content. Keep those two numbers in sync if either changes.
  * **The layer is draggable** (added at the user's request; there is no close button and there
    must not be one). It uses Pointer Events and is found by
    `document.querySelector(".fab-layer")`. It anchors on **left + bottom** and not left + top —
    that is deliberate, so the layer grows *upward* when `#fabChip` appears and the button never
    shifts under the user's pointer. Verified: the button's bottom edge is unchanged when the
    chip appears. A gesture past 4 px counts as a drag, and a capture-phase `click` handler on
    the layer swallows the trailing click so **dragging never triggers Check Answers**, while a
    plain click still does. Position is clamped to a 10 px margin, re-clamped on `resize` and by
    a `ResizeObserver`, and persisted to `titanicQuiz.fabPos.v1`.
  * The visible **drag affordance** is a 2×3 dot grip, `.fab-grip`, inside the button to the left
    of the label. It is pure CSS (`radial-gradient` dots, `currentColor`) so it needs no icon
    file, is `aria-hidden`, and brightens from `.5` to `.95` opacity on hover and while
    dragging. The button's native `title` also reads *"Click to check answers — drag to move"*.
    Dragging works when the gesture starts on the grip, on the label, or on the chip.
* The page **builds its own answer key into the file**. That is the accepted tradeoff of the
  standalone choice; there is no live verification at runtime.

---

## 3. Hard rules — do not repeat these mistakes

1. **Never invent psql output or a row count.** Every number in the quiz was taken from a real
   query against `sqltitanic`. If you add or change a question, run the query first and paste
   what came back. Plausible-looking is not the same as verified.
2. **Re-read `titanic_quiz.html` before editing it.** The user edits this file themselves
   between sessions — they once reformatted the entire document and added a new "Before you
   start" panel without telling the agent. Editing from memory will clobber their work.
3. **Match the user's formatting: 2-space indent** in HTML/CSS/JS, and they let Prettier
   expand otherwise-compact CSS blocks. Do not "tidy" their wrapping or collapse their rules
   unasked.
4. **Leave the user's own files alone** — `answers.js` (empty, theirs), anything under
   `../titanicSQL/`, and every database except as a read. Do not edit their databases to make
   a number fit; fix the quiz instead.
5. **Verify UI changes in a real browser, never structurally alone.** Tag-balance checks are a
   smoke test, not proof — the malformed `<div>` nesting found in §7 passed every naive check
   and only the rendered page exposed the missing styles. Use the Chrome recipe in §1.
6. **Announce any revision to a file the user may already have opened** (borrowed from
   `basic_psql` §3.10). One line of "I changed X" prevents a debugging round trip.
7. **Standalone means standalone.** No external fonts, CDNs, ES modules or `fetch` — the page
   must keep working when double-clicked offline. Inline everything.
8. **`titanic_quiz.html` and `../titanicSQL/` are two separate lessons.** `titanicSQL` is the
   earlier/richer one: its `titanic.sql` is 212,633 bytes (vs 166,125 here) and its database
   `titanic` has a **third table, `tickets`**, which `sqltitanic` does not. Do not cross-edit,
   and do not assume a `tickets` table exists in `sqltitanic`.
9. **Less is more — the user's own verdict.** On the trimmed joins page their words were
   *"thats better, less wordy.....clearer, less is more"*. They value brevity over completeness.
   Prefer the shortest version that still teaches: cut an aside rather than explain it, and do
   not add callouts, extra worked examples or encouragement that the teaching does not need.
   Applies to the pages and to chat replies.

---

## 4. Verification recipes that actually work here

**A. Every answer, re-derived from the database** (run from the workspace):

```bash
psql -U postgres -d sqltitanic -tAc "SELECT COUNT(*) FROM passengers;"   # → 891
```

**B. Extract the question bank and run its SQL for real.** Parse `answer:` / `sql:` pairs out of
the file with node, write each `sql` to a `.sql` file, and run it with `psql -f`. Comparing the
result to the `answer` field is the only check that catches a wrong expected value. Do this
after any edit to `QUESTIONS`.

**C. UI behaviour, in a real browser.** Append a test `<script>` to a *copy* of the page that
drives the DOM (set inputs, dispatch an `input` event, click `#checkBtnFab`/`#checkBtn`, read
`#fabChip` / `#scoreBig` / `classList`), write the assertions into a hidden `<pre id="TESTOUT">`,
then `--dump-dom` and regex that element out. This caught nothing short of real behaviour:
grading, chip text, "did not scroll", `localStorage` contents, hint/reveal persistence.

**D. Persistence across a genuine reload.** Serve the same page twice under one
`--user-data-dir` — phase 1 types answers in, phase 2 (same URL, no typing) only *reads* the
inputs and asserts they were restored. Note `html { scroll-behavior: smooth }` means
`scrollIntoView` is animated; a screenshot taken too early catches the page mid-scroll and
will look like the scroll never happened.

**E. Structure only (fast smoke test, not proof):** count `<div>`/`</div>`, `<section>`,
`<details>` pairs, and `node --check` the extracted `<script>`. Balanced tags are necessary,
not sufficient (rule §3.5).

---

## 5. Test oracles — the dataset, verified

`sqltitanic`: **891 passengers**, **3 ports**. Schema (all columns, lightly cleaned):

```sql
ports(id INT, embarked VARCHAR(1), city VARCHAR(100))
passengers(id INT, survived DECIMAL, pclass DECIMAL, name VARCHAR(100), sex VARCHAR(6),
           age DECIMAL, sibsp INT, parch INT, cabin VARCHAR(100), ticketId INT, portId INT)
```

`survived` is `0`/`1`, `pclass` is `1`/`2`/`3`, `age` **and** `cabin` can be `NULL`.
Port ids: 1 Southampton, 2 Cherbourg, 3 Queenstown.

| Fact | Value |
|---|---|
| Passengers / survivors / died | 891 / **342** / 549 |
| Sex | 314 female, 577 male |
| Female survived / died | **233** / 81 |
| Male survived / died | 109 / **468** |
| By class (total / survived) | 1st 216/**136**, 2nd 184/87, 3rd **491**/119 |
| Age NULL | **177** |
| Age range (non-null) / mean | 0.42 – 80 / **29.70** |
| Under 5 / under 5 who survived | **40** / 27 |
| Age ≤ 12 / ≤ 17 | 69 / 113 |
| Travelled alone (`sibsp=0 AND parch=0`) | **537** |
| Distinct names / ticketIds / cabins | 891 / 681 / 147 |
| Ports (total / survived) | Southampton 644/**217**, Cherbourg **168**/93, Queenstown 77/30 |
| **`portId` is NULL** | **2 passengers** (ids 62, 830) → `INNER JOIN` = **889** rows, `LEFT JOIN` = 891 |

### The 12 questions, in order, with their model SQL

Easy → hard; the last two are the only joins. Regenerate with recipe §4B.

| # | Level | Concept | Question | Ans | SQL |
|---|---|---|---|---|---|
| 1 | Easy | `COUNT(*)` | passengers listed | 891 | `SELECT COUNT(*) FROM passengers;` |
| 2 | Easy | `WHERE` | how many survived | 342 | `... WHERE survived = 1;` |
| 3 | Easy | text filter | how many female | 314 | `... WHERE sex = 'female';` |
| 4 | Easy | `<` | children under 5 | 40 | `... WHERE age < 5;` |
| 5 | Medium | `AND` | females who survived | 233 | `... WHERE sex='female' AND survived=1;` |
| 6 | Medium | `WHERE` | 3rd class | 491 | `... WHERE pclass = 3;` |
| 7 | Medium | `AND` | 1st class who survived | 136 | `... WHERE pclass=1 AND survived=1;` |
| 8 | Medium | `IS NULL` | no age recorded | 177 | `... WHERE age IS NULL;` |
| 9 | Hard | `AND` | male passengers who died | 468 | `... WHERE sex='male' AND survived=0;` |
| 10 | Hard | two columns | travelled completely alone | 537 | `... WHERE sibsp=0 AND parch=0;` |
| 11 | Hard | **JOIN** | boarded at Cherbourg | 168 | `FROM passengers p JOIN ports pt ON pt.id=p.portId WHERE pt.city='Cherbourg'` |
| 12 | Hard | **JOIN+AND** | Southampton who survived | 217 | as #11, `WHERE pt.city='Southampton' AND p.survived=1` |

Two teaching notes are baked into the reveals and **should survive future edits**: #11 explains
*why* a join is needed (passengers stores only `portId`, not the city name), and #12's note
states the 2-NULL-`portId` fact above (889 vs 891). #8 exists deliberately because `= NULL` is
the classic beginner trap.

### Databases on this server (do not touch the user's)

| Database | What it is |
|---|---|
| `sqltitanic` | **this project's target** — `passengers` (891) + `ports` (3) |
| `titanic` | sibling `../titanicSQL` lesson — same 891 rows **plus a `tickets` table** |
| `kjd_db`, `landreg` | the user's own — do not modify |
| `postgres`, `template0/1` | system |

Both `titanic` and `sqltitanic` exist. Note the page's "Before you start" panel tells the
reader `CREATE DATABASE titanic;` while this project uses `sqltitanic` — see §7.

---

## 6. File inventory

| File | Purpose |
|---|---|
| `AGENTS.md` | this file |
| `titanic_quiz.html` | 12 self-grading questions; inline CSS + JS; localStorage `titanicQuiz.v1` (answers) + `titanicQuiz.fabPos.v1` (draggable button position) |
| `titanic.sql` | dataset loader: `ports` + `passengers`, 166,125 bytes |
| `laliga_joins.html` | the JOINs lesson page; inline CSS + JS; localStorage `laligaJoins.v2` (§8) |
| `laliga.sql` | La Liga loader: `players_flat` (24) + `teams` (6) + `players` (24); re-runnable, `DROP … IF EXISTS` first |
| `answers.js` | **the user's** — empty (0 bytes) at last check; do not fill unasked (§7) |
| `openmoji--titanic.svg` | **the user's** — an OpenMoji Titanic icon that appeared during a review session. Not referenced by either page; purpose unstated. Leave alone |

---

## 7. Current state / open threads

**State at handoff:** nothing in progress, no background jobs, no scratch databases left on the
server (verification databases were dropped each time). Everything the user asked for has been
built, browser-verified and signed off. The only open items are the two unanswered questions
about the floating layer, listed below — do not act on them unasked.

* **The quiz is built, verified and handed over.** It was validated by: all 12 SQL statements
  run against `sqltitanic`; a headless-Chrome functional test (12/12 → `12 / 12 (100%)`, one
  wrong → `11 / 12`, chip text, no forced scroll, 12 stored answers); and a real two-phase
  reload test proving inputs, open hint and progress all restore. **The user reviewed it and
  signed off** (*"good job"*), with no defects reported.
* **The La Liga joins lesson is new** (built at the user's request, this session) and verified
  the same way — full write-up in §8. Its player/club data is a small **illustrative sample**,
  not a live roster; the page is written so it never claims otherwise.
* **User edits to watch for.** They reformatted the whole file (Prettier-expanded CSS) and
  added a **"Before you start"** block inside the schema `<details>`. That block arrived with
  two unbalanced `</div>`s and referenced `.grid2` / `.code` classes that had no CSS; both were
  repaired (styles added, tags closed, `<pre>` whitespace collapsed, footer `padding-bottom`
  50→110px for the floating button). **Re-read before editing — rule §3.2.**
* **The floating Check Answers layer** was added first: a `position: fixed` duplicate of the
  toolbar button plus a result chip, so it is reachable at any scroll position. It was then made
  **draggable** on request ("a nice UI touch") — repositionable anywhere, deliberately **not**
  closable, with the position remembered. Both are working and verified (§2 has the mechanics).
  **Open question left with the user:** whether the chip should also appear when the *top*
  button is used, and whether the floating button should hide until the toolbar scrolls away.
  No reply yet — do not implement unasked.
* **`answers.js` is empty (0 bytes, created 14:45 by the user).** The sibling `../titanicSQL`
  project has a *populated* `answers.js` holding a different 12-question bank (`id`, `skill`,
  `checkable`, `expected`, `tolerance`, `modelSql`, `result`, `explain`) loaded externally by
  `main.js`. The presence of an empty same-named file here suggests the user may be planning to
  externalise this page's question bank the same way. **Speculation — ask before acting.** If it
  is ever asked for, reuse only the *mechanism*; its questions are above this student (§2).
* **Text inconsistency flagged, left as-is:** the "Before you start" panel says
  `CREATE DATABASE titanic;`, but this project uses **`sqltitanic`** (the footer's
  `psql -U postgres -d sqltitanic` is correct). A `titanic` database does exist, so the line is
  not nonsense — but the load commands (`\i titanic.sql`) will only work against whichever
  database the reader actually connected to. The user was told; they have not asked for a fix.
* **Deliberately declined by the user:** a teacher answer-key page, a printable PDF, and bonus
  `GROUP BY` questions. Do not re-offer unasked.
* **No `.dsh/skills/` here**, so the `learning-designer` skill does not auto-load for this
  workspace — its source is in `../psqlLearn/.dsh/skills/` (§2). Copying it in would make it
  available, but that was offered to a sibling project once and never taken up; ask first.
* `../titanicSQL/` is a related but separate lesson (`titanic-sql-lesson.html` + `main.js` +
  populated `answers.js` + `titanic.sql` @212 KB). Read-only context — and its difficulty is
  **above this student** (level ceiling, §2), so never import its questions. Its *mechanism*
  (an external `answers.js` bank loaded by `main.js`) is a separate question and may be worth
  copying **only if the user asks**.

---

## 8. The La Liga joins lesson (`laliga_joins.html` + `laliga.sql`)

Built at the user's request: *"a separate html page to introduce the concept of joins — first
use a single table to demonstrate the problem, next split the table into 2 tables and
demonstrate the join"*, using **Spanish La Liga** data because the class follows football. It is
a *concept* page rather than a quiz, though it ends with 4 graded questions.

**Page order** — each section is a `<section class="part" id="…">`: `goals` → `setup` → `part1`
(one flat table and its anomalies) → `part2` (split into `teams` / `players`) → `part3` (the
JOIN) → `traps` (the two failure modes) → `practice`.

**Data (`laliga.sql`)** — 6 clubs × 4 players = 24 rows, one player per position:

| Table | Rows | What it is |
|---|---|---|
| `players_flat` | 24 | the "before": `team_name`, `city`, `stadium` repeated on every player row |
| `teams` | 6 | Real Madrid, FC Barcelona, Atlético de Madrid, Athletic Club, Sevilla FC, Real Sociedad |
| `players` | 24 | `team_id` FK → `teams`; carries **no** club name, city or stadium |

Both states coexist on purpose so students can compare them. The file opens with
`DROP TABLE IF EXISTS` for all three, so it is safe to re-run — the page tells students to
re-run it after the destructive demos in Part 1.

**Verified numbers — re-derived from a live load. Never restate these from memory:**

| Claim | Value |
|---|---|
| `players_flat` rows / distinct clubs | 24 / **6** |
| distinct cities | **5** (Madrid holds two clubs) |
| correct join `players ⋈ teams` | **24** rows |
| players at a Madrid club | **8** |
| players at Bilbao / at Sevilla | 4 / 4 |
| goalkeepers / defenders / midfielders / forwards | 6 each |
| **`FROM players, teams`** with no link | **144** = 24 × 6 |
| `JOIN` with no `ON` clause | **syntax error** — Postgres refuses to run it, it does *not* give 144 |
| wrong key `ON t.team_id = p.player_id` | **6** rows, mostly **wrong** pairings, **no error** |
| `UPDATE players_flat … WHERE team_name='Sevilla FC'` | `UPDATE 4` (the same fix on `teams` is `UPDATE 1`) |
| missing a row during that update | two different stadiums stored for one club |
| `DELETE FROM players_flat WHERE team_name='Sevilla FC'` | `DELETE 4` → 20 rows / **5** clubs; the club is gone |
| insert a club with no players (flat) | `INSERT 0 1` — a row with a NULL player |
| FK violation `team_id = 99` | `violates foreign key constraint "players_team_id_fkey"` |
| player with `team_id NULL` | 25 players; `JOIN` → 24, `LEFT JOIN` → 25 |

Two of these are now **verified but no longer displayed** after the simplification below: the
`LEFT JOIN` = 25 result, and the `UPDATE 1` half of the Sevilla row. Both remain true; they are
simply not on the page any more.

**Practice answers** (localStorage key **`laligaJoins.v2`** — bumped from `v1` when the set was
cut from 6 questions to 4, so stale localStorage from the longer set cannot be mismatched against
the new numbering): `6, 24, 8, 144` — every one verified by running the page's own SQL against
the loaded data.

**Simplified on the user's instruction (page is now ~46 KB, was ~51 KB).** Part 1 — "The problem:
one big table" — was called out as very good and is **kept verbatim; do not cut it**. Everything
after it was trimmed: the clause-by-clause breakdown table, the separate `WHERE`-across-a-join
worked example, Part 2's "What the split fixes" callout and its `UPDATE 1` payoff block, the
whole `LEFT JOIN` / NULL "going further" subsection, and 2 of the 6 practice questions. The
clause table and `.callout.win` CSS rules are now unused but were **left in place** — harmless,
and cheap to restore. If asked to simplify again, the next candidates in order are: the
syntax-error trap (keeping the 144 and wrong-key traps), then the practice set.

**Design decisions worth preserving:**
* The page teaches **three** failure modes, not one: no link (144 rows), SQL that refuses to run,
  and the **wrong** link (6 plausible-but-wrong rows). The wrong-key demo is the strongest
  teaching moment in the file — do not cut it for brevity.
* `GROUP BY` and `AVG` are **deliberately absent** (level ceiling, §2). All counting is
  `COUNT(*) … WHERE`, never per-group.
* Every answer is a whole number.
* The player/club data is an **illustrative sample**, and the page never claims otherwise: club
  names are real and stable, but squads change every season. If asked for "current" data, say
  this rather than asserting a roster.
* Accents are kept in the data (`Atlético`, `San Mamés`, `Éder`) and the page warns students to
  load via `-f` / `\i` instead of typing accented literals into a Windows terminal — see
  `basic_psql` §3.11 for that exact failure mode.
* The figure worth re-checking first if anything looks wrong: **144 vs 24**. Those two numbers
  are the whole lesson in miniature.
