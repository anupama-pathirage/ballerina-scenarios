import ballerina/io;
import ballerina/lang.runtime;
import ballerina/random;
import ballerina/websocket;

string[] symbolArr = ["MSFT", "AAPL", "GOOG", "NFLX", "CSCO"];

public function main() returns error? {
    websocket:Client wsClient = check new (string `ws://localhost:9090/feed/`);
    string message = check wsClient->readTextMessage();
    io:println(message);

    //Calculate dummy prices for each symbol randomly and send to server in every 2 seconds
    while true {
        int randomSymbolIndex = check random:createIntInRange(0, 5);
        float price = random:createDecimal() + 18.0;
        string stockData = symbolArr[randomSymbolIndex] + ":" + price.toString();
        io:println(stockData);
        check wsClient->writeTextMessage(stockData);
        runtime:sleep(2);
    }
}
