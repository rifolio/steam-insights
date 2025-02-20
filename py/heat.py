import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

df_genres = pd.read_csv('steam_data/genres.csv')
df_tags = pd.read_csv('steam_data/tags.csv')

#top 5 cat
genre_counts = df_genres['genre'].value_counts()
top5_genres = genre_counts.head(5).index.tolist()
print("Top 5 Genres:", top5_genres)

#Top 5 tag
tag_counts = df_tags['tag'].value_counts()
top5_tags = tag_counts.head(5).index.tolist()
print("Top 5 Tags:", top5_tags)

df_genres_top = df_genres[df_genres['genre'].isin(top5_genres)]
df_tags_top = df_tags[df_tags['tag'].isin(top5_tags)]

merged_df = pd.merge(df_genres_top, df_tags_top, on='app_id', how='inner')

genre_tag_counts = merged_df.groupby(['genre', 'tag']).size().reset_index(name='count')

pivot_table = genre_tag_counts.pivot(index='genre', columns='tag', values='count').fillna(0)

pivot_table = pivot_table.reindex(index=top5_genres, columns=top5_tags, fill_value=0)

plt.figure(figsize=(10, 6))
sns.heatmap(pivot_table, annot=True, fmt="d", cmap="YlGnBu")
plt.title("Overlap Between Top 5 Genres and Top 5 Tags")
plt.xlabel("Tag")
plt.ylabel("Genre")
plt.tight_layout()
plt.show()
