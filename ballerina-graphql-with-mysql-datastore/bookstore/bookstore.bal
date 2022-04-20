import ballerina/graphql;

public type Book record {|
    string title;
    int published_year;
    Author author;
|};

public type Author record {|
    string name;
    string country;
    string language;
|};

service /bookstore on new graphql:Listener(4000) {
    
    isolated resource function get bookByName(string title) returns Book[] {
        return getBooks(title);
    }

    isolated resource function get allBooks() returns Book[] {
        return getBooks(());
    }

    remote function addBook(string authorName, string authorCountry, string authorLanguage, string title,
                                                                        int published_year) returns int {
        int|error ret = addBookData(authorName, authorCountry, authorLanguage, title, published_year);
        return ret is error ? -1 : ret;
    }
}
