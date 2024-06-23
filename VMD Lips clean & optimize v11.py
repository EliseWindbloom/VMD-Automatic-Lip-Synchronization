# Code by Elise Windbloom

import os
import sys
import csv
import time
import tkinter as tk
from tkinter import ttk
from tkinter import messagebox
from tkinter import filedialog
import subprocess

VMD_CONVERTER_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "VMDConverter", "VMDConverter.exe")

def run_vmd_converter(file_dir):
    subprocess.run([VMD_CONVERTER_DIR, file_dir], check=True)
    
    new_file = ""
    if get_file_extension(file_dir) == "vmd":
        new_file = os.path.join(get_file_directory(file_dir), get_file_name_without_extension(file_dir) + ".csv")
    else:
        new_file = os.path.join(get_file_directory(file_dir), get_file_name_without_extension(file_dir) + ".vmd")
    
    if os.path.exists(new_file):
        return new_file
    else:
        print(f"Error - File Not Found: {new_file} not found.")
        sys.exit()

def clean_data(c_array, csv_file):
    array_size = len(c_array)
    max_columns = max(len(row) for row in c_array)
    c_array_final = [[None for _ in range(max_columns)] for _ in range(array_size)]
    
    i_count = 0
    i_count_items = 0
    i_start_index = -1
    a_index_a = []
    a_index_i = []
    a_index_u = []
    a_index_o = []
    a_index_extra = []

    for i in range(array_size):
        if i_start_index == -1:
            copy_row(c_array_final, i_count, c_array, i)
            i_count += 1
            if c_array[i][0] in "あいうお":
                i_start_index = i
        else:
            if c_array[i][0] == "あ":
                a_index_a.append(i)
            elif c_array[i][0] == "い":
                a_index_i.append(i)
            elif c_array[i][0] == "う":
                a_index_u.append(i)
            elif c_array[i][0] == "お":
                a_index_o.append(i)
            elif i > i_start_index:
                a_index_extra.append(i)

    i_count_dif = i_count
    i_count = process_indexes(a_index_a, c_array, c_array_final, i_count)
    i_count = process_indexes(a_index_i, c_array, c_array_final, i_count)
    i_count = process_indexes(a_index_u, c_array, c_array_final, i_count)
    i_count = process_indexes(a_index_o, c_array, c_array_final, i_count)
    i_count_items += (i_count - i_count_dif)

    for i in a_index_extra:
        copy_row(c_array_final, i_count, c_array, i)
        i_count += 1
        i_count_items += 1

    c_array_final[i_start_index - 1][0] = str(i_count_items-1)
    print(f"Array Item at Row {i_start_index - 1}, Column 0: {c_array[i_start_index - 1][0]} i_count={i_count} i_count_items={i_count_items}")

    csv_file_cleaned = os.path.join(get_file_directory(csv_file), get_file_name_without_extension(csv_file) + "_cleaned.csv")
    export_array_to_csv(c_array_final[:i_count], csv_file_cleaned)
    return csv_file_cleaned

def process_indexes(a_indexes, c_array, c_array_final, i_count):
    for j in range(len(a_indexes)):
        if j < 2 or j > (len(a_indexes) - 3):
            copy_row(c_array_final, i_count, c_array, a_indexes[j])
            i_count += 1
        else:
            v1 = float(c_array[a_indexes[j]][2])
            v2 = float(c_array[a_indexes[j - 1]][2])
            v3 = float(c_array[a_indexes[j + 1]][2])
            if not (v1 == 0 and v2 == 0 and v3 == 0) and higher_or_lower(v1, v2, v3):
                copy_row(c_array_final, i_count, c_array, a_indexes[j])
                i_count += 1
    return i_count

def copy_row(a_dest, i_dest_index, a_src, i_src_index):
    src_row = a_src[i_src_index]
    dest_row = a_dest[i_dest_index]
    for i in range(min(len(src_row), len(dest_row))):
        dest_row[i] = src_row[i]

def load_csv(csv_file):
    with open(csv_file, 'r', encoding='shift_jis') as file:
        csv_reader = csv.reader(file)
        csv_array = [row for row in csv_reader if row]  # Skip empty rows
    
    print(f"Total rows in CSV: {len(csv_array)}")
    print(f"First few rows: {csv_array[:5]}")
    
    return csv_array

