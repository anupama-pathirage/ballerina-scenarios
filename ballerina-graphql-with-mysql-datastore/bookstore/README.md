# Set up Environment

Create the sample MySQL database and  populate data with the `data.sql` script as follows.

```
mysql -uroot -p < /path/to/data.sql

```
# Run the code

Execute `bal run` command  within the `bookstore` project folder.



# Sample Requests and Responses

## Request 1
```
curl -X POST -H "Content-type: application/json" -d '{ "query": "{bookByName(title: \"Emma\") {title, published_year}}" }' 'http://localhost:4000/bookstore'
```

### Response
```json
{"data":{"bookByName":[{"title":"Emma", "published_year":1815}]}}
```

## Request 2
```
 curl -X POST -H "Content-type: application/json" -d '{ "query": "{allBooks {title}}" }' 'http://localhost:4000/bookstore'
 ```

### Response
```json
{"data":{"allBooks":[{"title":"Pride and Prejudice"}, {"title":"Sense and Sensibility"}, {"title":"Emma"}, {"title":"War and Peace"}, {"title":"Anna Karenina"}]}}
```

## Request 3
```
curl -X POST -H "Content-type: application/json" -d '{ "query": "{allBooks {title, author{name, language}}}" }' 'http://localhost:4000/bookstore'
```

### Response
```json
{"data":{"allBooks":[{"title":"Pride and Prejudice", "author":{"name":"Jane Austen", "language":"English"}}, {"title":"Sense and Sensibility", "author":{"name":"Jane Austen", "language":"English"}}, {"title":"Emma", "author":{"name":"Jane Austen", "language":"English"}}, {"title":"War and Peace", "author":{"name":"Leo Tolstoy", "language":"Russian"}}, {"title":"Anna Karenina", "author":{"name":"Leo Tolstoy", "language":"Russian"}}]}}
```

## Request 4
```
curl -X POST -H "Content-type: application/json" -d '{ "query": "mutation {addBook(authorName: \"J. K. Rowling\", authorCountry: \"United Kingdom\", authorLanguage: \"English\", title: \"Harry Potter\", published_year: 2007)}" }' 'http://localhost:4000/bookstore'
```

### Response
```json
{"data":{"addBook":10}}
```
