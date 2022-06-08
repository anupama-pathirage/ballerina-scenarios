import ballerina/http;

//Books Details
type VolumeInfo record {
    string title;
    decimal averageRating?;
    string[] authors?;
};

type Items record {
    VolumeInfo volumeInfo;
    string selfLink;
};

type Books record {
    Items[] items;
};

//Movie Records
type MovieData record {
    string id;
};

type Movies record {
    MovieData[] results;
};

type MovieDetails record {
    string fullTitle = "";
    string year = "";
    string link = "";
};

//Return Types

type BookData record {|
    string selfLink;
    string title;
    decimal? averageRating;
    string[]? authors;
|};

type NovelData record {|
    BookData[] bookData;
    string fullTitle = "";
    string year = "";
    string link = "";
|};

service /books on new http:Listener(9090) {
    resource function get search(string name) returns NovelData|error {
        http:Client booksEP = check new ("https://www.googleapis.com/books/v1/volumes");

        Books books = check booksEP->get("?q=intitle:" + name);

        BookData[] bookData = from Items item in books.items
            where item.volumeInfo.averageRating != ()
            select {
                selfLink: item.selfLink,
                title: item.volumeInfo.title,
                averageRating: item.volumeInfo.averageRating,
                authors: item.volumeInfo.authors
            };

        http:Client movieEP = check new ("https://imdb-api.com/en/API/");
        Movies movies = check movieEP->get("SearchMovie/k_mhb0408y/" + name);

        MovieDetails movieDetails = {};
        if (movies.results.length() > 0) {
            movieDetails = check movieEP->get("Trailer/k_mhb0408y/" + movies.results[0].id);
        }

        return {
            bookData,
            fullTitle: movieDetails.fullTitle,
            year: movieDetails.year,
            link: movieDetails.link
        };
    }
}
