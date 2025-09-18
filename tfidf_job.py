# tfidf_job.py
import sys
from pyspark.sql import SparkSession
from pyspark.ml.feature import Tokenizer, HashingTF, IDF
from pyspark.sql.functions import col, udf
from pyspark.sql.types import DoubleType

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: tfidf_job.py <s3_input_uri>")
        sys.exit(-1)

    s3_input_uri = sys.argv[1]

    spark = SparkSession.builder.appName("TF-IDF Wikipedia").getOrCreate()

    print(f"Reading data from {s3_input_uri}...")
    # 1. Load and prepare data
    raw_data = spark.read.option("sep", "\t").csv(s3_input_uri)
    articles = raw_data.toDF("id", "title", "time", "document")
    
    # 2. Clean data (remove nulls)
    cleaned_articles = articles.filter(articles.document.isNotNull())
    print(f"Total articles after cleaning: {cleaned_articles.count()}")

    # 3. Tokenize text
    tokenizer = Tokenizer(inputCol="document", outputCol="words")
    words_data = tokenizer.transform(cleaned_articles)

    # 4. Apply HashingTF to get term frequencies
    hashingTF = HashingTF(inputCol="words", outputCol="rawFeatures", numFeatures=20000)
    featurized_data = hashingTF.transform(words_data)

    # 5. Apply IDF to get TF-IDF scores
    idf = IDF(inputCol="rawFeatures", outputCol="features")
    idf_model = idf.fit(featurized_data)
    tfidf_data = idf_model.transform(featurized_data)
    print("TF-IDF model created successfully.")

    # 6. Search for the term "Gettysburg"
    search_term = "Gettysburg"
    
    # Get the hash value for the search term
    search_term_df = spark.createDataFrame([(search_term.lower().split(" "),)], ["words"])
    search_term_hashed = hashingTF.transform(search_term_df)
    gettysburg_hash_index = search_term_hashed.select("rawFeatures").first()[0].indices[0]
    
    print(f"The hash index for '{search_term}' is: {gettysburg_hash_index}")
    
    # UDF to extract the TF-IDF score for the specific term's hash index
    def get_tfidf_score(features):
        if gettysburg_hash_index in features.indices:
            # Find the position of our hash index and return the corresponding value
            idx = features.indices.tolist().index(gettysburg_hash_index)
            return float(features.values[idx])
        return 0.0

    extract_score_udf = udf(get_tfidf_score, DoubleType())

    # Add a column with the score for "Gettysburg"
    results = tfidf_data.withColumn("gettysburg_score", extract_score_udf(col("features")))

    # 7. Show top results
    print(f"\n--- Top 10 articles for the term '{search_term}' ---")
    top_results = results.select("title", "gettysburg_score").orderBy(col("gettysburg_score").desc())
    top_results.show(10, truncate=False)

    spark.stop()
