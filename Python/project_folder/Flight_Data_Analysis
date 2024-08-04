# Import necessary libraries
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sb
import datetime
import requests
import json

# Ensure plots are displayed inline
%matplotlib inline

# Fetch data from the API
url = "https://data.gov.il/api/3/action/datastore_search?resource_id=e83f763b-b7d7-479e-b172-ae981ddc6de5&limit=5000"
response = requests.get(url)
res = json.loads(response.content)
df = pd.DataFrame(res['result']['records'])

# Display the first and last few rows of the dataset for initial exploration
print("First 10 rows of the dataset:")
print(df.head(10))
print("\nLast 10 rows of the dataset:")
print(df.tail(10))

# Display basic information about the dataset
print("Dataset Info:")
df.info()

# Display the number of unique values in each column
print("Unique values in each column:")
print(df.nunique())

# Data Cleaning
print("Empty Strings Percentage (by columns):")
for column in df.columns:
    empty_counts = df[column].isnull().sum()
    total_counts = len(df[column])
    percentage = (empty_counts / total_counts) * 100
    print(f'{column}: {empty_counts} null values, {percentage:.2f}%')

# Remove rows with more than 3 null values
df = df[df.isnull().sum(axis=1) <= 3]

# Drop columns with more than 50% null values
half = len(df) * 0.5
columns_to_drop = [column for column in df.columns if df[column].isnull().sum() > half]
df.drop(columns=columns_to_drop, inplace=True)

# Drop unnecessary columns
if '_id' in df.columns:
    df.drop(columns='_id', inplace=True)
df.drop(columns=['CHLOC1CH', 'CHLOC1TH', 'CHRMINH'], inplace=True)

# Save the cleaned data to a CSV file
current_date = datetime.datetime.now()
formatted_date = current_date.strftime('%d_%m_%y')
output_filename = f'row_data_{formatted_date}.csv'
df.to_csv(output_filename, index=False)
print(f"Cleaned data saved to {output_filename}")

# Airports list processing
airports = df[['CHLOC1', 'CHLOC1D']].drop_duplicates()
airports_csv_df = pd.read_csv('airports.csv')
union_airports_df = pd.concat([airports, airports_csv_df], ignore_index=True).drop_duplicates()
union_airports_df.reset_index(drop=True, inplace=True)
union_airports_df.to_csv('airports.csv', index=False)
df.drop(columns=['CHLOC1D', 'CHLOC1'], inplace=True)

# Airlines list processing
airlines = df[['CHOPER', 'CHOPERD']].drop_duplicates()
airlines_csv_df = pd.read_csv('airlines.csv')
union_airlines_df = pd.concat([airlines, airlines_csv_df], ignore_index=True).drop_duplicates()
union_airlines_df.reset_index(drop=True, inplace=True)
union_airlines_df.to_csv('airlines.csv', index=False)
df.drop(columns=['CHOPER', 'CHOPERD'], inplace=True)

# Rename columns for better readability
df.rename(columns={
    'CHFLTN': 'FlightNum',
    'CHSTOL': 'PlanTime',
    'CHPTOL': 'ActualTime',
    'CHAORD': 'Direction',
    'CHLOC1T': 'City',
    'CHLOCCT': 'Country',
    'CHTERM': 'Terminal',
    'CHRMINE': 'Status',
}, inplace=True)

# Save the cleaned and processed data to a CSV file
cleaned_filename = f'cleaned_data_{formatted_date}.csv'
df.to_csv(cleaned_filename, index=False)
print(f"Cleaned data saved to {cleaned_filename}")

# Filter for final CSV with specific statuses
need_status = ['LANDED', 'DEPARTED', 'CANCELED']
for_final_df = df[df['Status'].isin(need_status)]
final_csv_df = pd.read_csv('final.csv')
final_df = pd.concat([for_final_df, final_csv_df], ignore_index=True).drop_duplicates()
final_df.reset_index(drop=True, inplace=True)
final_df.to_csv('final.csv', index=False)

# Convert PlanTime and ActualTime to datetime
final_df['PlanTime'] = pd.to_datetime(final_df['PlanTime'], errors='coerce')
final_df['ActualTime'] = pd.to_datetime(final_df['ActualTime'], errors='coerce')

