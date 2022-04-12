import ballerinax/mysql;
import ballerina/sql;
import ballerina/log;

final mysql:Client dbClient = check new ("localhost", "root", "password", "bookstore", 3306);

function addAuthor(string name, string country, string language) returns int|error {
    sql:ExecutionResult result = check dbClient->execute(`INSERT INTO AUTHOR(name, country, language) VALUES 
                                                          (${name},${country},${language})`);
    return <int>result.lastInsertId;
}

function addBook(string title, int published_year, int authorId) returns int|error {
    sql:ExecutionResult result = check dbClient->execute(`INSERT INTO BOOK(title, published_year, author_id) VALUES 
                                                          (${title},${published_year},${authorId})`);
    return <int>result.lastInsertId;
}

isolated function getBooks(string? title) returns Book[] {
    Book[] books = [];
    sql:ParameterizedQuery query = `SELECT b.title, b.published_year, a.name, a.country,
                                    a.language FROM BOOK  b left  join AUTHOR a on b.author_id=a.author_id`;
    if title is string {
        query = `SELECT b.title, b.published_year, a.name, a.country, a.language FROM BOOK b left join 
                 AUTHOR a on b.author_id=a.author_id where  b.title=${title}`;
    }
    stream<record {}, error?> resultStream = dbClient->query(query);
    error? res = from record {} result in resultStream
        do {
            Book b = {
                title: <string>result["title"],
                published_year: <int>result["published_year"],
                author: {
                    name: <string>result["name"],
                    country: <string>result["country"],
                    language: <string>result["language"]
                }
            };
            books.push(b);
        };
    if res is error {
        log:printError(res.message());
    }
    return books;
}

function addBookData(string authorName, string authorCountry, string authorLanguage, string title, int published_year)
                                                                                                    returns error|int {
    int author_id = -1;
    stream<record {}, error?> resultStream = dbClient->query(`SELECT author_id from AUTHOR WHERE name=${authorName}`);
    record {|record {} value;|}|error? result = resultStream.next();

    if result is record {|record {} value;|} {
        author_id = check result.value["author_id"].ensureType(int);
    } else {
        author_id = check addAuthor(authorName, authorCountry, authorLanguage);
    }
    check resultStream.close();

    int bookId = check addBook(title, published_year, author_id);
    return bookId;
}
