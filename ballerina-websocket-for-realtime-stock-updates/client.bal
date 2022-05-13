import ballerina/io;
import ballerina/lang.runtime;
import ballerina/websocket;

public function main() returns error? {
    websocket:Client wsClient = check new (string `ws://localhost:9090/subscribe/`);
    string message = check wsClient->readTextMessage();
    io:println(message);

    //Subscribe for `MSFT` symbol
    check wsClient->writeTextMessage("MSFT");

    //Subscribe for `GOOG` symbol later
    runtime:sleep(20);
    check wsClient->writeTextMessage("GOOG");

    //Read stock updates received from the server
    while true {
        string stockPrice = check wsClient->readTextMessage();
        io:println(stockPrice);
    }
}
