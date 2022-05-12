import ballerina/graphql;

type BookReviews record {
    record {
        VolumeInfo volumeInfo;
    }[] items; //Anonymous record defined in-line
};

type VolumeInfo record {
    int averageRating?;
    int ratingsCount?;
};

type BookDetails record {|
    string title;
    int published_year;
    string isbn;
    string name;
    string country;
|};

service class Book {
    private final readonly & BookDetails bookDetails;

    function init(BookDetails bookDetails) {
        self.bookDetails = bookDetails.cloneReadOnly();
    }
    resource function get title() returns string {
        return self.bookDetails.title;
    }
    resource function get published_year() returns int {
        return self.bookDetails.published_year;
    }
    resource function get isbn() returns string {
        return self.bookDetails.isbn;
    }
    resource function get author/name() returns string {
        return self.bookDetails.name;
    }
    resource function get author/country() returns string {
        return self.bookDetails.country;
    }
    resource function get reviews() returns VolumeInfo|error {
        string isbn = self.bookDetails.isbn;
        return getBookReviews(isbn);
    }
}

service /bookstore on new graphql:Listener(4000) {
    resource function get bookByName(string title) returns Book[] {
        return getBooks(title);
    }
    resource function get allBooks() returns Book[] {
        return getBooks(());
    }
    remote function addBook(string authorName, string authorCountry, string title,
                                                int published_year, string isbn) returns int {
        int|error ret = addBookData(authorName, authorCountry, title, published_year, isbn);
        return ret is error ? -1 : ret;
    }
}

