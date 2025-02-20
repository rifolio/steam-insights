import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


df_games = pd.read_csv('steam_data/games.csv', quotechar='"', escapechar="\\", encoding="utf-8", on_bad_lines="skip")
df_categories = pd.read_csv('steam_data/categories.csv')


df_games['release_date'] = pd.to_datetime(df_games['release_date'], errors='coerce')
df_games['year'] = df_games['release_date'].dt.year
df_games_subset = df_games[['app_id', 'year']]
df_merged = pd.merge(df_games_subset, df_categories, on='app_id', how='inner')

overall_counts = df_merged.groupby('category')['app_id'].nunique().reset_index(name='total_games')
top10_categories = overall_counts.sort_values('total_games', ascending=False).head(10)['category'].tolist()


category_year_counts = df_merged.groupby(['category', 'year'])['app_id'].nunique().reset_index(name='count')


category_year_top10 = category_year_counts[category_year_counts['category'].isin(top10_categories)]

pivot_data = category_year_top10.pivot(index='year', columns='category', values='count').fillna(0)
pivot_data = pivot_data.sort_index()


plt.figure(figsize=(12, 8))
for category in pivot_data.columns:
    plt.plot(pivot_data.index, pivot_data[category], marker='o', label=category)

plt.xlabel("Year")
plt.ylabel("Number of Games Released")
plt.title("Growth of Top 10 Categories Over the Years")
plt.legend(title="Category", bbox_to_anchor=(1.05, 1), loc='upper left')
plt.tight_layout()
plt.show()
