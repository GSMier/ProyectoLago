import json
import sys
import matplotlib.pyplot as plt
import numpy as np

def process_json(file_path):
    with open(file_path, "r") as file:
        data = json.load(file)

    checker_counts = {}

    for block in data["blocks"]:
        for result in block["results"]:
            checker_id = result["checkerID"]
            outcome = result["result"]

            if checker_id not in checker_counts:
                checker_counts[checker_id] = {"OK": 0, "ERROR": 0}

            if outcome in checker_counts[checker_id]:
                checker_counts[checker_id][outcome] += 1

    return checker_counts

def plot_results(checker_counts, output_file="checker_validation.png"):
    checker_ids = list(checker_counts.keys())
    ok_counts = [checker_counts[checker]["OK"] for checker in checker_ids]
    error_counts = [checker_counts[checker]["ERROR"] for checker in checker_ids]

    x = np.arange(len(checker_ids))  
    width = 0.2  

    fig, ax = plt.subplots(figsize=(12, 6))

    bars_ok = ax.bar(x - width/2, ok_counts, width, label="OK", color="green")
    bars_error = ax.bar(x + width/2, error_counts, width, label="ERROR", color="red")

    # Increase y-axis scale dynamically
    max_count = max(ok_counts + error_counts) if ok_counts + error_counts else 1
    ax.set_ylim(0, max_count * 2)  # Add 20% extra space above the highest bar

    ax.set_xlabel("Checker ID")
    ax.set_ylabel("Count")
    ax.set_title("Integrity Check Results per Checker ID")
    ax.set_xticks(x)
    ax.set_xticklabels(checker_ids, rotation=45, ha="right")
    ax.legend()

    # Annotate each bar with its value
    for bar in bars_ok + bars_error:
        height = bar.get_height()
        if height > 0:
            ax.text(bar.get_x() + bar.get_width() / 2, height + (max_count * 0.02),  # Offset for clarity
                    str(height), ha="center", va="bottom", fontsize=10, fontweight="bold")

    # Add grid lines for better readability
    ax.yaxis.grid(True, linestyle="--", alpha=0.7)

    plt.tight_layout()
    plt.savefig(output_file, dpi=300)
    print(f"Plot saved as {output_file}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <json_file>")
        sys.exit(1)

    json_file = sys.argv[1]
    checker_counts = process_json(json_file)
    plot_results(checker_counts)

