import ballerina/http;

type ITunesItem record {
    string artistName;
    string collectionName;
    string trackName;
    decimal collectionPrice;
    int trackTimeMillis;
};

type ITunesResponse record {
    int resultCount;
    ITunesItem[] results;
};

type Tunes record {|
    string artist;
    string collection;
    string track;
    decimal price;
    int time;
|};

type DiscountedTuneItem record {|
    string artist;
    string album;
    decimal discountedPrice;
    int time;
|};

type Customer record {|
    int id;
    string name;
    string address;
    string email;
|};

table<Customer> customerTable = table [
    {id: 1, name: "John", address: "20, Palm Grove", email: "john@foo.com"},
    {id: 2, name: "Peter", address: "Palm Grove", email: "peter@bar.com"}
];

service /store on new http:Listener(9090) {

    resource function get tunes(string name) returns Tunes[]|error {
        http:Client httpClient = check new ("https://itunes.apple.com");
        ITunesResponse iTuensResponse = check httpClient->get("/search?entity=musicTrack&term=" + name);
        return from ITunesItem item in iTuensResponse.results
            order by item.collectionPrice ascending
            select {
                artist: item.artistName,
                collection: item.collectionName,
                track: item.trackName,
                price: item.collectionPrice,
                time: item.trackTimeMillis / 1000
            };
    }

    resource function get discounts(string name) returns DiscountedTuneItem[]|error {
        http:Client httpClient = check new ("https://itunes.apple.com");
        ITunesResponse iTuensResponse = check httpClient->get("/search?entity=musicTrack&term=" + name);
        return transform(iTuensResponse.results);
    }

    resource function get customers() returns Customer[]|error {
        return customerTable.toArray();
    }

    resource function post customers(@http:Payload Customer customer) returns Customer {
        customerTable.add(customer);
        return customer;
    }
}

function transform(ITunesItem[] iTunesItem) returns DiscountedTuneItem[] => from var iTunesItemItem in iTunesItem
    select {
        artist: iTunesItemItem.artistName,
        album: iTunesItemItem.collectionName + "|" + iTunesItemItem.trackName,
        discountedPrice: iTunesItemItem.collectionPrice * 0.99,
        time: iTunesItemItem.trackTimeMillis / 1000
    };
