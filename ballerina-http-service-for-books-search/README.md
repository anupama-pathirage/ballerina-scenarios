# Ballerina HTTP Service for book and movie search

Refer to the scenario below. 

![Untitled Diagram drawio (1)](https://user-images.githubusercontent.com/16300038/173151138-5ccbb92e-387e-499f-ac83-c65613a5543c.png)


## External Calls

### Google Books API
https://www.googleapis.com/books/v1/volumes?q=intitle:war%20and%20peace



### IMDB Movie API

https://imdb-api.com/en/API/SearchMovie/k_mhb0408y/war%20and%20peace

https://imdb-api.com/en/API/Trailer/k_mhb0408y/tt3910804



## Test URL

curl "localhost:9090/books/search?name=war%20and%20peace" | jq