# Calculate the total delay in minutes
final_df['TotalDelayMinutes'] = (final_df['ActualTime'] - final_df['PlanTime']).dt.total_seconds() / 60
df = final_df

# Calculate the average delay for departed flights
departed_flights = df[df['Status'] == 'DEPARTED']
average_delay = departed_flights['TotalDelayMinutes'].mean()
print(f'Average delay for departed flights: {average_delay:.2f} minutes')

# Visualizations
plt.figure(figsize=(15, 8))

# 1. Distribution of flight statuses
plt.subplot(2, 4, 1)
status_counts = df['Status'].value_counts()
sb.barplot(x=status_counts.index, y=status_counts.values, palette='viridis')
plt.title('Flight Status Distribution')
plt.ylabel('Count')
plt.xlabel('Status')

# 2. Average delay per flight status
plt.subplot(2, 4, 2)
average_delay_status = df.groupby('Status')['TotalDelayMinutes'].mean().dropna()
sb.barplot(x=average_delay_status.index, y=average_delay_status.values, palette='magma')
plt.title('Average Delay by Status')
plt.ylabel('Average Delay (Minutes)')
plt.xlabel('Status')

# 3. Flights by terminal
plt.subplot(2, 4, 3)
terminal_counts = df['Terminal'].value_counts()
sb.barplot(x=terminal_counts.index, y=terminal_counts.values, palette='coolwarm')
plt.title('Flights by Terminal')
plt.ylabel('Count')
plt.xlabel('Terminal')

# 4. Top 10 cities by flight count
plt.subplot(2, 4, 4)
city_counts = df['City'].value_counts().head(10)
sb.barplot(x=city_counts.values, y=city_counts.index, palette='cubehelix')
plt.title('Top 10 Cities by Flight Count')
plt.xlabel('Count')
plt.ylabel('City')

# 5. Top 10 countries by flight count
plt.subplot(2, 4, 5)
country_counts = df['Country'].value_counts().head(10)
sb.barplot(x=country_counts.values, y=country_counts.index, palette='plasma')
plt.title('Top 10 Countries by Flight Count')
plt.xlabel('Count')
plt.ylabel('Country')

# 6. Average delay by terminal
plt.subplot(2, 4, 6)
average_delay_terminal = df.groupby('Terminal')['TotalDelayMinutes'].mean().dropna()
sb.barplot(x=average_delay_terminal.index, y=average_delay_terminal.values, palette='inferno')
plt.title('Average Delay by Terminal')
plt.ylabel('Average Delay (Minutes)')
plt.xlabel('Terminal')

# 7. Delays distribution
plt.subplot(2, 4, 7)
sb.histplot(df['TotalDelayMinutes'].dropna(), bins=50, kde=True, color='skyblue')
plt.title('Distribution of Delays')
plt.xlabel('Total Delay (Minutes)')
plt.ylabel('Frequency')

plt.tight_layout()
plt.show()

# Separate visualizations
plt.figure(figsize=(10, 6))

# 1. Count of Flights per Hour of the Day
df['HourOfDay'] = df['PlanTime'].dt.hour
hourly_flights = df['HourOfDay'].value_counts().sort_index()
sb.barplot(x=hourly_flights.index, y=hourly_flights.values, palette='viridis')
plt.title('Count of Flights per Hour of the Day')
plt.ylabel('Count')
plt.xlabel('Hour of Day')
plt.show()

plt.figure(figsize=(10, 6))

# 2. Count of Delayed Flights per Hour of the Day
delayed_flights = df[df['TotalDelayMinutes'] > 0]['HourOfDay'].value_counts().sort_index()
sb.barplot(x=delayed_flights.index, y=delayed_flights.values, palette='magma')
plt.title('Count of Delayed Flights per Hour of the Day')
plt.ylabel('Count')
plt.xlabel('Hour of Day')
plt.show()

plt.figure(figsize=(10, 6))

# 3. Plan vs Actual time scatter plot
plt.scatter(df['PlanTime'], df['ActualTime'], alpha=0.3)
plt.title('Planned vs Actual Time')
plt.xlabel('Planned Time')
plt.ylabel('Actual Time')
plt.show()
