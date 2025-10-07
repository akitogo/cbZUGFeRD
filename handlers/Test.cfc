/**
 * PdfA1A generation
 */
component{

	/**
	 * use existing PDF, attach some data, save it as PdfA1A
	 */
	function index( event, rc, prc ){
		var sourcePDF = '/sampledir/modules/cbZUGFeRD/tmp/test.pdf';
		var outputFolder = '/sampledir/modules/cbZUGFeRD/tmp/';
		//var iZe = ze.init();
		var test = {};
		var resPdf = '';

		// how to create an invoice
		// https://www.mustangproject.org/use/#xrechnung
		var invoice 	= getInstance('invoice@cbzugferd').init();
		var tradeParty 	= getInstance('tradeparty@cbzugferd').init("testfirma","teststr", "55232", "teststadt", "DE");
		tradeParty.addVATID("DE0815");

		var Recipient 	= getInstance('tradeparty@cbzugferd').init("testfirmaRecipient","teststr", "55232", "teststadt", "DE");
		Recipient.addVATID("DE0815");

		invoice.setDueDate( now() ).setIssueDate(now()).setDeliveryDate(now());

		invoice.setSender(tradeParty);
		invoice.setRecipient(Recipient);
		invoice.setOwnTaxID("4711");

		invoice.setReferenceNumber("991-01484-64");
		var product 	= getInstance('product@cbzugferd').init("Testprodukt", "", "C62", javaCast("BigDecimal",0) );
		var item 		= getInstance('item@cbzugferd').init(product, javaCast("BigDecimal",1),javaCast("BigDecimal",1) );

		invoice.setNumber("123").addItem(item);

		// create random pdf
		cfdocument(format="PDF" type="modern" page="#{width: 21, height: 29.7, type:'A4'}#" unit="cm" margin="0" name="test" overwrite="true"){
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

		fileWrite(outputFolder& "toPdfA1A.pdf",resPdf.fileContent);

		var iZe = getInstance('exporter@cbzugferd').init();
		dump(iZe);
		iZe.load(outputFolder & "toPdfA1A.pdf").setProducer("My Application").setCreator("cbZugferd");
		iZe.setTransaction(invoice);
		iZe.export(outputFolder & "final.pdf");

		// validate pdf here
		// https://www.portinvoice.com/
		// as well see here 
		// https://easyfirma.net/e-rechnung/zugferd/validatoren
		// https://validool.org/valitool-validierung-von-e-rechnungen-en16931-zugferd-xrechnung-order-desadv/
		
		dump(var=iZe,top=3); abort;
		event.setView( "home/index" );
	}

}
