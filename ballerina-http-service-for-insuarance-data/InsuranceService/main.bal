import ballerina/http;
import ballerina/lang.'string as string0;
import ballerinax/googleapis.sheets;
import ballerinax/openai.chat;

//Input records
type Address record {
    string street;
    string city;
    string state;
    string zipCode;
};

type Customer record {
    string firstName;
    string lastName;
    string email;
    string phoneNumber;
    Address address;
};

type PolicyDetails record {
    string policyType;
    string effectiveDate;
    string expirationDate;
    decimal coverageAmount;
    decimal deductibleAmount;
    int monthlyPayment;
    int initialPayment;
    string[] additionalCoverage;
};

type PolicyRequest record {
    string id;
    Customer customer;
    PolicyDetails policyDetails;
};

//Output records
type PolicyHolder record {|
    string name;
    string email;
    string phoneNumber;
|};

type PolicySummary record {|
    string policyType;
    string effectiveDate;
    string expirationDate;
    decimal coverageAmount;
    decimal deductibleAmount;
    int annualPayment;
    string additionalCoverage;
|};

type ConfirmedPolicy record {|
    string policyNumber;
    PolicyHolder policyHolder;
    PolicySummary policySummary;
|};

configurable string sheetsToken = ?;
configurable string sheetId = ?;
configurable string sheetName = ?;

final sheets:Client sheets = check new (config = {auth: {token: sheetsToken}});

configurable string openAIToken = ?;
final chat:Client chatEp = check new (config = {auth: {token: openAIToken}});

service /abc on new http:Listener(9090) {
    resource function post policies(PolicyRequest[] payload) returns error|ConfirmedPolicy[] {
        ConfirmedPolicy[] confirmedPolicies = [];
        foreach PolicyRequest policyRequest in payload {
            //Do some processing and transofrmation
            ConfirmedPolicy policy = transformToConfirmedPolicies(policyRequest);
            //Get risk analysis from OpenAI
            chat:CreateChatCompletionRequest request = {
                model: "gpt-3.5-turbo",
                messages: [
                    {
                        role: "user",
                        content: string `Generate a risk analysis for this insuarance policy. Policy details are 
                            Client name ${policy.policyHolder.name}, policy type ${policy.policySummary.policyType}, 
                            effective date ${policy.policySummary.effectiveDate}, expiration date ${policy.policySummary.expirationDate}, 
                            coverage amount ${policy.policySummary.coverageAmount},
                            deductible Amount ${policy.policySummary.deductibleAmount} and 
                            additionalCoverage ${policy.policySummary.additionalCoverage}`
                    }
                ]
            };
            chat:CreateChatCompletionResponse res = check chatEp->/chat/completions.post(request);
            //Update google sheet
            _ = check sheets->appendValue(sheetId, [policy.policyNumber, policy.policyHolder.name, policy.policySummary.policyType, res.choices[0].message?.content ?: ""], {sheetName});
            //Add to the list
            confirmedPolicies.push(policy);
        }
        return confirmedPolicies;
    }
}

function transformToConfirmedPolicies(PolicyRequest policyRequest) returns ConfirmedPolicy => {
    policyNumber: policyRequest.id,
    policyHolder: {
        name: policyRequest.customer.firstName + " " + policyRequest.customer.lastName,
        email: policyRequest.customer.email,
        phoneNumber: policyRequest.customer.phoneNumber
    },
    policySummary: {
        policyType: policyRequest.policyDetails.policyType,
        effectiveDate: policyRequest.policyDetails.effectiveDate,
        expirationDate: policyRequest.policyDetails.expirationDate,
        coverageAmount: policyRequest.policyDetails.coverageAmount,
        deductibleAmount: policyRequest.policyDetails.deductibleAmount,
        annualPayment: policyRequest.policyDetails.monthlyPayment * 12 + policyRequest.policyDetails.initialPayment,
        additionalCoverage: string0:'join(",", ...policyRequest.policyDetails.additionalCoverage)
    }
};
