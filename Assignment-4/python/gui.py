"""Tkinter GUI for the employee shift scheduler.

Lets a user build a roster (name + a ranked shift preference per day of the
week), then generates and displays the weekly schedule produced by the same
scheduler.py engine the CLI uses.
"""

import json
import tkinter as tk
from pathlib import Path
from tkinter import messagebox, ttk

from models import DAYS, SHIFTS, build_roster
from scheduler import format_schedule, run_schedule

DATA_FILE = Path(__file__).parent / "data" / "employees.json"
NONE_CHOICE = "(none)"


class EmployeeDialog(tk.Toplevel):
    """Modal form for adding or editing one employee's name and ranked
    shift preferences for each day of the week."""

    def __init__(self, parent, existing=None):
        super().__init__(parent)
        self.title("Edit Employee" if existing else "Add Employee")
        self.resizable(False, False)
        self.result = None

        name_frame = ttk.Frame(self, padding=10)
        name_frame.grid(row=0, column=0, sticky="ew")
        ttk.Label(name_frame, text="Employee name:").grid(row=0, column=0, sticky="w")
        self.name_var = tk.StringVar(value=(existing or {}).get("name", ""))
        ttk.Entry(name_frame, textvariable=self.name_var, width=25).grid(row=0, column=1, padx=5)

        prefs_frame = ttk.Frame(self, padding=10)
        prefs_frame.grid(row=1, column=0)
        ttk.Label(prefs_frame, text="Day").grid(row=0, column=0)
        ttk.Label(prefs_frame, text="1st choice").grid(row=0, column=1)
        ttk.Label(prefs_frame, text="2nd choice (optional)").grid(row=0, column=2)

        existing_prefs = (existing or {}).get("preferences", {})
        self.first_vars = {}
        self.second_vars = {}
        for row, day in enumerate(DAYS, start=1):
            day_prefs = existing_prefs.get(day, [])
            first = day_prefs[0] if len(day_prefs) > 0 else SHIFTS[0]
            second = day_prefs[1] if len(day_prefs) > 1 else NONE_CHOICE

            ttk.Label(prefs_frame, text=day).grid(row=row, column=0, sticky="w", padx=5, pady=2)

            first_var = tk.StringVar(value=first)
            ttk.Combobox(prefs_frame, textvariable=first_var, values=SHIFTS,
                         width=12, state="readonly").grid(row=row, column=1, padx=5)
            self.first_vars[day] = first_var

            second_var = tk.StringVar(value=second)
            ttk.Combobox(prefs_frame, textvariable=second_var, values=[NONE_CHOICE] + SHIFTS,
                         width=12, state="readonly").grid(row=row, column=2, padx=5)
            self.second_vars[day] = second_var

        button_frame = ttk.Frame(self, padding=10)
        button_frame.grid(row=2, column=0, sticky="e")
        ttk.Button(button_frame, text="Cancel", command=self.destroy).grid(row=0, column=0, padx=5)
        ttk.Button(button_frame, text="Save", command=self._save).grid(row=0, column=1)

        self.transient(parent)
        self.grab_set()

    def _save(self):
        name = self.name_var.get().strip()
        if not name:
            messagebox.showerror("Missing name", "Please enter an employee name.")
            return

        preferences = {}
        for day in DAYS:
            first = self.first_vars[day].get()
            second = self.second_vars[day].get()
            choices = [first]
            if second != NONE_CHOICE and second != first:
                choices.append(second)
            preferences[day] = choices

        self.result = {"name": name, "preferences": preferences}
        self.destroy()


class SchedulerApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Employee Shift Scheduler")
        self.geometry("1000x680")
        self.roster_data = []  # list[dict] in the same shape as employees.json

        paned = ttk.PanedWindow(self, orient=tk.HORIZONTAL)
        paned.pack(fill=tk.BOTH, expand=True, padx=8, pady=8)

        left = ttk.Frame(paned, padding=8)
        right = ttk.Frame(paned, padding=8)
        paned.add(left, weight=1)
        paned.add(right, weight=2)

        ttk.Label(left, text="Employees", font=("", 11, "bold")).pack(anchor="w")
        self.tree = ttk.Treeview(left, columns=("name",), show="headings", height=14, selectmode="browse")
        self.tree.heading("name", text="Name")
        self.tree.pack(fill=tk.BOTH, expand=True, pady=5)

        button_row = ttk.Frame(left)
        button_row.pack(fill=tk.X, pady=4)
        ttk.Button(button_row, text="Add", command=self.add_employee).pack(side=tk.LEFT, padx=2)
        ttk.Button(button_row, text="Edit", command=self.edit_employee).pack(side=tk.LEFT, padx=2)
        ttk.Button(button_row, text="Remove", command=self.remove_employee).pack(side=tk.LEFT, padx=2)
        ttk.Button(left, text="Load Sample Roster", command=self.load_sample).pack(fill=tk.X, pady=(8, 2))

        self.status_var = tk.StringVar(value="0 employees loaded.")
        ttk.Label(left, textvariable=self.status_var, foreground="#555").pack(anchor="w", pady=(8, 0))
        ttk.Button(left, text="Generate Schedule", command=self.generate_schedule).pack(fill=tk.X, pady=(12, 0))

        ttk.Label(right, text="Weekly Schedule", font=("", 11, "bold")).pack(anchor="w")
        self.output = tk.Text(right, wrap="none", font=("Courier New", 10))
        y_scroll = ttk.Scrollbar(right, orient=tk.VERTICAL, command=self.output.yview)
        self.output.configure(yscrollcommand=y_scroll.set, state="disabled")
        self.output.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, pady=5)
        y_scroll.pack(side=tk.RIGHT, fill=tk.Y)

    def _refresh_tree(self):
        self.tree.delete(*self.tree.get_children())
        for index, employee in enumerate(self.roster_data):
            self.tree.insert("", "end", iid=str(index), values=(employee["name"],))
        self.status_var.set(f"{len(self.roster_data)} employee(s) loaded.")

    def add_employee(self):
        dialog = EmployeeDialog(self)
        self.wait_window(dialog)
        if dialog.result:
            self.roster_data.append(dialog.result)
            self._refresh_tree()

    def edit_employee(self):
        selection = self.tree.selection()
        if not selection:
            messagebox.showinfo("No selection", "Select an employee to edit first.")
            return
        index = int(selection[0])
        dialog = EmployeeDialog(self, existing=self.roster_data[index])
        self.wait_window(dialog)
        if dialog.result:
            self.roster_data[index] = dialog.result
            self._refresh_tree()

    def remove_employee(self):
        selection = self.tree.selection()
        if not selection:
            messagebox.showinfo("No selection", "Select an employee to remove first.")
            return
        index = int(selection[0])
        del self.roster_data[index]
        self._refresh_tree()

    def load_sample(self):
        self.roster_data = json.loads(DATA_FILE.read_text())
        self._refresh_tree()

    def generate_schedule(self):
        if not self.roster_data:
            messagebox.showinfo("No employees", "Add employees (or load the sample roster) first.")
            return
        roster = build_roster(self.roster_data)
        result = run_schedule(roster, seed=42)
        text = format_schedule(result)

        self.output.configure(state="normal")
        self.output.delete("1.0", tk.END)
        self.output.insert("1.0", text)
        self.output.configure(state="disabled")
        self.status_var.set(f"{len(self.roster_data)} employee(s) loaded. Schedule generated.")


def main():
    app = SchedulerApp()
    app.mainloop()


if __name__ == "__main__":
    main()
