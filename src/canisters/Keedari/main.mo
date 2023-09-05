import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Map "mo:base/HashMap";
import Hash "mo:base/Hash";
import Error "mo:base/Error";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Ledger    "canister:ledger";
import Account   "./Account";
import Debug     "mo:base/Debug";
import Int       "mo:base/Int";

actor Keedari {
    type Funding = {
        title: Text;
        description: Text;
        goal: Nat;
        currentValue: Nat;
        creator: Principal.Principal;
        backers: [Principal];
        deadLine: Time.Time;
        finished: Bool;
    };

    public func getHello(): async Text {
        return "Hello, world!";
    };

    func natHash(n : Nat) : Hash.Hash { 
        Text.hash(Nat.toText(n));
    };

    var fundings = Map.HashMap<Nat, Funding>(0, Nat.equal, natHash);

    public query func getFunding(id : Nat) : async ?Funding {
        fundings.get(id);
    };

    public func createFunding(title : Text, description : Text, goal : Nat, deadLine : Time.Time, creator: Principal) : async Nat {
        let funding = {
            title = title;
            description = description;
            goal = goal;
            currentValue = 0;
            creator = creator;
            backers = [];
            deadLine = deadLine;
            finished = false;
        };
        fundings.put(fundings.size(), funding);
        return fundings.size() - 1;
    };

    public func fund(id : Nat, amount : Nat, backer : Principal) : async Bool {
        switch (fundings.get(id)) {
            case (?funding) {
                if (funding.finished) {
                    return false;
                };
                if (funding.deadLine < Time.now()) {
                    var currentFunding = {
                        title = funding.title;
                        description = funding.description;
                        goal = funding.goal;
                        currentValue = funding.currentValue;
                        creator = funding.creator;
                        backers = funding.backers;
                        deadLine = funding.deadLine;
                        finished = true;
                    };
                    fundings.put(id, currentFunding); 
                    return false;
                };
                let updatedFunding = {
                    title = funding.title;
                    description = funding.description;
                    goal = funding.goal;
                    currentValue = funding.currentValue + amount;
                    creator = funding.creator;
                    backers = Array.append<Principal>(funding.backers, [backer]);
                    deadLine = funding.deadLine;
                    finished = funding.finished;
                };
                return true;
            };
            case (_) {
                return false;
            };
        }
    };

    public func onFinishSchdule() : async () {
        for (index in fundings.keys()) {
            switch (fundings.get(index)) {
                case (?funding) {
                    if (funding.finished == false and funding.deadLine <= Time.now()) {
                        var currentFunding = {
                            title = funding.title;
                            description = funding.description;
                            goal = funding.goal;
                            currentValue = funding.currentValue;
                            creator = funding.creator;
                            backers = funding.backers;
                            deadLine = funding.deadLine;
                            finished = true;
                        };
                        fundings.put(index, currentFunding);
                    };
                };
                case (_) {

                };
            }
        }
    };

    public func withdraw(id : Nat, creator : Principal) : async Bool {
        switch (fundings.get(id)) {
            case (?funding) {
                if (funding.creator == creator and funding.finished) {
                    if (funding.currentValue >= funding.goal) {
                        let now = Time.now();   
                        let res = await Ledger.transfer({
                            memo = Nat64.fromNat(0);
                            from_subaccount = null;
                            to = Account.accountIdentifier(creator, Account.defaultSubaccount());
                            amount = { e8s = Nat64.fromNat(funding.currentValue)};
                            fee = { e8s = 10_000 };
                            created_at_time = ?{ timestamp_nanos = Nat64.fromNat(Int.abs(now)) };
                        });
                        switch (res) {
                            case (#Ok(blockIndex)) {
                                Debug.print("Paid reward to " # debug_show creator # " in block " # debug_show blockIndex);
                            };
                            case (#Err(#InsufficientFunds { balance })) {
                                throw Error.reject("Top me up! The balance is only " # debug_show balance # " e8s");
                            };
                            case (#Err(other)) {
                                throw Error.reject("Unexpected error: " # debug_show other);
                            };
                        };
                        return true;
                    };
                    return true;
                };
                return false;
            };
            case (_) {
                return false;
            };
        }
    };
}