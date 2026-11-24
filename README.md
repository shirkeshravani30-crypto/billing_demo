# Billing demo: see how a web page creates data in MySQL

A small shop billing page. Each bill you save becomes rows in MySQL
(`bills`, `bill_items`, and lower `stock` in `products`). The receipt page
shows the exact SQL that ran.

## Files

| File | What it is |
| --- | --- |
| `schema.sql` | Creates the `billing_demo` database, 3 tables and 10 products |
| `app.py` | The web page (Python + Flask) |
| `practice_queries.sql` | SELECT / UPDATE / DELETE / ALTER queries to run after making bills |
| `requirements.txt` | Python packages needed |

## Run it (about 5 minutes)

1. **Create the database.** Open `schema.sql` in VS Code, select all and run it
   (`Ctrl+E Ctrl+E`) on your MySQL connection.
2. **Install the packages.** Open a terminal in this folder (VS Code: `` Ctrl+` ``):
   ```
   pip install -r requirements.txt
   ```
3. **Set your password.** In `app.py`, change `"password": "your_password_here"`
   to your MySQL password.
4. **Start the page.**
   ```
   python app.py
   ```
5. **Open** http://127.0.0.1:5000 in a browser.

## Demo flow for class

1. Run `SELECT * FROM bills;` in VS Code. It is empty.
2. Make 3–4 bills on the page for different customers and payment modes.
3. Look at the "SQL that just ran" box under each receipt.
4. Run Part 1 of `practice_queries.sql`. The rows are there.
5. Run the UPDATE and DELETE parts, then refresh "All bills" to see the page change.
6. Finish with the reports in Part 6.

## If something fails

- **Could not talk to MySQL**: check MySQL is running and the password in `app.py`.
- **Unknown database 'billing_demo'**: run `schema.sql` first.
- **`pip` not found**: try `python -m pip install -r requirements.txt` (or `pip3`).
- **Port 5000 busy** (common on Mac): change the last line of `app.py` to
  `app.run(debug=True, port=5050)` and open http://127.0.0.1:5050.
