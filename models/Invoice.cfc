component {
    property name="ze" 				inject="javaloader:org.mustangproject.ZUGFeRD.IZUGFeRDExporter";

    property name = "zeInvoice" 		inject="javaloader:org.mustangproject.Invoice";

    
    function init() {
        return zeInvoice.init();
    }
}