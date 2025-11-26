/**
 * ZUGFeRD Invoice Generation Example
 */
component {

    /**
     * Generate a ZUGFeRD compliant PDF invoice
     */
    function index(event, rc, prc) {
        var sourcePDF = expandPath('/modules/cbZUGFeRD/tmp/test.pdf');
        var outputFolder = expandPath('/modules/cbZUGFeRD/tmp/');

        // Get the factory (singleton that handles all Java object creation)
        var factory = getInstance('MustangFactory@cbzugferd');

        // Create invoice
        var invoice = factory.createInvoice();

        // Create sender trade party (name, street, ZIP, location, country)
        var tradeParty = factory.createTradeParty("testfirma", "teststr", "55232", "teststadt", "DE");
        tradeParty.addVATID("DE0815");

        // Create recipient trade party
        var Recipient = factory.createTradeParty("testfirmaRecipient", "teststr", "55232", "teststadt", "DE");
        Recipient.addVATID("DE0815");

        // Set invoice dates and parties
        invoice.setDueDate(now()).setIssueDate(now()).setDeliveryDate(now());
        invoice.setSender(tradeParty);
        invoice.setRecipient(Recipient);
        invoice.setOwnTaxID("4711");
        invoice.setReferenceNumber("991-01484-64");

        // Create product and item (description, name, unit, VATPercent)
        var product = factory.createProduct("Testprodukt", "", "C62", 0);
        // Create item (product, price, quantity)
        var item = factory.createItem(product, 1, 1);
        invoice.setNumber("123").addItem(item);

        // Create PDF with cfdocument
        var test = {};
        cfdocument(format="PDF" type="modern" page="#{width: 21, height: 29.7, type:'A4'}#" unit="cm" margin="0" name="test" overwrite="true") {
            writeOutput('<h1>Überschrift #now()#</h1>');
        }

        // Save the PDF file
        fileWrite(sourcePDF, test);

        // Use ZUGFeRDExporterFromA1 with ignorePDFAErrors to handle regular PDF
        // This converts the PDF and embeds the ZUGFeRD XML data
        var iZe = factory.createExporterFromA1()
            .ignorePDFAErrors()
            .load(sourcePDF)
            .setProducer("My Application")
            .setCreator("cbZugferd");
        iZe.setTransaction(invoice);
        iZe.export(outputFolder & "final.pdf");

        // Validate your generated ZUGFeRD invoice here:
        // https://www.portinvoice.com/
        // https://validool.org/valitool-validierung-von-e-rechnungen-en16931-zugferd-xrechnung-order-desadv/
        // https://easyfirma.net/e-rechnung/zugferd/validatoren

        dump(var=iZe, top=3); abort;
        event.setView("home/index");
    }

}
