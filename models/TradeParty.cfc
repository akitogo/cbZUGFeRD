component {
    property name = "TradeParty";
    property name = "zeTradeParty" 		inject="javaloader:org.mustangproject.TradeParty";

    
    function init( String name, String street, String ZIP,String location,String country) {
        return zeTradeParty.init(
            arguments.name
            , arguments.street
            , arguments.ZIP
            , arguments.country
        );
    }
}