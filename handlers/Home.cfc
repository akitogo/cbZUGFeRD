/**
 * The main module handler
 */
component{
	property name="moduleSettings" 								inject="coldbox:moduleSettings:cbZUGFeRD";

	property name="ze" 											inject="javaloader:org.mustangproject.ZUGFeRD.IZUGFeRDExporter";
    property name="zePdf" 										inject="javaloader:org.mustangproject.ZUGFeRD.ZUGFeRDExporterFromA3";

	property name="zeInvoice" 									inject="javaloader:org.mustangproject.Invoice";
	property name="zeItem" 										inject="javaloader:org.mustangproject.Item";
	property name="zeCharge" 									inject="javaloader:org.mustangproject.Charge";
	property name="zeAllowance" 								inject="javaloader:org.mustangproject.Allowance";

	property name="zeProduct" 									inject="javaloader:org.mustangproject.Product";
	property name="zeTradeParty" 								inject="javaloader:org.mustangproject.TradeParty";
	property name="zeContact" 									inject="javaloader:org.mustangproject.Contact";
	property name="zeBankDetails" 								inject="javaloader:org.mustangproject.BankDetails";

	property name="zeLegalOrganisation" 						inject="javaloader:org.mustangproject.LegalOrganisation";

	/**
	 * Example implementation with dummy data - replace with your own services
	 */
	function index( event, rc, prc ){
		var sourcePDF = 'C:\Temp\2\source.pdf';
		var outputFolder = 'C:\Temp\2\';
		//var iZe = ze.init();
		var test = {};
		var resPdf = '';

		// Dummy data for sender (your company)
		var name 		= 'Example Company GmbH';
		var street  	= 'Musterstrasse 123';
		var zip 		= '10115';
		var location 	= 'Berlin';
		var country 	= 'DE';
		var vat 		= 'DE123456789';
	
		// how to create an invoice
		// https://www.mustangproject.org/use/#xrechnung
		var invoice 	= zeInvoice.init();

		invoice.addRegulatoryNote( moduleSettings.RegulatoryNote1 );
		invoice.addRegulatoryNote( moduleSettings.RegulatoryNote2 );
		
		var tradeParty 	= zeTradeParty.init( name = name, street = street, ZIP = zip, location = location, country = country );
		tradeParty.addVATID( vat );
		tradeParty.setName( moduleSettings.bankAccountName );

		// Dummy data for recipient (customer)
		var Recipient 	= zeTradeParty.init(
			name = 'Customer Company Ltd',
			street = 'Customer Street 456',
			ZIP = '20095',
			location = 'Hamburg',
			country = 'DE'
		);

		// Dummy dates
		invoice.setDueDate( dateAdd('d', 30, now()) );
		invoice.setIssueDate( now() );
		invoice.setDeliveryDate( now() );

	
		var bankDetails = zeBankDetails.init( moduleSettings.IBAN , moduleSettings.BIC );
		bankDetails.setAccountName( moduleSettings.bankAccountName );
		tradeparty.addBankDetails( bankDetails );

		invoice.setSender(tradeParty);

		invoice.setRecipient(Recipient);
		invoice.setOwnTaxID( vat );

		// Dummy invoice numbers
		invoice.setNumber( 'INV-2024-001' );
		invoice.setReferenceNumber( 'INV-2024-001' );

		invoice.addNote( 'This is a sample ZUGFeRD invoice for demonstration purposes' );
		
		// Dummy invoice items
		var product1 = zeProduct.init(
			description = 'High-quality consulting services for software development',
			name = 'Consulting Services',
			unit = 'C62',
			VATPercent = javaCast("BigDecimal", 19)
		);
		product1.setSellerAssignedID('SKU: CONS-001');

		var item1 = zeItem.init(
			product = product1,
			price = javaCast("BigDecimal", 150.00),
			quantity = javaCast("BigDecimal", 10)
		);
		invoice.addItem(item1);

		var product2 = zeProduct.init(
			description = 'Software license for one year',
			name = 'Software License',
			unit = 'C62',
			VATPercent = javaCast("BigDecimal", 19)
		);
		product2.setSellerAssignedID('SKU: LIC-002');

		var item2 = zeItem.init(
			product = product2,
			price = javaCast("BigDecimal", 500.00),
			quantity = javaCast("BigDecimal", 1)
		);
		invoice.addItem(item2);

		// create random pdf
		cfdocument( format="PDF" type="modern" page="#{width: 21, height: 29.7, type:'A4'}#" unit="cm" margin="0" name="test" overwrite="true" filename=sourcePDF ){
			writeOutput('<h1>Überschrift #now()#</h1>')
		}

		// send created pdf to docker container of gotenberg
		// https://gotenberg.dev/docs/routes#convert-into-pdfa--pdfua-route
		// run docker container:
		// docker run --rm -p 3000:3000 gotenberg/gotenberg:8
		//
		cfhttp( method="post" url="http://localhost:3000/forms/pdfengines/convert" multipart="true" result="resPdf") {
			cfhttpparam(type="file" name="files" file="#sourcePDF#");
			cfhttpparam(type="formfield" name="pdfa" value="PDF/A-3b");
			cfhttpparam(type="formfield" name="pdfua" value="true");
		}

		//var c = converter.init(sourcePDF);
		//dump(spreof); abort;
		//c.toPdfA1A( outputFolder & "toPdfA1A.pdf" );

		fileWrite(outputFolder& "gotenberg.pdf",resPdf.fileContent);

		var iZe = zePdf.init();
		//dump(iZe);
		iZe.load(outputFolder & "gotenberg.pdf").setProducer("My Application").setCreator("cbZugferd");
		iZe.setTransaction(invoice);
		iZe.export(outputFolder & "final.pdf");

		// validate pdf here
		// https://www.portinvoice.com/
		// as well see here 
		// https://easyfirma.net/e-rechnung/zugferd/validatoren
		// https://validool.org/valitool-validierung-von-e-rechnungen-en16931-zugferd-xrechnung-order-desadv/
		
		dump('DONE'); abort;
		event.setView( "home/index" );
	}

}