def higher_or_lower(v1, v2, v3):
    if v1 > v2 and v1 > v3:
        return True
    elif v1 < v2 and v1 < v3:
        return True
    elif v1 == 0 and (v2 != 0 or v3 != 0):
        return True
    elif v1 == 1 and (v2 != 1 or v3 != 1):
        return True
    elif v1 < 0.0099 and ((v2 > 0.0099 and v2 > v1) or (v3 > 0.0099 and v3 > v1)):
        return True
    else:
        return False

def export_array_to_csv(array, file_path):
    with open(file_path, 'w', newline='', encoding='shift_jis') as file:
        csv_writer = csv.writer(file)
        csv_writer.writerows(array)

def get_elapsed_time(start_time, format=0):
    elapsed_time = time.time() - start_time
    hours, rem = divmod(elapsed_time, 3600)
    minutes, seconds = divmod(rem, 60)
    milliseconds = int((seconds - int(seconds)) * 1000)
    
    if format == 1:
        return f"{int(hours)} hours, {int(minutes)} minutes, {int(seconds)} seconds, and {milliseconds} milliseconds."
    else:
        return f"{int(hours):02d}:{int(minutes):02d}:{int(seconds):02d}.{milliseconds:03d}"

def get_file_directory(file_path):
    return os.path.dirname(file_path)

def get_file_name_without_extension(file_path):
    return os.path.splitext(os.path.basename(file_path))[0]

def get_file_extension(file_path):
    return os.path.splitext(file_path)[1][1:]

def show_tooltip(tt_text="tooltip text",show_for=3):
    # Create the main window
    root = tk.Tk()
    root.withdraw()  # Hide the main window

    # Create a tooltip
    tooltip = tk.Toplevel(root)
    tooltip.wm_overrideredirect(True)  # Remove window decorations
    # Get the screen coordinates of the mouse pointer
    mouse_x = root.winfo_pointerx()
    mouse_y = root.winfo_pointery()
    tooltip.wm_geometry(f"+{mouse_x}+{mouse_y + 20}")  # Adjust y by 20 for readability

    # Add label to the tooltip
    label = ttk.Label(tooltip, text=tt_text, padding=(5, 3))
    label.pack()

    # Show the tooltip
    tooltip.deiconify()

    # Update the window to ensure it's displayed
    tooltip.update()

    # Wait for 3 seconds
    time.sleep(show_for)

    # Destroy the tooltip and exit
    tooltip.destroy()
    root.quit()

def show_results(elapsed_time_string_clean_data, elapsed_time_string, vmd_file_cleaned):
    root = tk.Tk()
    root.withdraw()  # Hide the main window

    message = (
        f"Time Taken (Cleaning Data Only): {elapsed_time_string_clean_data}\n"
        f"Time Taken (Total): {elapsed_time_string}\n\n"
        f"Cleaned VMD file saved:\n{vmd_file_cleaned}"
    )

    messagebox.showinfo("Results", message)
    root.destroy()  # Destroy the hidden root window

def main():
    root = tk.Tk()
    root.withdraw()

    vmd_file = filedialog.askopenfilename(title="Select VMD File (with mouth data only) to clean and optimize",
                                          filetypes=[("VMD Files", "*.vmd"), ("All Files", "*.*")])
    if not vmd_file:
        print("No vmd file was selected.")
        return

    start_time = time.time()
    
    print("Converting to CSV file")
    show_tooltip("Converting to CSV file",1)
    csv_file = run_vmd_converter(vmd_file)
    
    print("Cleaning/Optimizing CSV file")
    show_tooltip("Cleaning/Optimizing CSV file",1)
    c_array = load_csv(csv_file)
    
    start_time_clean_data = time.time()
    csv_file_cleaned = clean_data(c_array, csv_file)
    elapsed_time_string_clean_data = get_elapsed_time(start_time_clean_data)
    
    print("Saving cleaned VMD file")
    show_tooltip("Saving cleaned VMD file",1)
    vmd_file_cleaned = run_vmd_converter(csv_file_cleaned)
    
    os.remove(csv_file)
    os.remove(csv_file_cleaned)
    
    elapsed_time_string = get_elapsed_time(start_time)
    
    print(f"Time Taken (Cleaning Data Only): {elapsed_time_string_clean_data}")
    print(f"Time Taken (Total): {elapsed_time_string}")
    print(f"Cleaned VMD file saved: {vmd_file_cleaned}")

    show_results(elapsed_time_string_clean_data, elapsed_time_string, vmd_file_cleaned)

if __name__ == "__main__":
    main()