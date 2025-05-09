import csv
from datetime import datetime

# Function to read the CSV file and extract times and temperatures
def read_csv(file_name):
    times = []
    temps = []
    
    with open(file_name, 'r') as file:
        reader = csv.reader(file)
        next(reader)  # Skip the header row
        
        for row in reader:
            timestamp = datetime.strptime(row[0], "%Y-%m-%d %H:%M:%S.%f")
            temp = float(row[1])
            times.append(timestamp)
            temps.append(temp)
    
    return times, temps

# Convert datetime to seconds since the start (for time differences)
def time_to_seconds(start_time, current_time):
    delta = current_time - start_time
    return delta.total_seconds()

def estimate_G(times, temps, start_time, end_time, m, c, T_ambient):
    start_index = None
    end_index = None

    for i, t in enumerate(times):
        if start_time <= t <= end_time:
            if start_index is None:
                start_index = i
            end_index = i

    if start_index is None or end_index is None:
        print("Error: Start or End time not within data range.")
        return None

    G_values = []

    for i in range(start_index, end_index):
        delta_t = time_to_seconds(times[i], times[i+1])
        delta_T = temps[i+1] - temps[i]
        dT_dt = delta_T / delta_t

        if T_ambient != temps[i]:  # Avoid divide-by-zero
            G_i = (m * c * dT_dt) / (T_ambient - temps[i])
            G_values.append(G_i)

    if len(G_values) == 0:
        print("No valid G values found in the range.")
        return None

    G_avg = sum(G_values) / len(G_values)
    return G_avg

# Calculate total heat transferred (Q) using Riemann sum (without integrals)
def calculate_heat(times, temps, start_time, end_time, G, T_ambient):
    # Find the index for start_time and end_time
    start_index = None
    end_index = None
    
    for i, t in enumerate(times):
        if start_time <= t <= end_time:
            if start_index is None:
                start_index = i  # First valid time index
            end_index = i  # Last valid time index
    
    if start_index is None or end_index is None:
        print("Error: Start or End time not within data range.")
        return None
    
    # Initialize total heat transfer Q
    Q = 0.0
    
    # Loop through the data points to compute the Riemann sum
    for i in range(start_index, end_index):
        # Calculate delta t (time step) in seconds
        delta_t = time_to_seconds(times[start_index], times[i+1])
        
        # Temperature difference from ambient
        delta_T = T_ambient - temps[i]
        
        # Add to the total heat transferred using the formula
        Q += G * delta_T * delta_t
        
    return Q

# Main function to execute the process
def main():
    # === Parameters (update these!) ===
    file_name = 'measurements-2nd-attempt.csv'

    # Melting plateau phase
    melt_start_str = "2025-03-23 01:15:08.0"
    melt_end_str = "2025-03-23 10:00:08.0"

    # Warm-up phase for estimating G
    G_start_str = "2025-03-23 11:50:08.0"
    G_end_str = "2025-03-23 17:04:08.420029"

    T_ambient = 20.96  # °C
    m = 100  # g
    c = 4.181  # J/g·K

    # === Time conversion ===
    G_start = datetime.strptime(G_start_str, "%Y-%m-%d %H:%M:%S.%f")
    G_end = datetime.strptime(G_end_str, "%Y-%m-%d %H:%M:%S.%f")
    melt_start = datetime.strptime(melt_start_str, "%Y-%m-%d %H:%M:%S.%f")
    melt_end = datetime.strptime(melt_end_str, "%Y-%m-%d %H:%M:%S.%f")

    # === Read CSV ===
    times, temps = read_csv(file_name)

    # === Estimate G ===
    # HACK: m / 1000
    G = estimate_G(times, temps, G_start, G_end, m / 1000, c, T_ambient)
    if G is None:
        print("Failed to estimate G.")
        return
    print(f"Estimated thermal conductance G: {G} W/K")

    # === Calculate Q during melting ===
    Q = calculate_heat(times, temps, melt_start, melt_end, G, T_ambient)
    if Q is None:
        print("Failed to calculate heat transfer.")
        return
    print(f"Total heat transferred during melting: {Q} J")

    # === Calculate latent heat of fusion ===
    L = Q / m
    print(f"Latent heat of fusion: {L} J/g")

# Run the script
if __name__ == "__main__":
    main()
