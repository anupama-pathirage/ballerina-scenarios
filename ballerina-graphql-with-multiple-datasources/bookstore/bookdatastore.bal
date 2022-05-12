import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/http;

type Database record {|
    string host;
    string name;
    int port;
    string username;
    string password;
|};

configurable Database database = ?;

final mysql:Client dbClient = check new (database.host, database.username, database.password, database.name, database.port);
final http:Client bookEp = check new ("https://www.googleapis.com/books/v1");

function getBooks(string? bookTitle) returns Book[] {
    sql:ParameterizedQuery query = `SELECT b.title, b.published_year, b.isbn, a.name, a.country  
                                    FROM BOOK b left join AUTHOR a on b.author_id=a.author_id`;
    if bookTitle is string {
        query = sql:queryConcat(query, ` where b.title=${bookTitle}`);
    }
    stream<BookDetails, error?> resultStream = dbClient->query(query);
    BookDetails[]|error? bookRecords = from var {title, published_year, isbn, name, country} in resultStream
        select {
            title: title,
            published_year: published_year,
            isbn: isbn,
            name: name,
            country: country
        };
    Book[] books = [];
    if bookRecords is BookDetails[] {
        books = bookRecords.map(br => new Book(br));
    }
    return books;
}

function addBookData(string authorName, string authorCountry,
                    string title, int published_year, string isbn) returns int|error {
    int author_id = -1;
    int|sql:Error result = dbClient->queryRow(`SELECT author_id from AUTHOR WHERE name=${authorName}`);
    if result is error {
        author_id = check addAuthorToDB(authorName, authorCountry);
    } else {
        author_id = result;
    }
    int bookId = check addBookToDB(title, published_year, isbn, author_id);
    return bookId;
}

function addAuthorToDB(string name, string country) returns int|error {
    sql:ExecutionResult result = check dbClient->execute(`INSERT INTO AUTHOR(name, country) VALUES 
                                                          (${name},${country})`);
    return <int>result.lastInsertId;
}

function addBookToDB(string title, int published_year, string isbn, int authorId) returns int|error {
    sql:ExecutionResult result = check dbClient->execute(`INSERT INTO BOOK(title, published_year, isbn, author_id) VALUES 
                                                          (${title},${published_year},${isbn},${authorId})`);
    return <int>result.lastInsertId;
}

function getBookReviews(string isbn) returns VolumeInfo|error {
    BookReviews bookReviews = check bookEp->get(string `/volumes?q=isbn:${isbn}`);
    return bookReviews.items[0].volumeInfo;
}
