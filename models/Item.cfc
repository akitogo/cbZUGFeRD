component {
    property name = "invoice";
    property name = "zeItem" 		inject="javaloader:org.mustangproject.Item";

    
    function init( product, numeric price, numeric quantity = 1 
    ) {
        return zeItem.init(
            product
            , javaCast("BigDecimal",arguments.price)
            , javaCast("BigDecimal",arguments.quantity)
        );
    }
}