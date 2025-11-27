component singleton {
    property name="TradePartyClass"      inject="javaloader:org.mustangproject.TradeParty";
    property name="ProductClass"         inject="javaloader:org.mustangproject.Product";
    property name="ItemClass"            inject="javaloader:org.mustangproject.Item";
    property name="InvoiceClass"         inject="javaloader:org.mustangproject.Invoice";
    property name="BankDetailsClass"     inject="javaloader:org.mustangproject.BankDetails";
    property name="ContactClass"         inject="javaloader:org.mustangproject.Contact";
    property name="ExporterFromA3Class"  inject="javaloader:org.mustangproject.ZUGFeRD.ZUGFeRDExporterFromA3";
    property name="ExporterFromA1Class"  inject="javaloader:org.mustangproject.ZUGFeRD.ZUGFeRDExporterFromA1";

    function createTradeParty(name, street, ZIP, location, country) {
        return TradePartyClass.init(arguments.name, arguments.street, arguments.ZIP, arguments.location, arguments.country);
    }

    function createProduct(description, name, unit, VATPercent) {
        return ProductClass.init(arguments.description, arguments.name, arguments.unit, javaCast("BigDecimal", arguments.VATPercent));
    }

    function createItem(product, price, quantity = 1) {
        return ItemClass.init(arguments.product, javaCast("BigDecimal", arguments.price), javaCast("BigDecimal", arguments.quantity));
    }

    function createInvoice() {
        return InvoiceClass.init();
    }

    function createBankDetails(IBAN, BIC) {
        return BankDetailsClass.init(arguments.IBAN, arguments.BIC);
    }

    function createContact(name, phone = "", email = "") {
        return ContactClass.init(arguments.name, arguments.phone, arguments.email);
    }

    function createExporterFromA3() {
        return ExporterFromA3Class.init();
    }

    function createExporterFromA1() {
        return ExporterFromA1Class.init();
    }

    /**
     * Get the path to the bundled sRGB ICC profile
     */
    function getICCProfilePath() {
        return expandPath("/modules/cbzugferd/config/sRGB2014.icc");
    }
}
