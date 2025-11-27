# cbZUGFeRD v1.1.3

A ColdBox module for generating ZUGFeRD/XRechnung compliant invoices in ColdFusion (CFML).

## What is ZUGFeRD?

ZUGFeRD (Zentraler User Guide des Forums elektronische Rechnung Deutschland) is a German standard for electronic invoicing that embeds structured XML invoice data (based on the UN/CEFACT Cross Industry Invoice standard) into PDF/A-3 files. This allows invoices to be both human-readable (PDF) and machine-readable (XML) in a single file.

## Features

- Generate ZUGFeRD compliant PDF invoices with embedded XML data
- Based on the [Mustang Project](https://www.mustangproject.org/) Java library
- **No external services required** - PDF/A conversion handled by Mustang library
- Easy integration with ColdBox applications
- Full support for:
  - Invoice metadata (numbers, dates, notes)
  - Sender and recipient information (trade parties)
  - Line items with products, prices, quantities
  - VAT/tax rates
  - Bank details
  - Regulatory notes

## Requirements

- ColdBox framework
- Java (the module uses JavaLoader to load the Mustang Project library)
- cbJavaLoader module

## Installation

1. Place the module in your ColdBox application's `modules` directory
2. Ensure the Mustang Project library JAR is in the `lib` folder
3. Configure your module settings (see Configuration section)

## Dependencies

- **cbjavaloader**: For loading the Mustang Project Java library
- **Mustang Project library** (library-2.20.0-shaded.jar): The core ZUGFeRD generation library (Java 17+ compatible)

## Configuration

Configure the module in your ColdBox configuration file with the following settings:

```cfc
moduleSettings = {
    cbZUGFeRD = {
        IBAN = "DE12345678901234567890",
        BIC = "BANKDEFFXXX",
        bankAccountName = "Your Company Name",
        RegulatoryNote1 = "Your first regulatory note",
        RegulatoryNote2 = "Your second regulatory note"
    }
};
```

## Usage

The module uses a **factory pattern** to create ZUGFeRD objects. This approach properly handles WireBox dependency injection timing with JavaLoader.

### Quick Start

```cfc
// Get the factory (singleton)
var factory = getInstance('MustangFactory@cbzugferd');

// Create an invoice
var invoice = factory.createInvoice();

// Create sender trade party (name, street, ZIP, location, country)
var sender = factory.createTradeParty("My Company", "Main Street 1", "12345", "Berlin", "DE");
sender.addVATID("DE123456789");

// Add bank details to sender
var bankDetails = factory.createBankDetails("DE89370400440532013000", "COBADEFFXXX");
bankDetails.setAccountName("My Company");
sender.addBankDetails(bankDetails);

// Create recipient trade party
var recipient = factory.createTradeParty("Customer Inc", "Customer Road 5", "54321", "Munich", "DE");
recipient.addVATID("DE987654321");

// Set invoice dates and parties
invoice.setDueDate(now())
    .setIssueDate(now())
    .setDeliveryDate(now())
    .setSender(sender)
    .setRecipient(recipient)
    .setOwnTaxID("4711")
    .setReferenceNumber("INV-2024-001")
    .setNumber("2024-001");

// Add regulatory notes (Geschäftsführer, Handelsregister)
invoice.addRegulatoryNote("Geschäftsführer: Max Mustermann");
invoice.addRegulatoryNote("Handelsregister: Amtsgericht Berlin HRB 12345");

// Create product (description, name, unit, VATPercent)
var product = factory.createProduct("Widget Description", "Widget", "C62", 19);

// Create item (product, price, quantity)
var item = factory.createItem(product, 99.99, 2);
invoice.addItem(item);

// Generate your PDF (e.g., with cfdocument)
cfdocument(format="PDF" fontembed="true" fontdirectory="/System/Library/Fonts/Supplemental/" type="modern" name="pdfContent") {
    writeOutput('<html><head><style>body { font-family: Arial, sans-serif; }</style></head><body>');
    writeOutput('<h1>Invoice</h1>...');
    writeOutput('</body></html>');
}
fileWrite("/path/to/invoice.pdf", pdfContent);

// Create ZUGFeRD PDF with embedded XML
// disableAutoClose(true) keeps PDF in memory for potential further processing
var exporter = factory.createExporterFromA1()
    .disableAutoClose(true)
    .ignorePDFAErrors()  // Allows regular PDF input (not just PDF/A-1)
    .load("/path/to/invoice.pdf")
    .setProducer("My Application")
    .setCreator("cbZUGFeRD");

exporter.setTransaction(invoice);
exporter.export("/path/to/zugferd-invoice.pdf");
exporter.close();
```

### Factory Methods

The `MustangFactory` provides these methods:

| Method | Parameters | Description |
|--------|------------|-------------|
| `createInvoice()` | none | Creates a new Invoice object |
| `createTradeParty()` | name, street, ZIP, location, country | Creates a trade party (sender/recipient) |
| `createProduct()` | description, name, unit, VATPercent | Creates a product |
| `createItem()` | product, price, quantity | Creates a line item |
| `createBankDetails()` | IBAN, BIC | Creates bank details for payment |
| `createContact()` | name, phone, email | Creates a contact person |
| `createExporterFromA1()` | none | Creates exporter for PDF/A-1 input (use with `.ignorePDFAErrors()` for regular PDF) |
| `createExporterFromA3()` | none | Creates exporter for PDF/A-3 input |

### Bank Details Methods

After creating bank details, you can set additional properties:

- `.setAccountName(string)` - Set the account holder name

### Trade Party Methods

After creating a trade party, you can chain these methods:

- `.addVATID(string)` - Add VAT ID
- `.addTaxID(string)` - Add Tax ID
- `.setEmail(string)` - Set email address
- `.setID(string)` - Set organization ID
- `.setContact(contact)` - Set contact person
- `.addBankDetails(bankDetails)` - Add bank details

### Invoice Methods

- `.setNumber(string)` - Invoice number
- `.setIssueDate(date)` - Issue date
- `.setDueDate(date)` - Due date
- `.setDeliveryDate(date)` - Delivery date
- `.setSender(tradeParty)` - Sender/seller
- `.setRecipient(tradeParty)` - Recipient/buyer
- `.setOwnTaxID(string)` - Your tax ID
- `.setReferenceNumber(string)` - Reference number
- `.addItem(item)` - Add line item
- `.addRegulatoryNote(string)` - Add regulatory note (e.g., Geschäftsführer, Handelsregister)

### Exporter Methods

- `.ignorePDFAErrors()` - Allow regular PDF input (not just PDF/A-1)
- `.disableAutoClose(true)` - Keep PDF in memory for further processing
- `.load(string)` - Load source PDF file
- `.setProducer(string)` - Set PDF producer metadata
- `.setCreator(string)` - Set PDF creator metadata
- `.setTransaction(invoice)` - Set the invoice transaction
- `.export(string)` - Export to ZUGFeRD PDF at specified path
- `.close()` - Close the exporter (required when using disableAutoClose)

## Example Handler

See `handlers/Test.cfc` for a complete working example.

## Validation

You can validate your generated ZUGFeRD invoices using these online validators:

- [PortInvoice](https://www.portinvoice.com/)
- [Validool](https://validool.org/valitool-validierung-von-e-rechnungen-en16931-zugferd-xrechnung-order-desadv/)
- [easyfirma validators](https://easyfirma.net/e-rechnung/zugferd/validatoren)

### Font Embedding for PDF/A Compliance

To properly embed fonts in PDFs generated with `cfdocument`, you must:

1. Use `type="modern"` (Flying Saucer engine)
2. Set `fontembed="true"`
3. Specify `fontdirectory` pointing to a folder containing TTF font files
4. Reference the font by its exact name in CSS

**Example:**
```cfc
cfdocument(
    format="PDF"
    fontembed="true"
    fontdirectory="/System/Library/Fonts/Supplemental/"
    type="modern"
    name="pdfContent"
) {
    writeOutput('<html><head>');
    writeOutput('<style>body { font-family: Arial, sans-serif; }</style>');
    writeOutput('</head><body>...');
}
```

**Note:** On macOS, TTF fonts are typically located in `/System/Library/Fonts/Supplemental/`. On Linux/Windows servers, adjust the path accordingly (e.g., `/usr/share/fonts/truetype/` on Ubuntu).

See [Lucee PDF Extension source](https://github.com/lucee/extension-pdf/blob/master/source/java/src/org/lucee/extension/pdf/xhtmlrenderer/FSPDFDocument.java) for implementation details.

## Resources

- [Mustang Project](https://www.mustangproject.org/)
- [Mustang Project Usage Guide](https://www.mustangproject.org/use/#xrechnung)
- [ZUGFeRD Official Website](https://www.ferd-net.de/zugferd/index.html)

## Version History

### v1.1.3
- Updated Mustang library from 2.13.0 to 2.20.0 for Java 17+ compatibility
- Fixes Icc profile error

### v1.1.2
- Fixed font embedding for PDF/A compliance - fonts now properly embedded using `fontdirectory` attribute
- Updated documentation with correct font embedding instructions

### v1.1.1
- Added `createBankDetails()` factory method for payment information
- Added `createContact()` factory method for contact persons

### v1.1.0
- **Breaking Change**: Switched to factory pattern (`MustangFactory`) for creating Java objects
- **Removed**: Gotenberg/Docker dependency - no longer needed for PDF/A conversion
- Uses `ZUGFeRDExporterFromA1` with `ignorePDFAErrors()` to handle regular PDFs
- Simplified API - all object creation through single factory singleton
- Updated documentation with complete usage examples

### v1.0.0
- Initial release
- ZUGFeRD invoice generation using Mustang Project library
- Required Gotenberg Docker container for PDF/A-3b conversion
- Individual model CFCs for each Java class wrapper

## License

Please refer to the Mustang Project license for the underlying Java library.

## Notes

This module is designed to be integrated into your existing ColdBox application. Replace the example data in the test handler with your own invoice data from your database or business logic.
