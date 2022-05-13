import ballerina/websocket;
import ballerina/io;
import ballerina/regex;

isolated map<websocket:Caller[]> clientSymbolSubscriptionMap = {};

listener websocket:Listener stockMgtListner = new websocket:Listener(9090);

service /subscribe on stockMgtListner {
    //Accepts the websocket upgrade from clients by returining a websocket:service
    resource function get .() returns websocket:Service|websocket:UpgradeError {
        return new WsSubscribeService();
    }
}

service /feed on stockMgtListner {
    //Accepts the websocket upgrade from exchange feed by returining a websocket:service
    resource function get .() returns websocket:Service|websocket:UpgradeError {
        return new WsStockFeedService();
    }
}

//Websocket service to handle client subscriptions
service class WsSubscribeService {
    *websocket:Service;

    //Register the client
    remote function onOpen(websocket:Caller caller) returns websocket:Error? {
        string message = "Client with ID :" + caller.getConnectionId() + " registered successfully!";
        check caller->writeTextMessage(message);
        io:println(message);
    }

    //Register the symbol subscriptions of client.
    isolated remote function onTextMessage(websocket:Caller caller, string symbol) returns websocket:Error? {
        lock {
            websocket:Caller[]? clientList = clientSymbolSubscriptionMap[symbol];
            if clientList is websocket:Caller[] {
                clientList.push(caller);
            } else {
                clientSymbolSubscriptionMap[symbol] = [caller];
            }
        }
        io:println("Client " + caller.getConnectionId() + " subscribed for " + symbol);
    }
}

//Websocket service to handle incoming exchange data feed and broadcast to subscribed clients
service class WsStockFeedService {
    *websocket:Service;

    //Register the stock exchange feed
    remote function onOpen(websocket:Caller caller) returns websocket:Error? {
        string message = "Exchange with ID :" + caller.getConnectionId() + " registered successfully!";
        check caller->writeTextMessage(message);
        io:println(message);
    }

    //Receives exchange feed from the exchange and send the updates to registered clients
    isolated remote function onTextMessage(websocket:Caller caller, string text) returns error? {
        string[] result = regex:split(text, ":");
        string symbol = result[0];
        string price = result[1];

        lock {
            if (clientSymbolSubscriptionMap.hasKey(symbol)) {
                websocket:Caller[] clients = clientSymbolSubscriptionMap.get(symbol);
                foreach websocket:Caller c in clients {
                    check c->writeTextMessage(symbol + ":" + price);
                }
            }
        }
    }
}
