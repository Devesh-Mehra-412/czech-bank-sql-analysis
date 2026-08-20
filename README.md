# Czech Bank Loan & Transaction Analysis (SQL)

SQL-only analysis of a real, anonymized retail banking dataset — accounts, clients, loans, cards, and over a million transactions from a Czech bank (1993–1998).

## Dataset

This is the **Berka dataset**, also known as the PKDD'99 Financial Dataset — real anonymized transaction data released by a Czech bank for the 1999 PKDD Discovery Challenge. It is not synthetic or generated; it's actual historical banking activity, anonymized for public release (as any legally shareable bank data has to be).

- Source: [PKDD'99 Discovery Challenge](https://sorry.vse.cz/~berka/challenge/pkdd1999/berka.htm), prepared by Petr Berka and Marta Sochorova
- Mirror used here: [Kaggle — The Berka Dataset](https://www.kaggle.com/datasets/marceloventura/the-berka-dataset)

**8 tables, ~1.07M rows total:**

| Table | Rows | Description |
|---|---|---|
| `account` | 4,500 | One row per bank account |
| `client` | 5,369 | One row per client |
| `disp` (disposition) | 5,369 | Links clients to accounts (`OWNER` / `DISPONENT`), since one account can be shared |
| `district` | 77 | Demographics per region — population, average salary, unemployment, crime rate |
| `loan` | 682 | Loans issued against accounts, with status |
| `card` | 892 | Credit cards issued (linked via `disp`, not directly to client) |
| `order` (renamed `order_t` — `order` is a reserved SQL word) | 6,471 | Standing/permanent payment orders |
| `trans` | 1,056,320 | Individual transactions — deposits, withdrawals, transfers |

See the ER diagram for how these connect — the short version: `district → client/account`, `client ↔ account` via `disp`, and `disp/account → card/loan/order/trans`.

### A note on loan status codes
- `A` — contract finished, no problems
- `B` — contract finished, loan **not** paid (default)
- `C` — running contract, OK so far
- `D` — running contract, client **currently in debt**

No cleaning was needed or performed — the data is used as released.

## Why SQL only (no Python/pandas)

This project is intentionally scoped to demonstrate SQL fundamentals directly against a real relational schema, since that's the core skill being tested in most banking/data analyst interviews. The dataset is genuinely relational (not one flat file), so joins across `account`, `client`, `disp`, `loan`, `card`, and `district` are necessary, not decorative.

## SQL concepts covered (`queries.sql`)

| # | Query | Topics used |
|---|---|---|
| 1 | Loans currently in debt (status `D`) | `SELECT`, `WHERE` |
| 2 | Large cash withdrawals in 1998 | `WHERE`, date filtering |
| 3 | Loan count & exposure by status | `GROUP BY`, aggregates |
| 4 | Districts with 15+ loans issued | `JOIN`, `GROUP BY`, `HAVING` |
| 5 | Plain-English risk flag per loan | `CASE WHEN` |
| 6 | Loan size tiers vs. default rate | `CASE WHEN`, `GROUP BY` |
| 7 | Client + home district + account | multi-table `JOIN` |
| 8 | Avg loan amount by region | `JOIN`, `GROUP BY` |
| 9 | Clients holding both a loan and a card | multi-table `JOIN` |
| 10 | Rank loans by amount within status | `RANK() OVER (PARTITION BY ...)` |
| 11 | Rank districts by salary within region | `RANK() OVER (PARTITION BY ...)` |
| 12 | Top 3 highest loans per region | window function + subquery |

All queries were run and verified against the real ~1M-row dataset (not just written and assumed to work).

## Key findings

- Of 682 total loans, **45 accounts are currently in active debt** (`status = D`) and **31 have historically defaulted** (`status = B`) — a combined ~11% of all loans issued.
- Larger loans carry more risk: loans in the "small" tier (<50k) have a ~4% risky rate, versus higher rates in the larger tiers — worth flagging for underwriting review.
- Loan activity and exposure are heavily concentrated in **Prague**, which has both the highest loan count and highest total exposure of any district.
- 170 clients hold both a loan and a credit card — a natural segment for relationship banking / cross-sell outreach.

## Tools

Queries were written and run against a SQLite database loaded directly from the raw CSVs — no ORM, no pandas, no data cleaning layer. SQLite was chosen for portability (single file, zero setup); the SQL itself uses standard syntax that transfers directly to PostgreSQL/MySQL with minor date-function differences.

## What I'd add next

- A join against `card` + `order` to build a fuller "customer relationship value" score
- Time-series analysis of `trans` (1M+ rows) — monthly balance trends per account
- A small Power BI/Tableau layer on top of the query outputs, if a visual layer is wanted later
