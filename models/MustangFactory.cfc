component singleton {
    property name="TradePartyClass"      inject="javaloader:org.mustangproject.TradeParty";
    property name="ProductClass"         inject="javaloader:org.mustangproject.Product";
    property name="ItemClass"            inject="javaloader:org.mustangproject.Item";
    property name="InvoiceClass"         inject="javaloader:org.mustangproject.Invoice";
    property name="BankDetailsClass"     inject="javaloader:org.mustangproject.BankDetails";
    property name="ContactClass"         inject="javaloader:org.mustangproject.Contact";
    property name="AllowanceClass"       inject="javaloader:org.mustangproject.Allowance";
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

    /**
     * Phone / e-mail are only set when non-empty: Mustang writes every non-null
     * value, so "" would produce empty <ram:CompleteNumber/> / <ram:URIID/> elements
     * that EN16931 validators reject.
     */
    function createContact(required string name, string phone = "", string email = "") {
        var contact = ContactClass.init();
        contact.setName(trim(arguments.name));
        if (len(trim(arguments.phone))) contact.setPhone(trim(arguments.phone));
        if (len(trim(arguments.email))) contact.setEMail(trim(arguments.email));
        return contact;
    }

    /**
     * Document-level allowance (SpecifiedTradeAllowanceCharge, ChargeIndicator=false).
     * @amount     positive net amount that is deducted
     * @vatPercent VAT rate the allowance belongs to (drives the tax breakdown)
     * @reason     BT-97 — required by BR-33 when no reason code is given
     */
    function createAllowance(required numeric amount, numeric vatPercent = 0, string reason = "Rabatt") {
        var allowance = AllowanceClass.init(javaCast("BigDecimal", abs(arguments.amount)));
        allowance.setTaxPercent(javaCast("BigDecimal", arguments.vatPercent));
        if (arguments.vatPercent > 0) allowance.setCategoryCode("S");
        allowance.setReason(len(trim(arguments.reason)) ? trim(arguments.reason) : "Rabatt");
        return allowance;
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
