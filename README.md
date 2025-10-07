# cbZUGFeRD

A ColdBox module for generating ZUGFeRD/XRechnung compliant invoices in ColdFusion (CFML).

## What is ZUGFeRD?

ZUGFeRD (Zentraler User Guide des Forums elektronische Rechnung Deutschland) is a German standard for electronic invoicing that embeds structured XML invoice data (based on the UN/CEFACT Cross Industry Invoice standard) into PDF/A-3 files. This allows invoices to be both human-readable (PDF) and machine-readable (XML) in a single file.

## Features

- Generate ZUGFeRD compliant PDF invoices with embedded XML data
- Based on the [Mustang Project](https://www.mustangproject.org/) Java library
- Support for PDF/A-3b conversion via Gotenberg
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
- [Gotenberg](https://gotenberg.dev/) server (for PDF/A conversion)
  - Run via Docker: `docker run --rm -p 3000:3000 gotenberg/gotenberg:8`
- cbJavaLoader module

## Installation

1. Place the module in your ColdBox application's `modules` directory
2. Ensure the Mustang Project library JAR is in the `lib` folder
3. Configure your module settings (see Configuration section)

## Dependencies

- **cbjavaloader**: For loading the Mustang Project Java library
- **Mustang Project library** (library-2.13.0-shaded.jar): The core ZUGFeRD generation library

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

The module provides an example implementation in `handlers/Home.cfc` that demonstrates:

1. Creating invoice metadata (dates, numbers, notes)
2. Setting up sender and recipient information
3. Adding invoice line items
4. Converting a regular PDF to PDF/A-3b format
5. Embedding ZUGFeRD XML data into the PDF
6. Exporting the final compliant invoice

### Example

See `handlers/Home.cfc` for a complete working example with dummy data. The example shows how to:

- Initialize invoice objects
- Set sender/recipient trade party information
- Add products and line items
- Configure bank details
- Generate and convert PDFs
- Create the final ZUGFeRD compliant invoice

## Validation

You can validate your generated ZUGFeRD invoices using these online validators:

- [PortInvoice](https://www.portinvoice.com/)
- [Validool](https://validool.org/valitool-validierung-von-e-rechnungen-en16931-zugferd-xrechnung-order-desadv/)
- [easyfirma validators](https://easyfirma.net/e-rechnung/zugferd/validatoren)

## Resources

- [Mustang Project](https://www.mustangproject.org/)
- [Mustang Project Usage Guide](https://www.mustangproject.org/use/#xrechnung)
- [ZUGFeRD Official Website](https://www.ferd-net.de/zugferd/index.html)
- [Gotenberg Documentation](https://gotenberg.dev/)

## License

Please refer to the Mustang Project license for the underlying Java library.

## Notes

This module is designed to be integrated into your existing ColdBox application. Replace the dummy data in the example handler with your own invoice data from your database or business logic.
