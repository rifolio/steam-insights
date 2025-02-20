import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


df_games = pd.read_csv('steam_data/games.csv', quotechar='"', escapechar="\\", encoding="utf-8", on_bad_lines="skip")
df_tags = pd.read_csv('steam_data/tags.csv')


df_games['release_date'] = pd.to_datetime(df_games['release_date'], errors='coerce')
df_games['year'] = df_games['release_date'].dt.year


df_games = df_games.dropna(subset=['year'])


df_merged = pd.merge(df_games[['app_id', 'year']], df_tags, on='app_id', how='inner')


overall_tag_counts = df_merged.groupby('tag')['app_id'].nunique().reset_index(name='total_games')
top10_tags = overall_tag_counts.sort_values('total_games', ascending=False).head(10)['tag'].tolist()
print("Top 10 Tags:", top10_tags)


tag_year_counts = df_merged[df_merged['tag'].isin(top10_tags)] \
    .groupby(['tag', 'year'])['app_id'].nunique().reset_index(name='count')

pivot_data = tag_year_counts.pivot(index='year', columns='tag', values='count').fillna(0)
pivot_data = pivot_data.sort_index()


plt.figure(figsize=(12, 8))
for tag in pivot_data.columns:
    plt.plot(pivot_data.index, pivot_data[tag], marker='o', label=tag)

plt.xlabel("Year")
plt.ylabel("Number of Games Released")
plt.title("Growth of Top 10 Tags Over the Years")
plt.legend(title="Tag", bbox_to_anchor=(1.05, 1), loc='upper left')
plt.tight_layout()
plt.show()
