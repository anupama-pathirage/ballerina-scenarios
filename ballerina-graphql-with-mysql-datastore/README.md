# Sample usecase

In this use case, let’s see how we can implement a GraphQL server using the Ballerina language to expose data in the MySQL database. 

The MySQL database holds data about a book store, and it has book data and author data. Clients of the book store can do the following operations via the GraphQL server.
* Retrieve the details of all the books
* Retrieve the details of the book by providing the book name
* Add new books to the database

<img src="images/GraphQL_DB_Scenario.png"/>

# Set up the Database

Create the sample MySQL database and  populate data with the `data.sql` script as follows.

```
mysql -uroot -p < /path/to/data.sql

```
# Run the code

Execute `bal run` command  within the `bookstore` project folder.

# Test the service

To call the GraphQL server, we need to use a client. We can do this from the command line with [curl](https://curl.se/) by sending an HTTP POST request to the endpoint, passing the GraphQL query as the query field in a JSON payload. If you prefer to use a graphical user interface, you can use clients such as [GraphiQL](https://github.com/graphql/graphiql) or [Altair](https://altair.sirmuel.design/#download).

For all the requests the endpoint is  : http://localhost:4000/bookstore

## Sample Request 1:  Get the titles of all books

GraphQL query: 
```
{allBooks {title}}
```

Response: 
```json
{
 "data": {
   "allBooks": [
     { "title": "Pride and Prejudice" },
     { "title": "Sense and Sensibility" },
     { "title": "Emma" },
     { "title": "War and Peace" },
     { "title": "Anna Karenina" }
   ]
 }
}
```
CURL command  to request the same:
curl -X POST -H "Content-type: application/json" -d '{ "query": "{allBooks {title}}" }' 'http://localhost:4000/bookstore'

## Sample Request 2:  Get more details of all books

This is where the true power of GraphQL comes in. Users can request the exact information they need in the format they prefer without having different endpoints, but just by changing the query.

GraphQL query : 
```
{allBooks {title, author{name}}}
```

Response :

```json
{
 "data": {
   "allBooks": [
     { "title": "Pride and Prejudice", "author": { "name": "Jane Austen" } },
     { "title": "Sense and Sensibility", "author": { "name": "Jane Austen" } },
     { "title": "Emma", "author": { "name": "Jane Austen" } },
     { "title": "War and Peace", "author": { "name": "Leo Tolstoy" } },
     { "title": "Anna Karenina", "author": { "name": "Leo Tolstoy" } }
   ]
 }
}
```

CURL command to send the same request:

```
curl -X POST -H "Content-type: application/json" -d '{ "query": " {allBooks {title, author{name}}}" }' 'http://localhost:4000/bookstore'
```

## Sample Request 3:  Get details of books with  input parameter  

GraphQL Query:  
```
{bookByName(title: "Emma") {title, published_year}}
```

Response:

```json
{ "data": { "bookByName": [{ "title": "Emma", "published_year": 1815 }] } }
```

CURL Command to send the same request:
```
curl -X POST -H "Content-type: application/json" -d '{ "query": "{bookByName(title: \"Emma\") {title, published_year}}" }' 'http://localhost:4000/bookstore'
```

## Sample Request 4: Mutation to insert data into the database

GraphQL Query:
```
mutation {addBook(authorName: "J. K. Rowling", authorCountry: "United Kingdom", authorLanguage: "English", title: "Harry Potter", published_year: 2007)}
```
Response:

```json
{
 "data": {
   "addBook": 6
 }
}
```

CURL Command to send the same request:
```
curl -X POST -H "Content-type: application/json" -d '{ "query": "mutation {addBook(authorName: \"J. K. Rowling\", authorCountry: \"United Kingdom\", authorLanguage: \"English\", title: \"Harry Potter\", published_year: 2007)}" }' 'http://localhost:4000/bookstore'
```
