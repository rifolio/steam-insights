import pandas as pd
import re
import matplotlib.pyplot as plt
from wordcloud import WordCloud, STOPWORDS


df_games = pd.read_csv('steam_data/games.csv', quotechar='"', escapechar="\\", encoding="utf-8", on_bad_lines="skip")

titles = df_games['name'].dropna().tolist()

text = " ".join(titles)

text = text.lower()

text = re.sub(r'[^a-z\s]', ' ', text)

text = re.sub(r'\s+', ' ', text).strip()


stopwords = set(STOPWORDS)


wordcloud = WordCloud(
    width=800,
    height=400,
    background_color='white',
    stopwords=stopwords,
    collocations=False  
).generate(text)


plt.figure(figsize=(12, 6))
plt.imshow(wordcloud, interpolation='bilinear')
plt.axis("off")
plt.title("Word Cloud of Game Titles (Filtered)")
plt.show()
