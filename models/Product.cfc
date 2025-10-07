component {
    property name = "product";
    property name = "zeProduct" 		inject="javaloader:org.mustangproject.Product";

    function init(String description, String name, String unit, numeric VATPercent) {
        return zeProduct.init( 
            arguments.description
            ,arguments.name
            ,arguments.unit
            ,javaCast("BigDecimal",arguments.VATPercent)
        );
    }
}