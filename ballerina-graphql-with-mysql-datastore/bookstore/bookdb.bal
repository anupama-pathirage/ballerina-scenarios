import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

type Data record {|
    string title;
    int published_year;
    string name;
    string country;
    string language;
|};

final mysql:Client dbClient = check new ("localhost", "root", "password", "bookstore", 3306);

isolated function getBooks(string? bookTitle) returns Book[] {
    sql:ParameterizedQuery query = `SELECT b.title, b.published_year, a.name, a.country,
                                    a.language FROM BOOK  b left  join AUTHOR a on b.author_id=a.author_id`;
    if bookTitle is string {
        query = sql:queryConcat(query, ` where b.title=${bookTitle}`);
    }
    stream<Data, error?> resultStream = dbClient->query(query);
    Book[]?|error books = from Data data in resultStream
        select {
            title: data.title,
            published_year: data.published_year,
            author: {
                name: data.name,
                country: data.country,
                language: data.language
            }
        };
    return (books is error?) ? [] : books;
}

function addBookData(string authorName, string authorCountry, string authorLanguage, string title, int published_year)
                                                                                                    returns int|error {
    int author_id = -1;
    int|sql:Error result = dbClient->queryRow(`SELECT author_id from AUTHOR WHERE name=${authorName}`);

    if result is error {
        author_id = check addAuthorToDB(authorName, authorCountry, authorLanguage);
    } else {
        author_id = result;
    }
    int bookId = check addBookToDB(title, published_year, author_id);
    return bookId;
}

function addAuthorToDB(string name, string country, string language) returns int|error {
    sql:ExecutionResult result = check dbClient->execute(`INSERT INTO AUTHOR(name, country, language) VALUES 
                                                          (${name},${country},${language})`);
    return <int>result.lastInsertId;
}

function addBookToDB(string title, int published_year, int authorId) returns int|error {
    sql:ExecutionResult result = check dbClient->execute(`INSERT INTO BOOK(title, published_year, author_id) VALUES 
                                                          (${title},${published_year},${authorId})`);
    return <int>result.lastInsertId;
}
